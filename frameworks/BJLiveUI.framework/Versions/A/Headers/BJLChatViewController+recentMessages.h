//
//  BJLChatViewController+recentMessages.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-02.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLChatViewController () {
@protected
    BOOL _messagesHighlighting;
    NSMutableArray<NSNumber *> *_messagesReceivingTimeInterval;
}

@end

@interface BJLChatViewController (recentMessages)

- (void)updateReceivingTimeIntervalWithAllMessagesCount:(NSInteger)allMessagesCount;

- (void)updateAlphaForCellsWithAnimationDuration:(NSTimeInterval)duration;
- (void)updateAlphaForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath animationDuration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
