//
//  BJLRoomViewController+protected.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-01-19.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLAuthorization.h>

#import "BJLViewControllerImports.h"
#import "BJLRoomViewController.h"
#import "BJLRoomViewController+constraints.h"
#import "BJLRoomViewController+actions.h"
#import "BJLRoomViewController+observing.h"

#import "BJLContentView.h"
#import "BJLPreviewsViewController.h"
#import "BJLControlsViewController.h"
#import "BJLChatViewController.h"
#import "BJLTopBarView.h"

#import "BJLUsersViewController.h"
#import "BJLPPTManageViewController.h"
#import "BJLPPTQuickSlideViewController.h"
#import "BJLChatInputViewController.h"
#import "BJLMoreViewController.h"
#import "BJLNoticeViewController.h"
#import "BJLNoticeEditViewController.h"
#import "BJLSettingsViewController.h"

#import "BJLImageViewController.h"
#import "BJLOverlayViewController.h"
#import "BJLLoadingViewController.h"

#import "BJLQuizWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @see /wiki/design.md
 */
@interface BJLRoomViewController () {
    BOOL _chatHidden, _controlsHidden;
}

@property (nonatomic, readonly) BJLContentView *contentView;
@property (nonatomic, readonly) UIView *backgroundView;
@property (nonatomic, readonly) BJLPreviewsViewController *previewsViewController;
@property (nonatomic, readonly) BJLControlsViewController *controlsViewController; // with chatVC and buttonsVC
@property (nonatomic, readonly) BJLChatInputViewController *chatInputViewController;
@property (nonatomic, readonly) UIButton *recordingStateView;
@property (nonatomic, readonly) BJLTopBarView *topBarView;

@property (nonatomic, readonly) BJLUsersViewController *onlineUsersViewController;
@property (nonatomic, readonly) BJLPPTManageViewController *pptManageViewController;
@property (nonatomic, readonly) BJLPPTQuickSlideViewController *pptQuickSlideViewController;
@property (nonatomic, readonly) BJLChatViewController *chatViewController;
@property (nonatomic, readonly) BJLMoreViewController *moreViewController;
@property (nonatomic, readonly) BJLNoticeViewController *noticeViewController;
@property (nonatomic, readonly) BJLNoticeEditViewController *noticeEditViewController;
@property (nonatomic, readonly) BJLSettingsViewController *settingsViewController;

@property (nonatomic, readonly) BJLImageViewController *imageViewController;
@property (nonatomic, readonly) BJLOverlayViewController *overlayViewController;
@property (nonatomic, readonly) BJLLoadingViewController *loadingViewController;

@property (nonatomic, nullable) BJLQuizWebViewController *quizWebViewController;

@property (nonatomic, readonly) BOOL chatHidden, controlsHidden; // NON-KVO
@property (nonatomic) BOOL contentAnimating;
@property (nonatomic) BOOL didUpdateVideoPlayingUser;
@property (nonatomic) UIScreenEdgePanGestureRecognizer *showGesture;
@property (nonatomic) UIPanGestureRecognizer *hideGesture;

- (void)showProgressHUDWithText:(NSString *)text;
- (void)askToExit;

@end

NS_ASSUME_NONNULL_END
