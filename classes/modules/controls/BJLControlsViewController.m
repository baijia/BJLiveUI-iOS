//
//  BJLControlsViewController.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-15.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLHitTestView.h>

#import "BJLControlsViewController.h"

#import "BJLAnnularProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLControlsViewController ()

@property (nonatomic, readonly, weak) BJLRoom *room;

@property (nonatomic) UIView *rightToolBar, *bottomToolBar;

@property (nonatomic) UIButton *pptButton, *handButton, *penButton, *usersButton;
@property (nonatomic) BJLAnnularProgressView *handProgressView;

@property (nonatomic) UIButton *micButton, *cameraButton, *rotateButton, *moreButton;

@property (nonatomic) UIButton *chatButton;

@end

@implementation BJLControlsViewController

#pragma mark - lifecycle & <BJLRoomChildViewController>

- (instancetype)initWithRoom:(BJLRoom *)room {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self->_room = room;
    }
    return self;
}

- (void)loadView {
    bjl_weakify(self);
    self.view = [BJLHitTestView viewWithFrame:[UIScreen mainScreen].bounds hitTestBlock:^UIView * _Nullable(UIView * _Nullable hitView, CGPoint point, UIEvent * _Nullable event) {
        bjl_strongify(self);
        
        NSArray *containerViews = @[self.view, self.rightToolBar, self.bottomToolBar];
        
        // 非 container-view 才响应点击事件
        if (![containerViews containsObject:hitView]) {
            return hitView;
        }
        
        // 避免按钮禁用状态下点击穿透到 contentView，导致 controls 被隐藏
        // @see https://stackoverflow.com/a/40786920/456536
        for (UIView *superview in containerViews) {
            for (UIView *subview in superview.subviews) {
                UIControl *control = bjl_cast(UIControl, subview);
                CGPoint pointInControl = [self.view convertPoint:point toView:control];
                if (control && !control.enabled && [control pointInside:pointInControl withEvent:event]) {
                    return self.view; // !!!: self.view.userInteractionEnabled = YES;
                }
            }
        }
        
        return nil;
    }];
    
    self.view.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeSubviews];
    [self makeConstraints];
    
    [self updateButtonStates];
    
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room, vmsAvailable)
           filter:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
               // bjl_strongify(self);
               return now.boolValue;
           }
         observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             [self updateRightToolBarButtons];
             [self updateButtonStates];
             [self makeObserving];
             return YES;
         }];
    [self bjl_observe:BJLMakeMethod(self.room, enterRoomSuccess)
             observer:^BOOL {
                 bjl_strongify(self);
                 [self updateButtonStates];
                 return YES;
             }];
    
    [self makeActions];
}

// NOTE: trigger by [self.view setNeedsUpdateConstraints];
- (void)updateViewConstraints {
    [self updateButtonStates];
    [super updateViewConstraints];
}

#pragma mark - <UIContentContainer>

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    NSLog(@"%@ willTransitionToSizeClasses: %td-%td",
          NSStringFromClass([self class]), newCollection.horizontalSizeClass, newCollection.verticalSizeClass);
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        // @see - [self updateViewConstraints]
        [self.view setNeedsUpdateConstraints];
    } completion:nil];
}

#pragma mark - makeSubviews

