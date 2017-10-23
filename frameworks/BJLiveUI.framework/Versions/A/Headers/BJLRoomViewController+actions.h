//
//  BJLRoomViewController+actions.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-05-18.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLRoomViewController.h"

#import "UIPanGestureRecognizer+BJLViewPanning.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLRoomViewController (actions) <BJLPanGestureRecognizerDelegate>

- (void)makeActionsOnViewDidLoad;

- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
