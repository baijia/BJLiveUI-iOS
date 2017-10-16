//
//  BJLRoomViewController.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-01-17.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import <BJLiveBase/BJL_EXTScope.h>
#import <BJLiveBase/BJLUserAgent.h>

#import <BJLiveCore/BJLiveCore.h>


#import "BJLRoomViewController.h"
#import "BJLRoomViewController+protected.h"

#import "BJLiveUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLRoomViewController ()

@property (nonatomic) CGRect keyboardFrame;

@property (nonatomic, nullable) AFNetworkReachabilityManager *reachability;
@property (nonatomic, nullable) BJLProgressHUD *prevHUD;

@end

@implementation BJLRoomViewController {
    BOOL _entered;
}

+ (void)load {
    [[BJLUserAgent defaultInstance] regitsterSDK:BJLiveUIName() version:BJLiveUIVersion()];
}

#pragma mark - lifecycle & <BJLRoomChildViewController>

- (instancetype)initWithRoom:(BJLRoom *)room {
    NSParameterAssert(room);
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self->_room = room;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor bjl_darkGrayTextColor];
    
    [self makeViewControllersOnViewDidLoad];
    [self makeActionsOnViewDidLoad];
    [self makeRoomObserving];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /* 第一次 `viewDidAppear:` 时进入教室、而不是 `viewDidLoad`，因为要避免
     在创建 `BJLRoomViewController` 实例后、如果触发 `viewDidLoad` 但没有立即展示；
     然后 `viewDidLoad` 中调用 `enter`，进教室过程中可能需要弹出提示；
     但在 `viewDidAppear:` 之前弹出的提示无法显示，并在终端打印警告。
     Warning: Attempt to present <UIAlertController> on <BJLRoomViewController> whose view
     is not in the window hierarchy!
     */
    if (!_entered) {
        _entered = YES;
        [self.room enter];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHideWithNotification:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrameWithNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}

// NOTE: trigger by [self.view setNeedsUpdateConstraints];
- (void)updateViewConstraints {
    BOOL isHorizontal = BJLIsHorizontalUI(self);
    if (!isHorizontal) {
        // controls: 切到竖屏不再隐藏、并且再切回横屏依然显示
        [self setControlsHidden:NO animated:NO]; // TODO: 这里开动画会引起进教室时 self.backgroundView 动画异常
    }
    [self updateConstraintsForHorizontal:isHorizontal];
    [super updateViewConstraints];
}

- (void)dealloc {
    [self clean];
    
    // [NSObject cancelPreviousPerformRequestsWithTarget:self];
    // [[NSNotificationCenter defaultCenter] removeObserver:self];
    // [self bjl_stopAllKeyValueObserving];
    [self bjl_stopAllMethodArgumentsObserving];
}

#pragma mark - UIViewController

// NOTE: trigger by [self setNeedsStatusBarAppearanceUpdate];

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    BOOL isHorizontal = BJLIsHorizontalUI(self);
    return (self.imageViewController.parentViewController
            || self.room.slideshowViewController.drawingEnabled
            || (!self.overlayViewController.hidden && self.overlayViewController.prefersStatusBarHidden)
            || (isHorizontal && (self.controlsHidden)));
    // TODO: self.overlayViewController.prefersStatusBarHidden 支持由 contentViewController 设置，要区分横竖屏？
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return self.overlayViewController.hidden ? nil : self.overlayViewController;
}

- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return self.overlayViewController.hidden ? nil : self.overlayViewController;
}

// NOTE: trigger by [self setNeedsUpdateOfHomeIndicatorAutoHidden];

- (BOOL)prefersHomeIndicatorAutoHidden {
    BOOL isHorizontal = BJLIsHorizontalUI(self);
    return isHorizontal;
}

#pragma mark - UIViewControllerRotation

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return (self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone
            ? UIInterfaceOrientationMaskAllButUpsideDown
            : UIInterfaceOrientationMaskAll);
}

#pragma mark - <UIContentContainer>

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSLog(@"%@ viewWillTransitionToSize: %@",
          NSStringFromClass([self class]), NSStringFromCGSize(size));
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    NSLog(@"%@ willTransitionToSizeClasses: %td-%td",
          NSStringFromClass([self class]), newCollection.horizontalSizeClass, newCollection.verticalSizeClass);
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        [self setNeedsStatusBarAppearanceUpdate];
        if (@available(iOS 11.0, *)) {
            [self setNeedsUpdateOfHomeIndicatorAutoHidden];
        }
        [self.view setNeedsUpdateConstraints];
    } completion:nil];
}

