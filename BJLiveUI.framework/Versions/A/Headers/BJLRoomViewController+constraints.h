//
//  BJLRoomViewController+constraints.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-05-18.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import "BJLRoomViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLRoomViewController (constraints)

- (void)updateConstraintsForHorizontal:(BOOL)isHorizontal;
- (void)updateTopBarConstraintsForHorizontal:(BOOL)isHorizontal;
- (void)updateTapBarRelatedConstraintsForHorizontal:(BOOL)isHorizontal;
- (void)updateControlsConstraintsForHorizontal:(BOOL)isHorizontal;
- (void)updateChatConstraintsForHorizontal:(BOOL)isHorizontal;

@end

NS_ASSUME_NONNULL_END
