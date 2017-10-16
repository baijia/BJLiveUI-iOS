//
//  iCloudLoading.m
//  QBImagePicker
//
//  Created by MingLQ on 2017-01-14.
//  Copyright © 2017 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "BJL_iCloudLoading.h"

#import "ICLProgressView.h"

NS_ASSUME_NONNULL_BEGIN

static inline void icl_dispatch_sync_main_queue(dispatch_block_t block) {
    if ([NSThread isMainThread]) block();
    else dispatch_sync(dispatch_get_main_queue(), block);
}
/*
static inline void icl_dispatch_async_main_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
} */
static inline void icl_dispatch_async_background_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
}    

#pragma mark -

static NSString * const ICLImageTemporaryDirectory = @"QBImagePicker+iCloudLoading";
static NSString * const WTFImageFileURLKey = @"PHImageFileURLKey";

@interface ICLImageFile ()

@property (nonatomic, readwrite, copy) NSString *filePath, *fileName;
@property (nonatomic, readwrite, copy, nullable) NSString *mediaType;
// @property (nonatomic, readwrite) UIImageOrientation orientation;

@property (nonatomic, readwrite, nullable) UIImage *thumbnail;
@property (nonatomic, readwrite) PHAsset *asset;
@property (nonatomic, readwrite) CGSize imageSize;

@end

@implementation ICLImageFile

+ (nullable instancetype)imageFileWithAsset:(PHAsset *)asset
                                  imageData:(NSData *)imageData
                                  thumbnail:(nullable UIImage *)thumbnail
                                  mediaType:(nullable NSString *)mediaType
                                // orientation:(UIImageOrientation)orientation
                                      error:(NSError **)error {
    if (!asset || !imageData.length) {
        if (error) *error = nil;
        return nil;
    }
    
    ICLImageFile *imageFile = [self imageFileBySavingImageData:imageData
                                                         error:error];
    imageFile.mediaType = mediaType;
    // imageFile.orientation = orientation;
    imageFile.thumbnail = thumbnail;
    imageFile.asset = asset;
    imageFile.imageSize = CGSizeMake((CGFloat)asset.pixelWidth, (CGFloat)asset.pixelHeight);
    return imageFile;
}

+ (nullable instancetype)imageFileWithImage:(UIImage *)image
                                  thumbnail:(nullable UIImage *)thumbnail
                                  mediaType:(nullable NSString *)mediaType
                                // orientation:(UIImageOrientation)orientation
                                      error:(NSError **)error {
    if (!image) {
        if (error) *error = nil;
        return nil;
    }
    
    NSData *imageData = ([mediaType isEqualToString:(__bridge NSString *)kUTTypePNG]
                         ? UIImagePNGRepresentation(image)
                         : UIImageJPEGRepresentation(image, 1.0));
    ICLImageFile *imageFile = [self imageFileBySavingImageData:imageData
                                                         error:error];
    imageFile.mediaType = mediaType;
    // imageFile.orientation = orientation;
    imageFile.thumbnail = thumbnail;
    imageFile.imageSize = image.size;
    return imageFile;
}

+ (nullable instancetype)imageFileBySavingImageData:(NSData *)imageData
                                              error:(NSError **)error {
    if (!imageData.length) {
        if (error) *error = nil;
        return nil;
    }
    
    NSString *fileDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:ICLImageTemporaryDirectory];
    
    NSString *fileName = [NSString stringWithFormat:@"%lld", ({
        const uint32_t randomLength = 3, randomMultiplier = pow(10, randomLength);
        long long now = (long long)([NSDate timeIntervalSinceReferenceDate] * 1000);
        now = now * randomMultiplier + arc4random_uniform(randomMultiplier);
        now;
    })];
    
    NSString *filePath = [fileDirectory stringByAppendingPathComponent:fileName];
    
    if (error) *error = nil;
    BOOL written = ([[NSFileManager defaultManager] createDirectoryAtPath:fileDirectory
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:error]
                    && [imageData writeToFile:filePath
                                      options:NSDataWritingAtomic
                                        error:error]);
    if (!written) {
        return nil;
    }
    
    ICLImageFile *imageFile = [self new];
    imageFile.filePath = filePath;
    imageFile.fileName = fileName;
    return imageFile;
}

- (NSURL *)fileURL {
    return [NSURL fileURLWithPath:self.filePath isDirectory:NO];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> %@ (%@), %@", // @"<%@: %p> %@ (%@ - %td), %@"
            [self class], self, self.filePath, self.mediaType/* , self.orientation */, self.asset];
}

@end

#pragma mark -

@implementation QBImagePickerController (iCloudLoading)

- (void)icl_loadImageFilesWithAssets:(NSArray<PHAsset *> *)assets {
    [self icl_loadImageFilesWithAssets:assets thumbnailSize:CGSizeZero];
}