#pragma mark - events

- (void)makeRoomObserving {
    // [self bjl_stopAllMethodArgumentsObservingOfTarget:self.room];
    
    bjl_weakify(self);
    
    [self bjl_observe:BJLMakeMethod(self.room, enterRoomSuccess)
             observer:^BOOL {
                 bjl_strongify(self);
                 
                 if (self.room.loginUser.isTeacher
                     && !self.room.roomVM.liveStarted) {
                     [self.room.roomVM sendLiveStarted:YES]; // 进入教室上课
                 }
                 
                 [self.room.recordingVM setVideoBeautifyLevel:BJLVideoBeautifyLevel_off];
                 
                 [self roomViewControllerEnterRoomSuccess:self];
                 
                 self.reachability = ({
                     __block BOOL isFirstTime = YES;
                     AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager manager];
                     [reachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                         bjl_strongify(self);
                         if (status != AFNetworkReachabilityStatusReachableViaWWAN) {
                             return;
                         }
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             if (status != AFNetworkReachabilityStatusReachableViaWWAN) {
                                 return;
                             }
                             if (isFirstTime) {
                                 isFirstTime = NO;
                                 UIAlertController *alert = [UIAlertController
                                                             alertControllerWithTitle:@"提示"
                                                             message:@"正在使用3G/4G网络，可手动关闭视频以减少流量消耗"
                                                             preferredStyle:UIAlertControllerStyleAlert];
                                 [alert bjl_addActionWithTitle:@"知道了"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
                                 [self presentViewController:alert animated:YES completion:nil];
                             }
                             else {
                                 [self showProgressHUDWithText:@"正在使用3G/4G网络"];
                             }
                         });
                     }];
                     [reachability startMonitoring];
                     reachability;
                 });
                 
                 return YES;
             }];
    
    [self bjl_observe:BJLMakeMethod(self.room, enterRoomFailureWithError:)
             observer:^BOOL(BJLError *error) {
                 bjl_strongify(self);
                 [self roomViewController:self enterRoomFailureWithError:error];
                 return YES;
             }];
    
    [self bjl_observe:BJLMakeMethod(self.room, roomWillExitWithError:)
             observer:^BOOL(BJLError *error) {
                 bjl_strongify(self);
                 if (self.room.loginUser.isTeacher
                     && error.code != BJLErrorCode_exitRoom_loginConflict) {
                     if (self.room.serverRecordingVM.serverRecording) {
                         [self.room.serverRecordingVM requestServerRecording:NO]; // 退出教室停止录课
                     }
                     if (self.room.roomVM.liveStarted) {
                         [self.room.roomVM sendLiveStarted:NO]; // 退出教室下课
                     }
                 }
                 return YES;
             }];
    
    [self bjl_observe:BJLMakeMethod(self.room, roomDidExitWithError:)
             observer:^BOOL(BJLError *error) {
                 bjl_strongify(self);
                 [self clean];
                 [self roomDidExitWithError:error];
                 return YES;
             }];
    
    [self bjl_kvo:BJLMakeProperty(self.room, inRoom)
           filter:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
               // bjl_strongify(self);
               return now.boolValue;
           }
         observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             [self makeObservingWhenEnteredInRoom];
             return YES;
         }];
    
    /*
    [self bjl_kvo:BJLMakeProperty(self.room, vmsAvailable)
           filter:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
               // bjl_strongify(self);
               return now.boolValue && !old.boolValue;
           }
         observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             self.room.recordingVM.videoOrientation = BJLVideoOrientation_landscape;
             return YES;
         }]; */
    
    [self bjl_kvo:BJLMakeProperty(self.room, slideshowViewController)
           filter:^BOOL(id _Nullable old, id _Nullable now) {
               // bjl_strongify(self);
               return !!now;
           }
         observer:^BOOL(id _Nullable old, id _Nullable now) {
             bjl_strongify(self);
             self.room.slideshowViewController.view.backgroundColor = [UIColor clearColor];
             self.room.slideshowViewController.placeholderImage = [UIImage bjl_imageWithColor:[UIColor bjl_grayImagePlaceholderColor]];
             return YES;
         }];
}

- (void)clean {
    self->_room = nil;
    // [self.viewController bjl_removeFromParentViewControllerAndSuperiew];
    // self.viewController = nil;
}

