//
//  BJLWebImage.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-31.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/UIButton+AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BJLWebImageLoader;
typedef void (^BJLWebImageCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error, NSURL * _Nullable imageURL);

#pragma mark -

@interface UIView (BJLWebImage)

/**
 import BJLWebImageLoader_SD or BJLWebImageLoader_YY via subspec
 set nil to reset, BJLWebImageLoader_YY > BJLWebImageLoader_SD > BJLWebImageLoader_AFN
 */
@property (class,
           nonatomic,
           null_resettable,
           setter=bjl_setImageLoader:) id<BJLWebImageLoader> bjl_imageLoader;

@end

#pragma mark -

/**
 load image if failed: SDWebImageRetryFailed, YYWebImageOptionIgnoreFailedURL
 afn avoid auto set image if has completion, like SDWebImageAvoidAutoSetImage or YYWebImageOptionAvoidSetImage
 */
@protocol BJLWebImageLoader <NSObject>

/* UIImageView */

- (void)bjl_setImageWithURL:(nullable NSURL *)url
                placeholder:(nullable UIImage *)placeholder
                 completion:(nullable BJLWebImageCompletionBlock)completion
                  imageView:(UIImageView *)imageView;
- (void)bjl_cancelCurrentImageLoadForImageView:(UIImageView *)imageView;

/* UIButton */

- (void)bjl_setImageWithURL:(nullable NSURL *)url
                   forState:(UIControlState)state
                placeholder:(nullable UIImage *)placeholder
                 completion:(nullable BJLWebImageCompletionBlock)completion
                     button:(UIButton *)button;
- (void)bjl_cancelCurrentImageLoadForState:(UIControlState)state button:(UIButton *)button;

- (void)bjl_setBackgroundImageWithURL:(nullable NSURL *)url
                             forState:(UIControlState)state
                          placeholder:(nullable UIImage *)placeholder
                           completion:(nullable BJLWebImageCompletionBlock)completion
                               button:(UIButton *)button;
- (void)bjl_cancelCurrentBackgroundImageLoadForState:(UIControlState)state button:(UIButton *)button;

/* download */
// TODO: <#task#>
/*
 [SDWebImageManager.sharedManager loadImageWithURL:options:progress:completed:]
 */
/*
 YYWebImageManager *manager = [YYWebImageManager sharedManager];
 imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:imageURL] withType:YYImageCacheTypeMemory];
 [manager requestImageWithURL:options:progress:transform:completion:] // also load image form disk cache
 */
/*
 [AFImageDownloader sharedImageDownloader]
 
 id <AFImageRequestCache> imageCache = downloader.imageCache;
 UIImage *cachedImage = [imageCache imageforRequest:urlRequest withAdditionalIdentifier:nil];
 
 NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
 [request addValue:@"image/<#---- remove this ----#>*" forHTTPHeaderField:@"Accept"];
 AFImageDownloadReceipt *receipt = [downloader downloadImageForURLRequest:request withReceiptID:[NSUUID UUID] success: failure:];
 */

@end

@interface BJLWebImageLoader_AFN : NSObject <BJLWebImageLoader>
@end

#pragma mark -

@interface UIImageView (BJLWebImage)

// always return nil
@property (nonatomic/*, writeonly */, nullable, setter=bjl_setImageURL:) NSURL *bjl_imageURL;
@property (nonatomic/*, writeonly */, nullable, setter=bjl_setImageURLString:) NSString *bjl_imageURLString;

- (void)bjl_setImageWithURL:(nullable NSURL *)url
                placeholder:(nullable UIImage *)placeholder
                 completion:(nullable BJLWebImageCompletionBlock)completion;
- (void)bjl_setImageWithURLString:(nullable NSString *)urlString
                      placeholder:(nullable UIImage *)placeholder
                       completion:(nullable BJLWebImageCompletionBlock)completion;
- (void)bjl_cancelCurrentImageLoad;

@end

@interface UIButton (BJLWebImage)

- (void)bjl_setImageWithURL:(nullable NSURL *)url
                   forState:(UIControlState)state
                placeholder:(nullable UIImage *)placeholder
                 completion:(nullable BJLWebImageCompletionBlock)completion;
- (void)bjl_setImageWithURLString:(nullable NSString *)urlString
                   forState:(UIControlState)state
                placeholder:(nullable UIImage *)placeholder
                 completion:(nullable BJLWebImageCompletionBlock)completion;
- (void)bjl_cancelCurrentImageLoadForState:(UIControlState)state;

- (void)bjl_setBackgroundImageWithURL:(nullable NSURL *)url
                             forState:(UIControlState)state
                          placeholder:(nullable UIImage *)placeholder
                           completion:(nullable BJLWebImageCompletionBlock)completion;
- (void)bjl_setBackgroundImageWithURLString:(nullable NSString *)urlString
                             forState:(UIControlState)state
                          placeholder:(nullable UIImage *)placeholder
                           completion:(nullable BJLWebImageCompletionBlock)completion;
- (void)bjl_cancelCurrentBackgroundImageLoadForState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
