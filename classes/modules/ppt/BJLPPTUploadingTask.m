//
//  BJLPPTUploadingTask.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-18.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLPPTUploadingTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLPPTUploadingTask ()

@property (nonatomic, readonly, weak) BJLRoom *room;

@end

@implementation BJLPPTUploadingTask

@dynamic result;

+ (instancetype)uploadingTaskWithImageFile:(ICLImageFile *)imageFile room:(BJLRoom *)room {
    NSParameterAssert(room);
    
    BJLPPTUploadingTask *task = [super uploadingTaskWithImageFile:imageFile];
    task->_room = room;
    return task;
}

- (nullable NSURLSessionUploadTask *)uploadImageFile:(NSURL *)fileURL
                                            progress:(nullable void (^)(CGFloat progress))progress
                                              finish:(void (^)(id _Nullable result, BJLError * _Nullable error))finish {
    return [self.room.slideVM uploadImageFile:fileURL
                                     progress:progress
                                       finish:finish];
}

@end

NS_ASSUME_NONNULL_END