- (void)askToExit {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"提示"
                                message:@"确定退出教室？"
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert bjl_addActionWithTitle:@"确定"
                            style:UIAlertActionStyleDestructive
                          handler:^(UIAlertAction * _Nonnull action) {
                              [self exit];
                          }];
    [alert bjl_addActionWithTitle:@"取消"
                            style:UIAlertActionStyleCancel
                          handler:nil];
    [self presentViewController:alert animated:NO completion:nil];
}

- (void)roomDidExitWithError:(BJLError *)error {
    // !error: 主动退出
    // BJLErrorCode_exitRoom_disconnected: self.loadingViewController 已处理
    if (!error || error.code == BJLErrorCode_exitRoom_disconnected) {
        [self dismissWithError:error];
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"%@: %@(%td)",
                         error.localizedDescription,
                         error.localizedFailureReason ?: @"",
                         error.code];
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"提示"
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction
                      actionWithTitle:@"确定"
                      style:UIAlertActionStyleCancel
                      handler:^(UIAlertAction * _Nonnull action) {
                          [self dismissWithError:error];
                      }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dismissWithError:(nullable BJLError *)error {
    [self roomViewController:self willExitWithError:nil];
    
    void (^completion)(void) = ^{
        [self roomViewController:self didExitWithError:error];
    };
    
    UINavigationController *navigation = [self.parentViewController bjl_as:[UINavigationController class]];
    BOOL isRoot = (navigation
                   && self == navigation.topViewController
                   && self == navigation.bjl_rootViewController);
    UIViewController *outermost = isRoot ? navigation : self;
    
    // pop
    if (navigation && !isRoot) {
        [navigation bjl_popViewControllerAnimated:YES completion:completion];
    }
    // dismiss
    else if (!outermost.parentViewController && outermost.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:completion];
    }
    // close in `roomViewController:didExitWithError:`
    else {
        completion();
    }
}

#pragma mark - NSNotification

- (void)keyboardDidHideWithNotification:(NSNotification *)notification {
    self.keyboardFrame = CGRectZero;
}

- (void)keyboardWillChangeFrameWithNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (!userInfo) {
        return;
    }
    
    self.keyboardFrame = bjl_cast(NSValue, userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;;
}

#pragma mark - protected

- (void)showProgressHUDWithText:(NSString *)text {
    if (!text.length
        || [text isEqualToString:self.prevHUD.detailsLabel.text]) {
        return;
    }
    
    BJLProgressHUD *hud = [BJLProgressHUD bjl_hudForTextWithSuperview:self.view];
    [hud bjl_makeDetailsLabelWithLabelStyle];
    hud.detailsLabel.text = text;
    hud.minShowTime = 0.0; // !!!: MUST be 0.0
    bjl_weakify(self, hud);
    hud.completionBlock = ^{
        bjl_strongify(self, hud);
        if (hud == self.prevHUD) {
            self.prevHUD = nil;
        }
    };
    
    if (self.prevHUD) {
        [self.prevHUD hideAnimated:NO];
        /*
        BJLProgressHUD *prevHUD = self.prevHUD;
        [UIView animateWithDuration:0.5 animations:^{
            prevHUD.offset = CGPointMake(0.0, - (CGRectGetHeight(prevHUD.bezelView.frame) + BJLViewSpaceM));
        } completion:^(BOOL finished) {
            [prevHUD hideAnimated:YES];
        }]; */
    }
    CGFloat minY = CGRectGetMinY(self.keyboardFrame);
    if (minY > CGFLOAT_MIN) {
        hud.offset = CGPointMake(0, - (CGRectGetHeight(self.view.frame) - minY) / 2);
    }
    [hud showAnimated:NO]; // YES?
    [hud hideAnimated:YES afterDelay:BJLProgressHUDTimeInterval];
    self.prevHUD = hud;
}

#pragma mark - public

+ (__kindof instancetype)instanceWithID:(NSString *)roomID
                                apiSign:(NSString *)apiSign
                                   user:(BJLUser *)user {
    BJLRoom *room = [BJLRoom roomWithID:roomID apiSign:apiSign user:user];
    return [[self alloc] initWithRoom:room];
}

+ (__kindof instancetype)instanceWithSecret:(NSString *)roomSecret
                                   userName:(NSString *)userName
                                 userAvatar:(nullable NSString *)userAvatar {
    BJLRoom *room = [BJLRoom roomWithSecret:roomSecret userName:userName userAvatar:userAvatar];
    return [[self alloc] initWithRoom:room];
}

- (void)exit {
    if (self.room) {
        [self.room exit];
        [self clean];
    }
    else {
        [self dismissWithError:nil];
    }
}

