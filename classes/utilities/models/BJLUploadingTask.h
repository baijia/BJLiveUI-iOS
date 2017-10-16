//
//  BJLUploadingTask.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-18.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BJLiveCore/BJLiveCore.h>
#import "BJL_iCloudLoading.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJLUploadState) {
    BJLUploadState_waiting,
    BJLUploadState_uploading,
    BJLUploadState_uploaded
};

@interface BJLUploadingTask : NSObject

+ (instancetype)uploadingTaskWithImageFile:(ICLImageFile *)imageFile;

@property (nonatomic, readonly) ICLImageFile *imageFile;
@property (nonatomic, readonly, nullable) UIImage *thumbnail;
@property (nonatomic, readonly) CGSize imageSize;

@property (nonatomic, readonly) BJLUploadState state;
@property (nonatomic, readonly) CGFloat progress; // 主线程更新，不会过于频繁
@property (nonatomic) CGFloat progressStep; // default: 0.05, min: 0.001

@property (nonatomic, readonly, nullable) id result; // on uploaded > non-nil
@property (nonatomic, readonly, nullable) BJLError *error;

- (void)upload;
- (void)cancel;

// abstract method, subclasses MUST override and DONOT call super
- (nullable NSURLSessionUploadTask *)uploadImageFile:(NSURL *)fileURL
                                            progress:(nullable void (^)(CGFloat progress))progress
                                              finish:(void (^)(id _Nullable result, BJLError * _Nullable error))finish;

@end

NS_ASSUME_NONNULL_END