// deliveryMode: should NOT be PHImageRequestOptionsDeliveryModeOpportunistic for non-synchronous
- (void)icl_loadImageFilesWithAssets:(NSArray<PHAsset *> *)assets thumbnailSize:(CGSize)thumbnailSize {
    assets = [assets copy];
    icl_dispatch_async_background_queue(^{
        [self _icl_loadImageFilesWithAssets:assets thumbnailSize:thumbnailSize];
    });
}

- (void)_icl_loadImageFilesWithAssets:(NSArray<PHAsset *> *)assets thumbnailSize:(CGSize)thumbnailSize {
    /* loading */
    
    __block UIAlertController *loadingAlert = nil;
    __block ICLProgressView *progressView = nil;
    
    /* result */
    
    NSMutableArray<ICLImageFile *> *imageFiles = [NSMutableArray arrayWithCapacity:assets.count];
    __block BOOL cancelled = NO;
    
    /* image data */
    
    PHImageManager *imageManager = [PHImageManager defaultManager];
    PHImageRequestOptions *imageOptions = ({
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        options.networkAccessAllowed = YES;
        options.synchronous = NO;
        options;
    });
    __block PHImageRequestID imageRequestID = - 1;
    
    /* thumbnail image */
    
    // `new` instead of `defaultManager` for [PHCachingImageManager stop....]
    PHCachingImageManager *thumbnailManager = [PHCachingImageManager new];
    PHImageContentMode thumbnailContentMode = PHImageContentModeAspectFill;
    // NO thumbnailOptions.progressHandler - thumbnail is generate from image data
    PHImageRequestOptions *thumbnailOptions = ({
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = (CGSizeEqualToSize(thumbnailSize, CGSizeZero)
                                ? PHImageRequestOptionsDeliveryModeFastFormat
                                : PHImageRequestOptionsDeliveryModeHighQualityFormat);
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.networkAccessAllowed = YES;
        options.synchronous = NO;
        options;
    });
    __block PHImageRequestID thumbnailRequestID = - 1;
    
    /* for each */
    
    NSEnumerator<PHAsset *> *enumerator = [assets objectEnumerator];
    __block PHAsset *asset = [enumerator nextObject];
    
    /* progress */
    
    typeof(self) __weak __self__ = self;
    typeof(thumbnailOptions) __weak __thumbnailOptions__ = thumbnailOptions;
    // progressHandler: called when image "comes from iCloud", "Photos calls this block in an arbitrary serial queue"
    imageOptions.progressHandler
    = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        typeof(__self__) __strong self = __self__;
        typeof(__thumbnailOptions__) __strong thumbnailOptions = __thumbnailOptions__;
        if (cancelled) {
            *stop = YES;
            return;
        }
        icl_dispatch_sync_main_queue(^{
            if (!loadingAlert) {
                progressView = [ICLProgressView new];
                loadingAlert = [self icl_loadingAlertWithProgressView:progressView cancellingHandler:^(UIAlertAction * _Nonnull action) {
                    [imageManager cancelImageRequest:imageRequestID];
                    [thumbnailManager cancelImageRequest:thumbnailRequestID];
                    [thumbnailManager stopCachingImagesForAssets:assets
                                                      targetSize:thumbnailSize
                                                     contentMode:thumbnailContentMode
                                                         options:thumbnailOptions];
                    cancelled = YES;
                }];
                [self presentViewController:loadingAlert animated:YES completion:nil];
            }
            // left 0.01 for thumbnail
            progressView.progress = (imageFiles.count + progress * 0.99) / assets.count;
            NSLog(@"<#NSString *format#>: %f", progressView.progress);
        });
    };
    
    /* caching */
    
    [thumbnailManager startCachingImagesForAssets:assets
                                       targetSize:thumbnailSize
                                      contentMode:thumbnailContentMode
                                          options:thumbnailOptions];
    
    /* loading */
    
    // resultHandler: "for asynchronous requests, always called on main thread"
    void (^ __block resultHandler)(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info)
    = ^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        typeof(__self__) __strong self = __self__;
        
        if (cancelled) {
            if ([self.delegate respondsToSelector:@selector(icl_imagePickerControllerDidCancelLoadingImageFiles:)]) {
                [(id<QBImagePickerControllerDelegate_iCloudLoading>)self.delegate
                 icl_imagePickerControllerDidCancelLoadingImageFiles:self];
            }
            resultHandler = nil;
            return;
        }
        
        NSError *error = nil;
        ICLImageFile *imageFile = [ICLImageFile imageFileWithAsset:asset
                                                         imageData:imageData
                                                         thumbnail:nil
                                                         mediaType:dataUTI
                                                       // orientation:orientation
                                                             error:&error];
        if (!imageFile) {
            NSLog(@"failed to load image data - [%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error ?: info);
            [self icl_stopLoadingWithAlert:loadingAlert completion:^{
                if ([self.delegate respondsToSelector:@selector(icl_imagePickerControllerDidFailLoadingImageFiles:)]) {
                    [(id<QBImagePickerControllerDelegate_iCloudLoading>)self.delegate
                     icl_imagePickerControllerDidFailLoadingImageFiles:self];
                }
                else {
                    [self icl_alertError];
                }
            }];
            resultHandler = nil;
            return;
        }
        
        /* loading thumbnail */
        
        // resultHandler: "for asynchronous requests, always called on main thread"
        thumbnailRequestID
        = [thumbnailManager requestImageForAsset:asset
                                      targetSize:thumbnailSize
                                     contentMode:thumbnailContentMode
                                         options:thumbnailOptions
                                   resultHandler:^(UIImage * _Nullable thumbnail, NSDictionary * _Nullable info) {
                                       typeof(__self__) __strong self = __self__;
                                       
                                       if (cancelled) {
                                           if ([self.delegate respondsToSelector:@selector(icl_imagePickerControllerDidCancelLoadingImageFiles:)]) {
                                               [(id<QBImagePickerControllerDelegate_iCloudLoading>)self.delegate
                                                icl_imagePickerControllerDidCancelLoadingImageFiles:self];
                                           }
                                           resultHandler = nil;
                                           return;
                                       }
                                       
                                       /* result */
                                       
                                       if (!thumbnail) {
                                           NSLog(@"failed to load thumbnail image - [%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error ?: info);
                                       }
                                       imageFile.thumbnail = thumbnail;
                                       
                                       [imageFiles addObject:imageFile];
                                       progressView.progress = ((double)imageFiles.count) / assets.count; // necessary if NOT load from iCloud
                                       
                                       if ([self.delegate respondsToSelector:@selector(icl_imagePickerController:didFinishLoadingImageFile:)]) {
                                           [(id<QBImagePickerControllerDelegate_iCloudLoading>)self.delegate
                                            icl_imagePickerController:self didFinishLoadingImageFile:imageFile];
                                       }
                                       
                                       /* finish */
                                       
                                       asset = [enumerator nextObject];
                                       if (!asset) {
                                           [self icl_stopLoadingWithAlert:loadingAlert completion:^{
                                               if ([self.delegate respondsToSelector:@selector(icl_imagePickerController:didFinishLoadingImageFiles:)]) {
                                                   [(id<QBImagePickerControllerDelegate_iCloudLoading>)self.delegate
                                                    icl_imagePickerController:self didFinishLoadingImageFiles:imageFiles];
                                               }
                                           }];
                                           resultHandler = nil;
                                           return;
                                       }
                                       
                                       /* next */
                                       
                                       imageRequestID
                                       = [imageManager requestImageDataForAsset:asset
                                                                        options:imageOptions
                                                                  resultHandler:resultHandler];
                                   }];
    };
    
    // fire
    imageRequestID
    = [imageManager requestImageDataForAsset:asset
                                     options:imageOptions
                               resultHandler:resultHandler];
}