- (void)makeSubviews {
    self.rightToolBar = ({
        UIView *view = [UIView new];
        [self.view addSubview:view];
        view;
    });
    
    self.bottomToolBar = ({
        UIView *view = [UIView new];
        [self.view addSubview:view];
        view;
    });
    
    self.pptButton = [self makeButtonWithIconName:@"bjl_ic_ppt"
                                 selectedIconName:nil
                                             size:BJLButtonSizeL
                                        superview:nil]; // add to self.rightToolBar later
    
    self.handButton = [self makeButtonWithIconName:@"bjl_ic_handup"
                                  selectedIconName:@"bjl_ic_handup_on"
                                              size:BJLButtonSizeL
                                         superview:nil]; // add to self.rightToolBar later
    
    self.handProgressView = ({
        BJLAnnularProgressView *progressView = [BJLAnnularProgressView new];
        progressView.size = BJLButtonSizeL;
        progressView.annularWidth = 2.0;
        progressView.color = [UIColor bjl_blueBrandColor];
        progressView.userInteractionEnabled = NO;
        [self.handButton addSubview:progressView];
        [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.handButton);
        }];
        progressView;
    });
    
    self.penButton = [self makeButtonWithIconName:@"bjl_ic_lightpen"
                                 selectedIconName:@"bjl_ic_lightpen_on"
                                             size:BJLButtonSizeL
                                        superview:nil]; // add to self.rightToolBar later
    
    self.usersButton = [self makeButtonWithIconName:@"bjl_ic_users"
                                   selectedIconName:nil
                                               size:BJLButtonSizeL
                                          superview:nil]; // add to self.rightToolBar later
    
    self.micButton = [self makeButtonWithIconName:@"bjl_ic_stopaudio_closed"
                                 selectedIconName:nil
                                             size:BJLButtonSizeM
                                        superview:self.bottomToolBar];
    
    self.cameraButton = [self makeButtonWithIconName:@"bjl_ic_stopvideo_closed"
                                    selectedIconName:@"bjl_ic_stopvideo_open"
                                                size:BJLButtonSizeM
                                           superview:self.bottomToolBar];
    
    self.rotateButton = [self makeButtonWithIconName:@"bjl_ic_rotate" // 竖屏时 normal，点击切到横屏
                                    selectedIconName:@"bjl_ic_rotate" // 横屏时 selected，点击切到竖屏
                                                size:BJLButtonSizeM
                                           superview:self.bottomToolBar];
    
    self.moreButton = [self makeButtonWithIconName:@"bjl_ic_more"
                                  selectedIconName:nil
                                              size:BJLButtonSizeM
                                         superview:self.bottomToolBar];
    
    self.chatButton = [self makeButtonWithIconName:@"bjl_ic_sentmsg"
                                  selectedIconName:nil
                                              size:BJLButtonSizeM
                                         superview:self.bottomToolBar];
}

- (UIButton *)makeButtonWithIconName:(nullable NSString *)iconName
                    selectedIconName:(nullable NSString *)selectedIconName
                                size:(CGFloat)size
                           superview:(nullable UIView *)superview {
    UIButton *button = [UIButton new];
    if (iconName) {
        [button setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
        /*
        if (selectedImage) {
            [button setImage:selectedImage forState:UIControlStateNormal | UIControlStateHighlighted];
        } */
        if (selectedIconName) {
            UIImage *selectedImage = [UIImage imageNamed:selectedIconName];
            [button setImage:selectedImage forState:UIControlStateSelected];
            [button setImage:selectedImage forState:UIControlStateSelected | UIControlStateHighlighted];
        }
    }
    
    button.layer.cornerRadius = size / 2;
    button.layer.masksToBounds = YES;
    
    [superview addSubview:button];
    
    return button;
}

- (void)updateRightToolBarButtons {
    if (!self.room.loginUser) {
        return;
    }
    
    NSArray<UIButton *> *buttons;
    if (self.room.loginUser.isTeacherOrAssistant) {
        buttons = @[self.penButton, self.pptButton, self.usersButton];
    }
    else if (self.room.roomInfo.roomType != BJLRoomType_1toN) {
        buttons = @[self.penButton, self.usersButton];
    }
    else {
        // self.room.speakingRequestVM.speakingEnabled || NOT
        buttons = @[self.penButton, self.handButton, self.usersButton];
    }
    
    [self.rightToolBar.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIButton *last = nil;
    for (UIButton *button in buttons) {
        [self.rightToolBar addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(last.mas_bottom ?: self.rightToolBar).with.offset(last ? BJLViewSpaceM : 0.0);
            make.left.right.equalTo(self.rightToolBar);
            make.width.height.equalTo(@(BJLButtonSizeL));
        }];
        last = button;
    }
    [last mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.rightToolBar);
    }];
}

