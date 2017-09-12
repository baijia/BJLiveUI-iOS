//
//  BJLMessageCell.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-02.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <BJLiveCore/BJLMessage.h>
#import "BJLChatUploadingTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLMessageCell : UITableViewCell

@property (nonatomic, readonly) UIImageView *imgView;

@property (nonatomic, copy, nullable) void (^updateConstraintsCallback)(BJLMessageCell * _Nullable cell);
@property (nonatomic, copy, nullable) void (^retryUploadingCallback)(BJLMessageCell * _Nullable cell);

@property (nonatomic, copy, nullable) BOOL (^linkURLCallback)(BJLMessageCell * _Nullable cell, NSURL *url);

- (void)updateWithMessage:(BJLMessage *)message
              placeholder:(nullable UIImage *)placeholder // for BJLMessageType_image+uploaded
            isCurrentUser:(BOOL)isCurrentUser
           tableViewWidth:(CGFloat)tableViewWidth
             isHorizontal:(BOOL)isHorizontal;

- (void)updateWithUploadingTask:(BJLChatUploadingTask *)task
                       fromUser:(BJLUser *)fromUser
                 tableViewWidth:(CGFloat)tableViewWidth
                   isHorizontal:(BOOL)isHorizontal;

+ (NSArray<NSString *> *)allCellIdentifiers;
+ (NSString *)cellIdentifierForMessageType:(BJLMessageType)type;
+ (NSString *)cellIdentifierForUploadingImage;
+ (CGFloat)estimatedRowHeightForMessageType:(BJLMessageType)type;

@end

NS_ASSUME_NONNULL_END
