//
//  BJLPPTUploadingTask.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-18.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLUploadingTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLPPTUploadingTask : BJLUploadingTask

@property (nonatomic, readonly, nullable) BJLDocument *result;

+ (instancetype)uploadingTaskWithImageFile:(ICLImageFile *)imageFile room:(BJLRoom *)room;

@end

NS_ASSUME_NONNULL_END
