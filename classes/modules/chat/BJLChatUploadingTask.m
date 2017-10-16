//
//  BJLChatUploadingTask.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-18.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLChatUploadingTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLChatUploadingTask ()

@property (nonatomic, readonly, weak) BJLRoom *room;

@end

@implementation BJLChatUploadingTask

@dynamic result, error;

+ (instancetype)uploadingTaskWithImageFile:(ICLImageFile *)imageFile room:(BJLRoom *)room {
    NSParameterAssert(room);
    
    BJLChatUploadingTask *task = [super uploadingTaskWithImageFile:imageFile];
    task->_room = room;
    return task;
}

- (nullable NSURLSessionUploadTask *)uploadImageFile:(NSURL *)fileURL
                                            progress:(nullable void (^)(CGFloat progress))progress
                                              finish:(void (^)(id _Nullable result, BJLError * _Nullable error))finish {
    return [self.room.chatVM uploadImageFile:fileURL progress:progress finish:finish];
}

@end

NS_ASSUME_NONNULL_END