- (void)setCustomButtons:(NSArray<UIButton *> *)buttons {
    UIView *customContainerView = self.topBarView.customContainerView;
    
    [customContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIButton *last = nil;
    for (UIButton *button in buttons) {
        [customContainerView addSubview:button];
        [button setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                forAxis:UILayoutConstraintAxisHorizontal];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(last.mas_left ?: customContainerView).with.offset(- BJLViewSpaceM);
            make.centerY.equalTo(customContainerView);
        }];
        
        bjl_weakify(self);
        [button bjl_addHandler:^(UIButton * _Nullable sender) {
            bjl_strongify(self);
            if ([self.delegate respondsToSelector:@selector(roomViewController:viewControllerToShowForCustomButton:)]) {
                UIViewController *content = [self.delegate
                                             roomViewController:self
                                             viewControllerToShowForCustomButton:sender];
                if (content) {
                    [self.overlayViewController showWithContentViewController:content];
                }
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        last = button;
    }
    
    [last mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(customContainerView);
    }];
}

#pragma mark - lazy load properties

- (void)makeViewControllersOnViewDidLoad {
    { // in-order add subview/childViewControllers
        [self.view addSubview:self.contentView];
        [self.view addSubview:self.backgroundView];
        [self bjl_addChildViewController:self.controlsViewController
                               superview:self.view];
        [self bjl_addChildViewController:self.chatViewController
                               superview:self.view];
        [self bjl_addChildViewController:self.previewsViewController
                               superview:self.view];
        [self.view addSubview:self.recordingStateView];
        
        [self.view addSubview:self.topBarView];
        [self bjl_addChildViewController:self.overlayViewController];
        
        // at last
        [self bjl_addChildViewController:self.loadingViewController];
    }
    
    [UIViewController attemptRotationToDeviceOrientation];
    // @see - [self updateViewConstraints]
    [self.view setNeedsUpdateConstraints];
}

@synthesize contentView = _contentView;
- (BJLContentView *)contentView {
    return _contentView ?: (_contentView = ({
        BJLContentView *view = [BJLContentView new];
        view;
    }));
}

@synthesize backgroundView = _backgroundView;
- (UIView *)backgroundView {
    return _backgroundView ?: (_backgroundView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor bjl_grayLineColor];
        view;
    }));
}

@synthesize previewsViewController = _previewsViewController;
- (BJLPreviewsViewController *)previewsViewController {
    return _previewsViewController ?: (_previewsViewController = ({
        BJLPreviewsViewController *view = [[BJLPreviewsViewController alloc] initWithRoom:self.room];
        view;
    }));
}

@synthesize controlsViewController = _controlsViewController;
- (BJLControlsViewController *)controlsViewController {
    return _controlsViewController ?: (_controlsViewController = ({
        BJLControlsViewController *controller = [[BJLControlsViewController alloc] initWithRoom:self.room];
        controller;
    }));
}

@synthesize chatInputViewController = _chatInputViewController;
- (BJLChatInputViewController *)chatInputViewController {
    return _chatInputViewController ?: (_chatInputViewController = ({
        BJLChatInputViewController *controller = [[BJLChatInputViewController alloc] initWithRoom:self.room];
        bjl_weakify(self);
        [controller setSelectImageFileCallback:^(ICLImageFile *file, UIImage * _Nullable image) {
            bjl_strongify(self);
            [self.overlayViewController hide];
            [self.chatViewController refreshMessages];
            [self.chatViewController sendImageFile:file image:image];
        }];
        [controller setFinishCallback:^(NSString * _Nullable errorMessage) {
            bjl_strongify(self);
            [self.overlayViewController hide];
            if (errorMessage.length) {
                [self showProgressHUDWithText:errorMessage];
            }
            else {
                [self.chatViewController refreshMessages];
            }
        }];
        controller;
    }));
}

@synthesize recordingStateView = _recordingStateView;
- (UIButton *)recordingStateView {
    return _recordingStateView ?: (_recordingStateView = ({
        BJLButton *button = [BJLButton new];
        [button setTitle:@"录课中" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"bjl_ic_luxianging"] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        button.backgroundColor = [UIColor bjl_lightMostDimColor];
        button.adjustsImageWhenHighlighted = NO;
        button.adjustsImageWhenDisabled = NO;
        CGSize buttonSize = CGSizeMake(85.0, BJLButtonSizeS);
        button.layer.cornerRadius = buttonSize.height / 2;
        button.intrinsicContentSize = buttonSize;
        button.midSpace = BJLViewSpaceS;
        button.layer.masksToBounds = YES;
        button.hidden = YES;
        button;
    }));
}

