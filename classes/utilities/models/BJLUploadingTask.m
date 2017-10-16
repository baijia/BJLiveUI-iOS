//
//  BJLUploadingTask.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-18.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLUploadingTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLUploadingTask ()

@property (nonatomic, readwrite) ICLImageFile *imageFile;
@property (nonatomic, readwrite, nullable) UIImage *thumbnail;
@property (nonatomic, readwrite) CGSize imageSize;

@property (nonatomic, readwrite) BJLUploadState state;
@property (nonatomic, readwrite) CGFloat progress;

@property (nonatomic, weak, nullable) NSURLSessionUploadTask *uploadTask;
@property (nonatomic) BOOL isCancelled;

@property (nonatomic, readwrite, nullable) id result;
@property (nonatomic, readwrite, nullable) BJLError *error;

@end

@implementation BJLUploadingTask

+ (instancetype)uploadingTaskWithImageFile:(ICLImageFile *)imageFile {
    NSParameterAssert(imageFile);
    
    BJLUploadingTask *uploadingTask = [self new];
    uploadingTask.imageFile = imageFile;
    uploadingTask.thumbnail = imageFile.thumbnail;
    uploadingTask.imageSize = imageFile.imageSize;
    uploadingTask.state = BJLUploadState_waiting;
    return uploadingTask;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.progressStep = 0.05;
    }
    return self;
}

- (void)upload {
    if (self.state != BJLUploadState_waiting) {
        return;
    }
    
    self.isCancelled = NO;
    self.result = nil;
    self.error = nil;
    self.progress = 0.0;
    self.state = BJLUploadState_uploading;
    
    bjl_weakify(self);
    self.uploadTask =
    [self uploadImageFile:[self.imageFile fileURL]
                 progress:^(CGFloat progress) {
                     bjl_strongify(self);
                     if (progress != self.progress
                         && (progress == 0.0
                             || progress == 1.0
                             || ABS(progress - self.progress) >= MAX(0.001, self.progressStep))) {
                             // !!!: MUST be sync
                             bjl_dispatch_sync_main_queue(^{
                                 self.progress = progress;
                             });
                         }
                 }
                   finish:^(id _Nullable result, BJLError * _Nullable error) {
                       bjl_strongify(self);
                       self.uploadTask = nil;
                       if (self.isCancelled) {
                           return;
                       }
                       if (result) {
                           self.result = result;
                           self.state = BJLUploadState_uploaded;
                       }
                       else {
                           self.error = error;
                           self.state = BJLUploadState_waiting;
                       }
                   }];
    
    if (!self.uploadTask) {
        self.error = BJLErrorMake(BJLErrorCode_invalidCalling, nil);
        self.state = BJLUploadState_waiting;
    }
}

- (nullable NSURLSessionUploadTask *)uploadImageFile:(NSURL *)fileURL
                                            progress:(nullable void (^)(CGFloat progress))progress
                                              finish:(void (^)(id _Nullable result, BJLError * _Nullable error))finish {
    return nil;
}

- (void)cancel {
    self.isCancelled = YES;
    
    [self.uploadTask cancel];
    self.uploadTask = nil;
    
    self.result = nil;
    self.error = nil;
    self.progress = 0.0;
    self.state = BJLUploadState_waiting;
}

@end

NS_ASSUME_NONNULL_END