- (void)updateMicButtonSelectedIconWithInputVolumeLevel:(CGFloat)inputVolumeLevel {
    if (!self.micButton.selected) {
        return;
    }
    
    bjl_returnIfRobot(0.2);
    
    NSArray<NSString *> * const imageNames = @[@"bjl_ic_stopaudio_1",
                                               @"bjl_ic_stopaudio_2",
                                               @"bjl_ic_stopaudio_3",
                                               @"bjl_ic_stopaudio_4",
                                               @"bjl_ic_stopaudio_5",
                                               @"bjl_ic_stopaudio_6"];
    NSInteger imageIndex = round(imageNames.count * inputVolumeLevel);
    NSString *imageName = [imageNames bjl_objectOrNilAtIndex:imageIndex] ?: imageNames.firstObject;
    UIImage *image = [UIImage imageNamed:imageName];
    [self.micButton setImage:image forState:UIControlStateSelected];
    [self.micButton setImage:image forState:UIControlStateSelected | UIControlStateHighlighted];
}

#pragma mark - makeConstraints

- (void)makeConstraints {
    [self.rightToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).inset(BJLViewSpaceM);
        // 纵向居中时【不能】从 bottomToolBar 顶部算起，因为竖屏时上边有发言列表、横屏时上边有退出按钮
        make.centerY.equalTo(self.view);
    }];
    [self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view).inset(BJLViewSpaceM);
        make.height.equalTo(@(BJLButtonSizeM));
    }];
    
    UIButton *last = nil;
    NSArray<UIButton *> *buttons = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
                                    ? @[self.moreButton/* , self.rotateButton */, self.cameraButton, self.micButton]
                                    : @[self.moreButton, self.rotateButton, self.cameraButton, self.micButton]);
    for (UIButton *button in buttons) {
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(last.mas_left ?: self.bottomToolBar).with.offset(last ? - BJLViewSpaceM : 0.0);
            make.centerY.equalTo(self.bottomToolBar);
            make.width.height.equalTo(@(BJLButtonSizeM));
        }];
        last = button;
    }
    
    [self.chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(self.bottomToolBar);
        make.width.height.equalTo(@(BJLButtonSizeM));
    }];
}

#pragma mark - makeObserving

- (void)makeObserving {
    bjl_weakify(self);
    
    BJLPropertyFilter ifIntegerChanged = ^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
        // bjl_strongify(self);
        return now.integerValue != old.integerValue;
    };
    
    [self bjl_kvo:BJLMakeProperty(self.room.speakingRequestVM, speakingRequestTimeRemaining)
          options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
           filter:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable timeRemaining) {
               // bjl_strongify(self);
               return timeRemaining.doubleValue != old.doubleValue;
           }
         observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable timeRemaining) {
             bjl_strongify(self);
             if (timeRemaining.doubleValue <= 0.0) {
                 self.handProgressView.progress = 0.0;
             }
             else {
                 CGFloat progress = timeRemaining.doubleValue / self.room.speakingRequestVM.speakingRequestTimeoutInterval; // 1.0 ~ 0.0
                 self.handProgressView.progress = progress;
             }
             return YES;
         }];
    
    [self bjl_kvo:BJLMakeProperty(self.room.speakingRequestVM, speakingEnabled)
          options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
           filter:ifIntegerChanged
         observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             [self updateButtonStates];
             return YES;
         }];
    
    [self bjl_kvo:BJLMakeProperty(self.room.slideshowViewController, drawingEnabled)
          options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
           filter:ifIntegerChanged
         observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             [self updateButtonStates];
             return YES;
         }];
    
    [self bjl_kvo:BJLMakeProperty(self.room.playingVM, playingUsers)
          options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
           filter:^BOOL(NSArray<BJLUser *> * _Nullable old, NSArray<BJLUser *> * _Nullable now) {
               // bjl_strongify(self);
               return now != old;
           }
         observer:^BOOL(NSArray<BJLUser *> * _Nullable old, NSArray<BJLUser *> * _Nullable now) {
             bjl_strongify(self);
             if (now.count > 0 != old.count > 0) {
                 [self updateButtonStates];
             }
             return YES;
         }];
    
    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, recordingAudio)
          options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
           filter:ifIntegerChanged
         observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             self.micButton.selected = self.room.recordingVM.recordingAudio;
             if (self.micButton.selected) {
                 [self updateMicButtonSelectedIconWithInputVolumeLevel:1.0];
             }
             return YES;
         }];
    
    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, inputVolumeLevel)
          options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
           filter:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
               return ABS(round(old.doubleValue * 10) - round(now.doubleValue * 10)) >= 1.0;
           }
         observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             [self updateMicButtonSelectedIconWithInputVolumeLevel:now.doubleValue];
             return YES;
         }];
    
    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, recordingVideo)
          options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
           filter:ifIntegerChanged
         observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             self.cameraButton.selected = self.room.recordingVM.recordingVideo;
             return YES;
         }];
}