@synthesize topBarView = _topBarView;
- (BJLTopBarView *)topBarView {
    return _topBarView ?: (_topBarView = ({
        BJLTopBarView *view = [BJLTopBarView new];
        view;
    }));
}

@synthesize onlineUsersViewController = _onlineUsersViewController;
- (BJLUsersViewController *)onlineUsersViewController {
    return _onlineUsersViewController ?: (_onlineUsersViewController = ({
        BJLUsersViewController *controller = [[BJLUsersViewController alloc] initWithRoom:self.room userStates:BJLUserStateMask_online];
        controller;
    }));
}

@synthesize pptManageViewController = _pptManageViewController;
- (BJLPPTManageViewController *)pptManageViewController {
    return _pptManageViewController ?: (_pptManageViewController = ({
        BJLPPTManageViewController *controller = [[BJLPPTManageViewController alloc] initWithRoom:self.room];
        bjl_weakify(self);
        [controller setUploadingCallback:^(NSInteger failedCount, void (^ _Nullable retry)(void)) {
            bjl_strongify(self);
            if (failedCount > 0) {
                [self showProgressHUDWithText:[NSString stringWithFormat:@"有%td个课件上传失败", failedCount]];
                /*
                UIAlertController *alert = [UIAlertController
                                            alertControllerWithTitle:@"错误"
                                            message:[NSString stringWithFormat:@"有%td个课件上传失败。", failedCount]
                                            preferredStyle:UIAlertControllerStyleAlert];
                if (retry) {
                    [alert bjl_addActionWithTitle:@"重试"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * _Nonnull action) {
                                              retry();
                                          }];
                }
                [alert bjl_addActionWithTitle:retry ? @"取消" : @"确定"
                                        style:UIAlertActionStyleCancel
                                      handler:nil];
                [self presentViewController:alert animated:YES completion:nil]; */
            }
            else {
                [self showProgressHUDWithText:@"课件上传完成"];
            }
        }];
        controller;
    }));
}

@synthesize pptQuickSlideViewController = _pptQuickSlideViewController;
- (BJLPPTQuickSlideViewController *)pptQuickSlideViewController {
    return _pptQuickSlideViewController ?: (_pptQuickSlideViewController = ({
        BJLPPTQuickSlideViewController *controller = [[BJLPPTQuickSlideViewController alloc] initWithRoom:self.room];
        /*
        [controller setSelectPPTCallback:^{
            [self.overlayViewController hide];
        }];
        */
        controller;
    }));
}

@synthesize chatViewController = _chatViewController;
- (BJLChatViewController *)chatViewController {
    return _chatViewController ?: (_chatViewController = ({
        BJLChatViewController *controller = [[BJLChatViewController alloc] initWithRoom:self.room];
        controller;
    }));
}

@synthesize moreViewController = _moreViewController;
- (BJLMoreViewController *)moreViewController {
    return _moreViewController ?: (_moreViewController = ({
        BJLMoreViewController *controller = [[BJLMoreViewController alloc] initWithForTeacher:self.room.loginUser.isTeacher];
        bjl_weakify(self);
        [controller setNoticeCallback:^(id _Nullable sender) {
            bjl_strongify(self);
            [self.moreViewController bjl_removeFromParentViewControllerAndSuperiew];
            
            if (self.room.loginUser.isTeacherOrAssistant) {
                UIRectEdge edges = UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom;
                CGSize size = CGSizeZero;
                self.overlayViewController.prefersStatusBarHidden = NO;
                [self.overlayViewController showWithContentViewController:self.noticeEditViewController
                                                                 horEdges:edges horSize:size
                                                                 verEdges:edges verSize:size];
            }
            else {
                [self.overlayViewController showWithContentViewController:self.noticeViewController];
            }
        }];
        [controller setServerRecordingCallback:^(id _Nullable sender) {
            bjl_strongify(self);
            [self.moreViewController bjl_removeFromParentViewControllerAndSuperiew];
            
            BOOL wasRecording = self.room.serverRecordingVM.serverRecording;
            BJLError *error = [self.room.serverRecordingVM requestServerRecording:!wasRecording];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            }
        }];
        [controller setSettingsCallback:^(id _Nullable sender) {
            bjl_strongify(self);
            [self.moreViewController bjl_removeFromParentViewControllerAndSuperiew];
            [self.overlayViewController showWithContentViewController:self.settingsViewController];
        }];
        [controller setCloseCallback:^(id _Nullable sender) {
            bjl_strongify(self);
            [self.moreViewController bjl_removeFromParentViewControllerAndSuperiew];
        }];
        controller;
    }));
}

