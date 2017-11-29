//
//  BJLRoomViewController+constraints.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-05-18.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLRoomViewController+protected.h"

NS_ASSUME_NONNULL_BEGIN

static const CGFloat chatViewWidth = 260.0;

@implementation BJLRoomViewController (constraints)

- (void)updateConstraintsForHorizontal:(BOOL)isHorizontal {
    self.chatViewController.alphaMin = isHorizontal ? 0.2 : 0.8;
    
    // degbug
    MASAttachKeys(self.view,
                  self.topBarView,
                  self.previewsViewController.view,
                  self.contentView,
                  self.controlsViewController.view,
                  self.chatViewController.view,
                  self.recordingStateView,
                  self.overlayViewController.view,
                  self.loadingViewController.view);
    
    // clean all constraints at first to fix warnings
    [@[// !!!: NO self.view
       self.topBarView,
       self.previewsViewController.view,
       self.contentView,
       self.backgroundView,
       self.controlsViewController.view,
       self.chatViewController.view,
       self.recordingStateView,
       self.overlayViewController.view,
       self.loadingViewController.view]
     mas_remakeConstraints:^(MASConstraintMaker *make) {}];
    
    CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    [self.topBarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.height.equalTo(@(statusBarHeight));
        make.left.right.equalTo(self.controlsViewController.view);
    }];
    [self updateStatusBarAndTopBar];
    
    [self updatePreviewsAndContentConstraintsForHorizontal:isHorizontal];
    
    [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [self updateControlsConstraintsForHorizontal:isHorizontal];
    
    [self.recordingStateView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.bjl_safeAreaLayoutGuide ?: self.contentView).with.offset(- BJLViewSpaceM);
        // TODO: 对其到画笔清除按钮
        CGFloat offset = - BJLViewSpaceM - (BJLButtonSizeM - BJLButtonSizeS) / 2;
        make.bottom.equalTo(self.contentView).with.offset(offset);
    }];
    [self updateRecordingStateViewForHorizontal:isHorizontal];
    
    [self.overlayViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.loadingViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)updateStatusBarAndTopBar {
    [self setNeedsStatusBarAppearanceUpdate];
    self.topBarView.hidden = self.controlsHidden;
    self.topBarView.backgroundView.hidden = [UIApplication sharedApplication].statusBarHidden;
}

- (void)updateRecordingStateViewForHorizontal:(BOOL)isHorizontal {
    self.recordingStateView.hidden = (!self.room.loginUser.isTeacher
                                      || !self.room.serverRecordingVM.serverRecording
                                      || (isHorizontal && !(self.controlsHidden || self.room.slideshowViewController.drawingEnabled)));
}

- (void)updatePreviewsAndContentConstraintsForHorizontal:(BOOL)isHorizontal {
    BOOL showBackgroundView = (self.previewsViewController.numberOfItems > 0
                               && (!isHorizontal || self.previewsViewController.numberOfItems > 2)
                               && !self.previewBackgroundImageHidden);
    self.previewsViewController.backgroundView.hidden = !showBackgroundView;
    
    [self.previewsViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(isHorizontal ? self.view : self.contentView.mas_bottom);
        [self.previewsViewController makeContentSize:make forHorizontal:isHorizontal];
    }];
    
    __block UIEdgeInsets insets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        if (bjl_iPhoneX()) {
            insets = self.view.safeAreaInsets;
            if (isHorizontal) {
                insets.top = insets.bottom = 0.0;
                // 内容紧贴刘海
                insets.left = MAX(0.0, insets.left - BJLiPhoneXInsetsAdjustment);
                insets.right = MAX(0.0, insets.right - BJLiPhoneXInsetsAdjustment);
            }
            /*
            else {
                // 内容紧贴刘海
                insets.top = MAX(0.0, insets.top - BJLiPhoneXInsetsAdjustment);
            } */
        }
    }
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isHorizontal) {
            make.left.right.bottom.equalTo(self.view).insets(insets);
            BOOL showPreviewsInline = (isHorizontal && self.previewsViewController.numberOfItems <= 2);
            make.top.equalTo(showPreviewsInline ? self.view : self.previewsViewController.view.mas_bottom);
        }
        else {
            make.left.right.top.equalTo(self.view).insets(insets);
            // !!!: .priorityHigh() - fix warnings during ver to hor
            make.height.equalTo(self.contentView.mas_width).multipliedBy(3.0 / 4).priorityHigh();
        }
    }];
    
    [self updateChatConstraintsForHorizontal:isHorizontal];
}

- (void)updateControlsConstraintsForHorizontal:(BOOL)isHorizontal {
    __block UIEdgeInsets insets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        if (bjl_iPhoneX()) {
            insets = self.view.safeAreaInsets;
            if (isHorizontal) {
                insets.top = insets.bottom = 0.0;
                // 内容紧贴刘海
                insets.left = MAX(0.0, insets.left - BJLiPhoneXInsetsAdjustment);
                insets.right = MAX(0.0, insets.right - BJLiPhoneXInsetsAdjustment);
            }
            /*
            else {
                // 内容紧贴刘海
                insets.bottom = MAX(0.0, insets.bottom - BJLViewSpaceM * 2);
            }
            */
        }
    }
    
    [self.controlsViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        // !!!: .priorityHigh() - fix warnings during ver to hor
        make.top.equalTo(self.previewsViewController.view.mas_bottom).priorityHigh();
        if (isHorizontal) {
            MASConstraint *xAxisAnchor = (self.controlsHidden ? make.right : make.left);
            xAxisAnchor.equalTo(self.view.mas_left).with.offset(self.controlsHidden ? 0.0 : insets.left); // maybe update
            // !!!: 为了可以水平拖动，这里是 width 而不是 right
            make.top.bottom.equalTo(self.view).insets(insets);
            make.width.equalTo(self.view).sizeOffset(CGSizeMake(- (insets.left + insets.right), 0.0));
        }
        else {
            make.left.right.bottom.equalTo(self.view).insets(insets);
        }
    }];
}

- (void)updateChatConstraintsForHorizontal:(BOOL)isHorizontal {
    [self.chatViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        MASConstraint *horAlignment;
        CGFloat leftOffset = 0.0;
        if (isHorizontal) {
            if (self.chatHidden) {
                horAlignment = make.right;
                leftOffset = -self.controlsViewController.view.frame.origin.x;
            }
            else {
                horAlignment = make.left;
            }
        }
        else {
            horAlignment = make.left;
        }
        horAlignment.equalTo(self.controlsViewController.view.mas_left).with.offset(leftOffset); // maybe update
        make.right.lessThanOrEqualTo(self.controlsViewController.rightLayoutGuide).with.offset(- BJLViewSpaceM).priorityHigh();
        make.top.equalTo(self.previewsViewController.view.mas_bottom);
        make.bottom.equalTo(self.controlsViewController.bottomLayoutGuide);
        make.width.equalTo(@(chatViewWidth));
    }];
    
    self.chatViewController.view.hidden = isHorizontal && self.room.slideshowViewController.drawingEnabled;
}

@end

NS_ASSUME_NONNULL_END
