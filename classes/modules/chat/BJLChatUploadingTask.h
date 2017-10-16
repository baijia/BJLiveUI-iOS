//
//  BJLChatUploadingTask.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-18.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLUploadingTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLChatUploadingTask : BJLUploadingTask

@property (nonatomic, readonly, nullable) NSString *result;
@property (nonatomic, readwrite, nullable) BJLError *error;

+ (instancetype)uploadingTaskWithImageFile:(ICLImageFile *)imageFile room:(BJLRoom *)room;

@end

NS_ASSUME_NONNULL_END