- (void)updateButtonStates {
    BOOL isHorizontal = BJLIsHorizontalUI(self);
    
    // loading == before loading + loading + after exit
    BOOL loading = self.room.loadingVM || !self.room.vmsAvailable;
    
    BOOL isTeacherOrAssistant = self.room.loginUser.isTeacherOrAssistant;
    
    BOOL not1toN = self.room.roomInfo.roomType != BJLRoomType_1toN;
    BOOL speakingEnabled = (self.room.speakingRequestVM.speakingEnabled || not1toN);
    BOOL drawingEnabled = self.room.slideshowViewController.drawingEnabled;
    
    BOOL penOnly = isHorizontal && drawingEnabled;
    
    BOOL hideUserList = self.room.featureConfig.hideUserList && !isTeacherOrAssistant;
    
    /* right */
    
    self.pptButton.hidden = loading || penOnly || !isTeacherOrAssistant;
    
    self.handButton.hidden = loading || penOnly || isTeacherOrAssistant || not1toN;
    self.handButton.selected = !isTeacherOrAssistant && speakingEnabled;
    
    self.penButton.hidden = loading || !(isTeacherOrAssistant || speakingEnabled);
    self.penButton.selected = drawingEnabled;
    
    self.usersButton.hidden = loading || penOnly || hideUserList;
    
    /* right bottom */
    
    self.moreButton.hidden = loading || penOnly;
    
    self.rotateButton.hidden = loading || penOnly;
    // 解决旋转动画过程中更改 button 状态无效的问题
    bjl_dispatch_async_main_queue(^{
        self.rotateButton.selected = isHorizontal;
    });
    
    self.micButton.hidden = loading || penOnly || !(isTeacherOrAssistant || speakingEnabled);
    self.micButton.selected = self.room.recordingVM.recordingAudio;
    
    self.cameraButton.hidden = loading || penOnly || !(isTeacherOrAssistant || speakingEnabled);
    self.cameraButton.selected = self.room.recordingVM.recordingVideo;
    
    /* left bottom */
    
    self.chatButton.hidden = loading || penOnly;
}

#pragma mark - makeActions

- (void)makeActions {
    bjl_weakify(self);
    
    [self.pptButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.pptCallback) self.pptCallback(sender);
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.handButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        [sender bjl_disableForSeconds:BJLRobotDelayS];
        if (self.handCallback) self.handCallback(sender);
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.penButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.penCallback) self.penCallback(sender);
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.usersButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.usersCallback) self.usersCallback(sender);
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.moreButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.moreCallback) self.moreCallback(sender);
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.rotateButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.rotateCallback) self.rotateCallback(sender);
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.micButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        [sender bjl_disableForSeconds:BJLRobotDelayS];
        if (self.micCallback) self.micCallback(sender);
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.cameraButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        [sender bjl_disableForSeconds:BJLRobotDelayS];
        if (self.cameraCallback) self.cameraCallback(sender);
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.chatButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.chatCallback) self.chatCallback(sender);
    } forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - public

- (MASViewAttribute *)rightLayoutGuide {
    if (!self.isViewLoaded) {
        [self view];
    }
    return self.rightToolBar.mas_left;
}

- (MASViewAttribute *)bottomLayoutGuide {
    if (!self.isViewLoaded) {
        [self view];
    }
    return self.bottomToolBar.mas_top;
}

@end

NS_ASSUME_NONNULL_END
