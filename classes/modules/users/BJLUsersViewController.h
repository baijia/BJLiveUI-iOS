//
//  BJLUsersViewController.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-13.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLViewControllerImports.h"

#import "BJLUserCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, BJLUserStateMask) {
    BJLUserStateMask_request    = 1 << BJLUserState_request,
    BJLUserStateMask_speaking   = 1 << BJLUserState_speaking,
    BJLUserStateMask_online     = 1 << BJLUserState_online,
    BJLUserStateMask_all        = NSIntegerMax
};

@interface BJLUsersViewController : BJLTableViewController <
UITableViewDataSource,
UITableViewDelegate,
BJLRoomChildViewController>

@property (nonatomic, readonly) BJLUserStateMask userStates;

- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
- (instancetype)initWithRoom:(BJLRoom *)room NS_UNAVAILABLE; // use `initWithRoom:userStates:` instead
- (instancetype)initWithRoom:(BJLRoom *)room userStates:(BJLUserStateMask)userStates NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, nullable) void (^updateVideoPlayingUserCallback)(BOOL isTeacher, BOOL videoOn);

@end

NS_ASSUME_NONNULL_END
