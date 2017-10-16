//
//  BJLChatViewController+recentMessages.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-02.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLChatViewController+recentMessages.h"

#import <BJLiveCore/BJLMessage.h>

NS_ASSUME_NONNULL_BEGIN

@implementation BJLChatViewController (recentMessages)

- (void)updateReceivingTimeIntervalWithAllMessagesCount:(NSInteger)allMessagesCount {
    NSTimeInterval timeInterval = [NSDate timeIntervalSinceReferenceDate];
    NSNumber *numberValue = @(timeInterval);
    for (NSInteger i = self->_messagesReceivingTimeInterval.count; i < allMessagesCount; i++) {
        [self->_messagesReceivingTimeInterval addObject:numberValue];
    }
    [self updateAlphaForCellsWithAnimationDuration:0.0];
}

- (void)updateAlphaForCellsWithAnimationDuration:(NSTimeInterval)duration {
    for (NSIndexPath *indexPath in self.tableView.indexPathsForVisibleRows) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self updateAlphaForCell:cell atIndexPath:indexPath animationDuration:duration];
    }
}

- (void)updateAlphaForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath animationDuration:(NSTimeInterval)duration {
    CGFloat alpha = [self alphaForCellAtIndex:indexPath.row];
    if (ABS(alpha - cell.alpha) <= CGFLOAT_MIN) {
        return;
    }
    
    if (duration <= CGFLOAT_MIN) {
        cell.alpha = alpha;
    }
    else {
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:(UIViewAnimationOptionAllowUserInteraction
                                     | UIViewAnimationOptionOverrideInheritedOptions
                                     | UIViewAnimationOptionCurveLinear)
                         animations:^{
                             cell.alpha = alpha;
                         }
                         completion:nil];
    }
}

- (CGFloat)alphaForCellAtIndex:(NSUInteger)index {
    if (self->_messagesHighlighting) {
        return self.alphaMax;
    }
    
    CGFloat max = self.alphaMax, min = MIN(self.alphaMin, self.alphaMax);
    CGFloat step = (max - min) / 4;
    
    static const NSInteger positionBoundary = 3, timingBoundary = 3;
    
    CGFloat positionAlpha = max;
    // invertedPosition: 1 ~ self->_messagesReceivingTimeInterval.count
    NSInteger invertedPosition = self->_messagesReceivingTimeInterval.count - index;
    if (invertedPosition > positionBoundary) {
        positionAlpha -= (invertedPosition - positionBoundary) * step;
        positionAlpha = MAX(positionAlpha, min);
    }
    
    CGFloat timingAlpha = max;
    NSTimeInterval timeInterval = ({
        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval received = [[self->_messagesReceivingTimeInterval bjl_objectOrNilAtIndex:index] doubleValue];
        now - received;
    });
    if (timeInterval > timingBoundary) {
        timingAlpha -= (timeInterval - timingBoundary) * step;
        timingAlpha = MAX(timingAlpha, min);
    }
    
    return MIN(positionAlpha, timingAlpha);
}

@end

NS_ASSUME_NONNULL_END