@synthesize noticeViewController = _noticeViewController;
- (BJLNoticeViewController *)noticeViewController {
    return _noticeViewController ?: (_noticeViewController = ({
        BJLNoticeViewController *controller = [[BJLNoticeViewController alloc] initWithRoom:self.room];
        controller;
    }));
}

@synthesize noticeEditViewController = _noticeEditViewController;
- (BJLNoticeEditViewController *)noticeEditViewController {
    return _noticeEditViewController ?: (_noticeEditViewController = ({
        BJLNoticeEditViewController *controller = [[BJLNoticeEditViewController alloc] initWithRoom:self.room];
        bjl_weakify(self);
        [controller setFinishCallback:^(id _Nullable sender) {
            bjl_strongify(self);
            [self.overlayViewController hide];
        }];
        controller;
    }));
}

@synthesize settingsViewController = _settingsViewController;
- (BJLSettingsViewController *)settingsViewController {
    return _settingsViewController ?: (_settingsViewController = ({
        BJLSettingsViewController *controller = [[BJLSettingsViewController alloc] initWithRoom:self.room];
        controller;
    }));
}

@synthesize imageViewController = _imageViewController;
- (BJLImageViewController *)imageViewController {
    return _imageViewController ?: (_imageViewController = ({
        BJLImageViewController *controller = [BJLImageViewController new];
        bjl_weakify(self);
        [controller setHideCallback:^(id _Nullable sender) {
            bjl_strongify(self);
            [UIView animateWithDuration:BJLAnimateDurationM
                             animations:^{
                                 self.imageViewController.view.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                                 self.imageViewController.imageView.image = nil;
                                 [self.imageViewController bjl_removeFromParentViewControllerAndSuperiew];
                                 [self setNeedsStatusBarAppearanceUpdate];
                             }];
        }];
        controller;
    }));
}

@synthesize overlayViewController = _overlayViewController;
- (BJLOverlayViewController *)overlayViewController {
    return _overlayViewController ?: (_overlayViewController = ({
        BJLOverlayViewController *controller = [BJLOverlayViewController new];
        controller;
    }));
}

@synthesize loadingViewController = _loadingViewController;
- (BJLLoadingViewController *)loadingViewController {
    return _loadingViewController ?: (_loadingViewController = ({
        BJLLoadingViewController *controller = [[BJLLoadingViewController alloc] initWithRoom:self.room];
        controller;
    }));
}

@end

#pragma mark -

@implementation BJLRoomViewController (BJLObservable)

- (BJLObservable)roomViewControllerEnterRoomSuccess:(BJLRoomViewController *)roomViewController {
    BJLMethodNotify((BJLRoomViewController *),
                    roomViewController);
    if ([self.delegate respondsToSelector:@selector(roomViewControllerEnterRoomSuccess:)]) {
        [self.delegate roomViewControllerEnterRoomSuccess:self];
    }
}

- (BJLObservable)roomViewController:(BJLRoomViewController *)roomViewController
          enterRoomFailureWithError:(BJLError *)error {
    BJLMethodNotify((BJLRoomViewController *, BJLError *),
                    roomViewController, error);
    if ([self.delegate respondsToSelector:@selector(roomViewController:enterRoomFailureWithError:)]) {
        [self.delegate roomViewController:self enterRoomFailureWithError:error];
    }
}

- (BJLObservable)roomViewController:(BJLRoomViewController *)roomViewController
                  willExitWithError:(nullable BJLError *)error {
    BJLMethodNotify((BJLRoomViewController *, BJLError *),
                    roomViewController, error);
    if ([self.delegate respondsToSelector:@selector(roomViewController:willExitWithError:)]) {
        [self.delegate roomViewController:self willExitWithError:error];
    }
}

- (BJLObservable)roomViewController:(BJLRoomViewController *)roomViewController
                   didExitWithError:(nullable BJLError *)error {
    BJLMethodNotify((BJLRoomViewController *, BJLError *),
                    roomViewController, error);
    if ([self.delegate respondsToSelector:@selector(roomViewController:didExitWithError:)]) {
        [self.delegate roomViewController:self didExitWithError:error];
    }
}

@end

NS_ASSUME_NONNULL_END