- (void)icl_alertError {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"无法下载照片"
                                message:@"从“iCloud 照片图库”下载这张照片时出错。请稍后再试。"
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction
                      actionWithTitle:@"好"
                      style:UIAlertActionStyleCancel
                      handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - private

- (UIAlertController *)icl_loadingAlertWithProgressView:(UIView *)progressView
                                      cancellingHandler:(void (^ _Nullable)(UIAlertAction *action))handler {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"正在从 iCloud 加载..."
                                message:@"\n\n\n\n\n"
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction
                      actionWithTitle:@"取消"
                      style:UIAlertActionStyleCancel
                      handler:handler]];
    [alert.view addSubview:progressView];
    progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [progressView addConstraints:@[[NSLayoutConstraint
                                    constraintWithItem:progressView
                                    attribute:NSLayoutAttributeWidth
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                    attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                    constant:ICLProgressSizeM],
                                   [NSLayoutConstraint
                                    constraintWithItem:progressView
                                    attribute:NSLayoutAttributeHeight
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                    attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                    constant:ICLProgressSizeM]]];
    [alert.view addConstraints:@[[NSLayoutConstraint
                                  constraintWithItem:progressView
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:alert.view
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1.0
                                  constant:0.0],
                                 [NSLayoutConstraint
                                  constraintWithItem:progressView
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:alert.view
                                  attribute:NSLayoutAttributeCenterY
                                  multiplier:1.0
                                  constant:0.0]]];
    return alert;
}

- (void)icl_stopLoadingWithAlert:(UIAlertController *)loadingAlert
                      completion:(void (^)(void))completion {
    if (loadingAlert) {
        [loadingAlert dismissViewControllerAnimated:YES completion:completion];
    }
    else {
        if (completion) completion();
    }
}

@end

NS_ASSUME_NONNULL_END
