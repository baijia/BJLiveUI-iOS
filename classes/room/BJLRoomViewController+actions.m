//
//  BJLRoomViewController+actions.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-05-18.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLRoomViewController+protected.h"

NS_ASSUME_NONNULL_BEGIN

@implementation BJLRoomViewController (actions)

- (void)makeActionsOnViewDidLoad {
    bjl_weakify(self);
    
    __block NSInteger tapTimes = 0;
    [self.contentView setToggleTopBarCallback:^(id _Nullable sender) {
        bjl_strongify(self);
        
        if (tapTimes <= 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                tapTimes = 0;
            });
        }
        tapTimes++;
        if (tapTimes == 10) { // NOT >= 10
            [self.room.slideshowViewController tryToReload];
        }
        
        BOOL isHorizontal = BJLIsHorizontalUI(self);
        if (!isHorizontal || self.room.slideshowViewController.drawingEnabled) {
            return;
        }
        
        [self setControlsHidden:!self.controlsHidden animated:NO];
        
        [UIView animateWithDuration:BJLAnimateDurationS animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }];
    [self.contentView setShowMenuCallback:^(id _Nullable sender) {
        bjl_strongify(self);
        [self.previewsViewController showMenuForFullScreenItemSourceView:self.contentView];
    }];
    [self.contentView setClearDrawingCallback:^(id _Nullable sender) {
        bjl_strongify(self);
        [self.room.slideshowViewController clearDrawing];
    }];
    [self.contentView setPageControlCallback:^(id _Nullable sender){
        bjl_strongify(self);
        self.overlayViewController.prefersStatusBarHidden = NO;
        self.overlayViewController.backgroundColor = [UIColor clearColor];
        [self.overlayViewController
         showWithContentViewController:self.pptQuickSlideViewController
         remakeConstraintsBlock:^(MASConstraintMaker *make, UIView *superView, BOOL isHorizontal) {
             bjl_strongify(self);
             if (isHorizontal) {
                 make.left.right.bottom.equalTo(superView);
             }
             else {
                 make.left.right.equalTo(superView);
                 make.top.equalTo(self.contentView.mas_bottom);
             }
             make.height.equalTo(@([self.previewsViewController viewHeightIfDisplay]));
         }];
    }];
    
    [self.controlsViewController setPPTCallback:^(id _Nullable sender) {
        bjl_strongify(self);
        [self.overlayViewController showWithContentViewController:self.pptManageViewController];
    }];
    [self.controlsViewController setHandCallback:^(id _Nullable sender) {
        bjl_strongify(self);
        if (self.room.loginUser.isTeacherOrAssistant) {
            return;
        }
        if (self.room.speakingRequestVM.speakingEnabled) {
            [self.room.speakingRequestVM stopSpeakingRequest];
        }
        else if (self.room.speakingRequestVM.speakingRequestTimeRemaining > 0) {
            [self.room.speakingRequestVM stopSpeakingRequest];
        }
        else {
            if (self.room.featureConfig.disableSpeakingRequest) {
                [self showProgressHUDWithText:self.room.featureConfig.disableSpeakingRequestReason ?: @"举手功能被禁用"];
                return;
            }
            if (self.room.speakingRequestVM.forbidSpeakingRequest) {
                [self showProgressHUDWithText:@"老师设置了禁止举手"];
                return;
            }
            // TODO: MingLQ - sendSpeakingRequest 返回错误注释
            BJLError *error = [self.room.speakingRequestVM sendSpeakingRequest];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            }
            else {
                [self showProgressHUDWithText:@"举手中，等待老师同意"];
            }
        }
    }];
    [self.controlsViewController setPenCallback:^(id _Nullable sender) {
        bjl_strongify(self);
        if (!self.room.loginUser.isTeacherOrAssistant
            && self.room.featureConfig.disableSpeakingRequest) {
            [self showProgressHUDWithText:@"画笔功能被禁用"];
            return;
        }
        
        if (!self.room.slideshowViewController.drawingEnabled) {
            if (!self.room.loginUser.isTeacherOrAssistant
                && !self.room.roomVM.liveStarted) {
                [self showProgressHUDWithText:@"上课状态才能开启画笔"];
                return;
            }
        }
        
        [self.previewsViewController enterFullScreenWithPPTView];
        
        if (!self.room.slideshowViewController.drawingEnabled
            && self.room.slideshowViewController.localPageIndex != self.room.slideshowVM.currentSlidePage.documentPageIndex) {
            [self showProgressHUDWithText:@"PPT 翻页与老师不同步，不能开启画笔"];
            return;
        }
        
        self.room.slideshowViewController.drawingEnabled = !self.room.slideshowViewController.drawingEnabled;
    }];
    [self.controlsViewController setUsersCallback:^(id _Nullable sender) {
        bjl_strongify(self);
        [self.overlayViewController showWithContentViewController:self.onlineUsersViewController];
    }];
    [self.controlsViewController setMoreCallback:^(UIButton * _Nullable button) {
        bjl_strongify(self);
        [self bjl_addChildViewController:self.moreViewController];
        [self.moreViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        [self.moreViewController updateArrowWithRight:button.mas_left bottom:button.mas_top];
        [self.moreViewController setServerRecordingEnabled:self.room.serverRecordingVM.serverRecording];
    }];
    [self.controlsViewController setRotateCallback:^(id _Nullable sender) {
        bjl_strongify(self);
        BOOL isHorizontal = BJLIsHorizontalUI(self);
        if (isHorizontal) {
            [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
        }
        else {
            [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeRight) forKey:@"orientation"];
        }
    }];
    [self.controlsViewController setMicCallback:^(id _Nullable sender) {
        bjl_strongify(self);
        if (!self.room.loginUser.isTeacherOrAssistant
            && self.room.featureConfig.disableSpeakingRequest) {
            [self showProgressHUDWithText:self.room.featureConfig.disableSpeakingRequestReason ?: @"发言功能被禁用"];
            return;
        }
        // TODO: MingLQ - [self setRecordingAudio:recordingVideo:];
        [BJLAuthorization checkMicrophoneAccessAndRequest:YES callback:^(BOOL granted, UIAlertController * _Nullable alert) {
            if (granted) {
                BJLError *error = [self.room.recordingVM setRecordingAudio:!self.room.recordingVM.recordingAudio
                                                            recordingVideo:self.room.recordingVM.recordingVideo];
                if (error) {
                    [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                }
                else {
                    [self showProgressHUDWithText:(self.room.recordingVM.recordingAudio
                                                   ? @"麦克风已打开"
                                                   : @"麦克风已关闭")];
                }
            }
            else if (alert) {
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }];
    [self.controlsViewController setCameraCallback:^(id _Nullable sender) {
        bjl_strongify(self);
        if (!self.room.loginUser.isTeacherOrAssistant
            && self.room.featureConfig.disableSpeakingRequest) {
            [self showProgressHUDWithText:self.room.featureConfig.disableSpeakingRequestReason ?: @"发言功能被禁用"];
            return;
        }
        if (self.room.featureConfig.mediaLimit == BJLMediaLimit_audioOnly) {
            [self showProgressHUDWithText:@"音频课不能打开摄像头"];
            return;
        }
        [BJLAuthorization checkCameraAccessAndRequest:YES callback:^(BOOL granted, UIAlertController * _Nullable alert) {
            if (granted) {
                BJLError *error = [self.room.recordingVM setRecordingAudio:self.room.recordingVM.recordingAudio
                                                            recordingVideo:!self.room.recordingVM.recordingVideo];
                if (error) {
                    [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                }
                else {
                    [self showProgressHUDWithText:(self.room.recordingVM.recordingVideo
                                                   ? @"摄像头已打开"
                                                   : @"摄像头已关闭")];
                }
            }
            else if (alert) {
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }];
    [self.controlsViewController setChatCallback:^(id _Nullable sender) {
        bjl_strongify(self);
        if (!self.room.loginUser.isTeacherOrAssistant
            && (self.room.chatVM.forbidMe || self.room.chatVM.forbidAll)) {
            [self showProgressHUDWithText:@"禁言状态不能发送消息"];
            return;
        }
        UIRectEdge edges = UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom;
        CGSize size = CGSizeZero;
        self.overlayViewController.prefersStatusBarHidden = NO;
        [self.overlayViewController showWithContentViewController:self.chatInputViewController
                                                         horEdges:edges horSize:size
                                                         verEdges:edges verSize:size];
    }];
    
    [self.chatViewController setShowImageViewCallback:^(UIImageView *imageView) {
        bjl_strongify(self);
        if (!imageView.image) {
            return;
        }
        self.imageViewController.view.alpha = 0.0;
        self.imageViewController.imageView.image = imageView.image;
        [self bjl_addChildViewController:self.imageViewController superview:self.view];
        [self.imageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        [self.imageViewController.view setNeedsLayout];
        [self.imageViewController.view layoutIfNeeded];
        [UIView animateWithDuration:BJLAnimateDurationM
                         animations:^{
                             self.imageViewController.view.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             [self setNeedsStatusBarAppearanceUpdate];
                         }];
    }];
    
    [self.recordingStateView bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (!self.room.serverRecordingVM.serverRecording) {
            return;
        }
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"提示"
                                    message:@"正在录课中"
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert bjl_addActionWithTitle:@"结束录课"
                                style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction * _Nonnull action) {
                                  [self.room.serverRecordingVM requestServerRecording:NO];
                              }];
        [alert bjl_addActionWithTitle:@"取消"
                                style:UIAlertActionStyleCancel
                              handler:nil];
        [self presentViewController:alert animated:YES completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.topBarView setExitCallback:^(id _Nonnull sender) {
        bjl_strongify(self);
        [self askToExit];
    }];
    
    [self.overlayViewController setShowCallback:^(id _Nullable sender) {
        bjl_strongify(self);
        [self updateStatusBarAndTopBar];
    }];
    
    [self.overlayViewController setHideCallback:^(id _Nullable sender) {
        bjl_strongify(self);
        [self updateStatusBarAndTopBar];
    }];
    
    [self.loadingViewController setShowCallback:^(BOOL reloading) {
        bjl_strongify(self);
        [self bjl_dismissPresentedViewControllerAnimated:NO completion:nil];
        [self.overlayViewController hide];
        [self.imageViewController hide];
    }];
    [self.loadingViewController setHideCallback:^{
        bjl_strongify(self);
        [self.pptManageViewController startAllUploadingTasks];
    }];
    [self.loadingViewController setHideCallbackWithError:^(BJLError * _Nullable error) {
        bjl_strongify(self);
        [self exit];
    }];
    [self.loadingViewController setExitCallback:^{
        bjl_strongify(self);
        [self askToExit];
    }];
    
    self.showGesture = ({
        UIScreenEdgePanGestureRecognizer *gesture = [UIScreenEdgePanGestureRecognizer bjl_gestureWithHandlerDelegate:self];
        gesture.edges = UIRectEdgeLeft;
        gesture.delegate = self;
        [self.view addGestureRecognizer:gesture];
        gesture;
    });
    self.hideGesture = ({
        UIPanGestureRecognizer *gesture = [UIPanGestureRecognizer bjl_gestureWithHandlerDelegate:self];
        gesture.delegate = self;
        [self.view addGestureRecognizer:gesture];
        gesture;
    });
}

- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated {
    self->_controlsHidden = hidden;
    
    [self updateStatusBarAndTopBar];
    
    BOOL isHorizontal = BJLIsHorizontalUI(self);
    // [self updatePreviewsAndContentConstraintsForHorizontal:isHorizontal];
    [self updateControlsConstraintsForHorizontal:isHorizontal];
    [self updateRecordingStateViewForHorizontal:isHorizontal];
    
    if (animated) {
        [UIView animateWithDuration:BJLAnimateDurationM animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }
    else {
        [self.view layoutIfNeeded];
    }
}

- (void)setChatHidden:(BOOL)hidden animated:(BOOL)animated {
    self->_chatHidden = hidden;
    
    if (!hidden) {
        [self.chatViewController refreshMessages];
    }
    
    BOOL isHorizontal = BJLIsHorizontalUI(self);
    [self updateChatConstraintsForHorizontal:isHorizontal];
    
    if (animated) {
        [UIView animateWithDuration:BJLAnimateDurationM animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }
    else {
        [self.view layoutIfNeeded];
    }
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(__kindof UIGestureRecognizer *)gesture {
    if (gesture == self.showGesture || gesture == self.hideGesture) {
        return !![self bjl_viewIfPanGestureShouldBegin:gesture];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(__kindof UIGestureRecognizer *)gesture
shouldBeRequiredToFailByGestureRecognizer:(__kindof UIGestureRecognizer *)otherGesture {
    if (gesture == self.showGesture && [otherGesture.view isDescendantOfView:gesture.view]) {
        return !![self bjl_viewIfPanGestureShouldBegin:gesture];
    }
    return NO;
}

#pragma mark - <BJLPanGestureRecognizerDelegate>

- (nullable UIView *)bjl_viewIfPanGestureShouldBegin:(__kindof UIPanGestureRecognizer *)gesture {
    BOOL isHorizontal = BJLIsHorizontalUI(self);
    if (!isHorizontal) {
        return nil;
    }
    
    if (!self.overlayViewController.hidden
        || !self.loadingViewController.hidden
        || self.imageViewController.parentViewController) {
        return nil;
    }
    
    if (gesture == self.showGesture) {
        if (self.controlsHidden) {
            return self.controlsViewController.view;
        }
        if (self.chatHidden) {
            return self.chatViewController.view;
        }
        return nil;
    }
    
    if (gesture == self.hideGesture) {
        CGPoint point = [gesture locationInView:self.view];
        UIView *subview = [self.view hitTest:point withEvent:nil];
        if (![subview isDescendantOfView:self.topBarView]
            && ![subview isDescendantOfView:self.controlsViewController.view]
            && ![subview isDescendantOfView:self.chatViewController.view]) {
            return nil;
        }
        if ([subview isDescendantOfView:self.chatViewController.view]
            && !self.chatHidden) {
            return self.chatViewController.view;
        }
        if (!self.controlsHidden && !self.room.slideshowViewController.drawingEnabled) {
            return self.controlsViewController.view;
        }
        return nil;
    }
    
    return nil;
}

- (CGPoint)bjl_panGestureBegan:(__kindof UIPanGestureRecognizer *)gesture view:(UIView *)view {
    BOOL wasHidden = NO;
    MASViewAttribute *superviewLeft = nil;
    
    if (view == self.chatViewController.view) {
        wasHidden = self.chatHidden;
        superviewLeft = self.controlsViewController.view.mas_left;
        [self setChatHidden:NO animated:NO];
    }
    else if (view == self.controlsViewController.view) {
        wasHidden = self.controlsHidden;
        superviewLeft = self.view.mas_left;
        [self setControlsHidden:NO animated:NO];
    }
    else {
        return CGPointZero;
    }
    
    CGPoint origin = CGPointMake(wasHidden ? - CGRectGetWidth(view.frame) : 0.0, 0.0);
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(superviewLeft).offset(origin.x);
    }];
    return origin;
}

- (void)bjl_panGestureChanged:(__kindof UIPanGestureRecognizer *)gesture view:(UIView *)view origin:(CGPoint)origin translation:(CGPoint)translation {
    MASViewAttribute *superviewLeft = nil;
    if (view == self.chatViewController.view) {
        superviewLeft = self.controlsViewController.view.mas_left;
    }
    else if (view == self.controlsViewController.view) {
        superviewLeft = self.view.mas_left;
    }
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat min = - CGRectGetWidth(view.frame), max = 0.0; // (maxOffset > 0): show message time
        CGFloat offset = MIN(MAX(min, origin.x + translation.x), max);
        make.left.equalTo(superviewLeft).offset(offset);
    }];
}

- (void)bjl_panGestureEnded:(__kindof UIPanGestureRecognizer *)gesture view:(UIView *)view origin:(CGPoint)origin direction:(UISwipeGestureRecognizerDirection)direction {
    BOOL wasHidden = origin.x < 0.0;
    BOOL hidden = (wasHidden
                   ? !(direction & UISwipeGestureRecognizerDirectionRight)
                   : (direction & UISwipeGestureRecognizerDirectionLeft));
    
    /* NOTE: animate duration with velocity
     CGFloat movement = (hidden ? - CGRectGetWidth(view.frame) : 0.0) - origin.x;
     NSTimeInterval animateDuration = ABS(movement / velocity.x); // */
    
    if (view == self.chatViewController.view) {
        [self setChatHidden:hidden animated:YES];
    }
    else if (view == self.controlsViewController.view) {
        [self setControlsHidden:hidden animated:YES];
    }
}

- (void)bjl_panGestureCancelled:(__kindof UIPanGestureRecognizer *)gesture view:(UIView *)view origin:(CGPoint)origin {
    BOOL wasHidden = origin.x < 0.0;
    
    if (view == self.chatViewController.view) {
        [self setChatHidden:wasHidden animated:YES];
    }
    else if (view == self.controlsViewController.view) {
        [self setControlsHidden:wasHidden animated:YES];
    }
}

@end

NS_ASSUME_NONNULL_END
