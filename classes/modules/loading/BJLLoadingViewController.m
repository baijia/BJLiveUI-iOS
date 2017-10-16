//
//  BJLLoadingViewController.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-01-19.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLLoadingViewController.h"

#import "BJLViewImports.h"

#import "ICLProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLLoadingViewController ()

@property (nonatomic, readonly, weak) BJLRoom *room;

@property (nonatomic) UIButton *exitButton;

@property (nonatomic) UIView *loadingContainerView;
@property (nonatomic) UILabel *loadingProgressLabel;
@property (nonatomic) ICLProgressView *loadingProgressView;
@property (nonatomic, nullable) UIView *supportMessageView;

@property (nonatomic) UIView *errorContainerView;
@property (nonatomic) UIButton *reloadButton;
@property (nonatomic) UILabel *errorTitleLabel, *errorTipsLabel, *errorMoreLabel;

@property (nonatomic, copy, nullable) void (^reloadCallback)(void);

@end

@implementation BJLLoadingViewController

#pragma mark - lifecycle & <BJLRoomChildViewController>

- (instancetype)initWithRoom:(BJLRoom *)room {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self->_room = room;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor bjl_lightDimColor];
    self.view.hidden = YES;
    
    [self makeSubviews];
    [self makeConstraints];
    
    bjl_weakify(self);
    
    [self bjl_kvo:BJLMakeProperty(self.room, loadingVM)
           filter:^BOOL(id _Nullable old, id _Nullable now) {
               bjl_strongify(self);
               self.view.hidden = !self.room.loadingVM;
               return !!now;
           }
         observer:^BOOL(id _Nullable old, id _Nullable now) {
             bjl_strongify(self);
             [self showLoadingWithVM:self.room.loadingVM];
             return YES;
         }];
    
    [self.room setReloadingBlock:^(BJLLoadingVM *reloadingVM, void (^callback)(BOOL reload)) {
        bjl_strongify(self);
        self.view.hidden = NO;
        [self showReloadingWithVM:reloadingVM];
        callback(YES);
    }];
    
    [self bjl_kvo:BJLMakeProperty(self.room, roomInfo)
           filter:^BOOL(id _Nullable old, id _Nullable now) {
               // bjl_strongify(self);
               return !!now;
           }
         observer:^BOOL(id _Nullable old, id _Nullable now) {
             bjl_strongify(self);
             self.errorMoreLabel.text = self.room.roomInfo.customerSupportMessage;
             return YES;
         }];
    
    [self makeActions];
}

#pragma mark - getters & setters

- (BOOL)isHidden {
    return self.view.hidden;
}

#pragma mark -

- (void)showLoadingWithVM:(nullable BJLLoadingVM *)loadingVM {
    self.view.backgroundColor = [UIColor bjl_lightDimColor];
    self.loadingContainerView.hidden = NO;
    self.errorContainerView.hidden = YES;
    
    if (self.showCallback) self.showCallback(NO);
    
    if (loadingVM) {
        [self makeObservingForLoadingVM:loadingVM];
    }
}

- (void)showReloadingWithVM:(nullable BJLLoadingVM *)loadingVM {
    self.view.backgroundColor = [UIColor clearColor];
    self.loadingContainerView.hidden = NO;
    self.errorContainerView.hidden = YES;
    
    if (self.showCallback) self.showCallback(NO);
    
    if (loadingVM) {
        [self makeObservingForLoadingVM:loadingVM];
    }
}

- (void)showErrorWithTitle:(NSString *)title tips:(NSString *)tips {
    self.view.backgroundColor = [UIColor bjl_lightDimColor];
    self.loadingContainerView.hidden = YES;
    self.errorContainerView.hidden = NO;
    
    if (self.showCallback) self.showCallback(YES);
    
    self.errorTitleLabel.text = title;
    self.errorTipsLabel.text = tips;
}

#pragma mark -

- (void)makeSubviews {
    self.exitButton = ({
        UIButton *button = [UIButton new];
        [button setImage:[UIImage imageNamed:@"bjl_ic_exit"] forState:UIControlStateNormal];
        [self.view addSubview:button];
        button;
    });
    
    self.loadingContainerView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = BJLButtonCornerRadius;
        view.layer.masksToBounds = YES;
        [self.view insertSubview:view atIndex:0];
        view;
    });
    
    self.loadingProgressView = ({
        ICLProgressView *view = [ICLProgressView new];
        view.size = 20.0;
        view.color = [UIColor bjl_lightGrayTextColor];
        [self.loadingContainerView addSubview:view];
        view;
    });
    
    self.loadingProgressLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:16.0];
        label.textColor = [UIColor bjl_lightGrayTextColor];
        label.text = @"连接中 ...";
        [self.loadingContainerView addSubview:label];
        label;
    });
    
    self.errorContainerView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        [self.view insertSubview:view atIndex:0];
        view;
    });
    
    self.reloadButton = ({
        UIButton *button = [UIButton new];
        [button setTitle:@"刷新重试" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor bjl_blueBrandColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        button.backgroundColor = [UIColor whiteColor];
        button.layer.cornerRadius = BJLButtonCornerRadius;
        button.layer.masksToBounds = YES;
        [self.errorContainerView addSubview:button];
        button;
    });
    
    self.errorTitleLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont boldSystemFontOfSize:24.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [self.errorContainerView addSubview:label];
        label;
    });
    
    self.errorTipsLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        [self.errorContainerView addSubview:label];
        label;
    });
    
    self.errorMoreLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        [self.errorContainerView addSubview:label];
        label;
    });
    
    self.supportMessageView = ({
        UIView *supportMessgaeView = [[UIView alloc] init];
        [self.view addSubview:supportMessgaeView];
        
        // logo
        UIImageView *logoImageView = ({
            UIImage *logo = [UIImage imageNamed:@"ic_baijiayun_logo"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:logo];
            imageView.alpha = 0.3;
            imageView;
        });
        [supportMessgaeView addSubview:logoImageView];
        [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.centerY.equalTo(supportMessgaeView);
            make.size.mas_equalTo(CGSizeMake(19.0, 13.0));
        }];
        
        // message label
        UILabel *messageLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont systemFontOfSize:12.0];
            label.text = @"百家云提供直播服务";
            label.textColor = [UIColor bjl_grayBorderColor];
            label.numberOfLines = 0;
            label.alpha = 0.3;
            label;
        });
        [supportMessgaeView addSubview:messageLabel];
        [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(logoImageView.mas_right).offset(5.0);
            make.right.top.bottom.equalTo(supportMessgaeView);
        }];
        
        supportMessgaeView.hidden = YES;
        supportMessgaeView;
    });
}

- (void)makeConstraints {
    // TODO: 对齐到 BJLTopBarView 的 exitButton
    [self.exitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(self.view).offset(BJLViewSpaceM);
        if (bjl_iPhoneX()) {
            // ver
            make.top.equalTo(self.view.bjl_safeAreaLayoutGuide)/* .offset(- BJLViewSpaceS) */.priorityHigh();
        }
        else {
            // self.view.bjl_safeAreaLayoutGuide: iOS 11
            // self.mas_topLayoutGuide: earlier
            make.top.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.mas_topLayoutGuide).priorityHigh();
        }
        make.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view).with.offset(- BJLViewSpaceM);
    }];
    
    [self.loadingContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@144);
        make.height.equalTo(@40);
    }];
    
    [self.loadingProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.loadingContainerView).with.offset(BJLViewSpaceL);
        make.centerY.equalTo(self.loadingContainerView);
        make.width.height.equalTo(@20);
    }];
    
    [self.loadingProgressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.loadingProgressView.mas_right).with.offset(BJLViewSpaceM);
        make.centerY.equalTo(self.loadingContainerView);
    }];
    
    [self.errorContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.errorContainerView);
        make.width.equalTo(@144.0);
        make.height.equalTo(@40.0);
    }];
    
    CGFloat largeSpace = 24.0;
    
    [self.errorTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.errorContainerView).with.inset(BJLViewSpaceM);
        make.bottom.equalTo(self.reloadButton.mas_top).with.offset(- largeSpace);
    }];
    
    [self.errorTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.errorContainerView).with.inset(BJLViewSpaceM);
        make.bottom.equalTo(self.errorTipsLabel.mas_top).with.offset(- BJLViewSpaceM);
    }];
    
    [self.errorMoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.errorContainerView).with.inset(BJLViewSpaceM);
        make.top.equalTo(self.reloadButton.mas_bottom).with.offset(largeSpace);
    }];
    
    [self.supportMessageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(- 20.0);
        make.left.greaterThanOrEqualTo(self.view).with.offset(BJLViewSpaceL);
        make.right.lessThanOrEqualTo(self.view).with.offset(- BJLViewSpaceL);
    }];
}

- (void)makeObservingForLoadingVM:(BJLLoadingVM *)loadingVM {
    static const NSInteger maxFaildTimes = 3;
    __block NSInteger faildTimes = 0;
    bjl_weakify(self);
    loadingVM.suspendBlock = ^(BJLLoadingStep step,
                               BJLLoadingSuspendReason reason,
                               BJLError *error,
                               void (^continueCallback)(BOOL isContinue)) {
        bjl_strongify(self);
        if (reason == BJLLoadingSuspendReason_errorOccurred) {
            faildTimes++;
        }
        else {
            faildTimes = 0;
        }
        if (faildTimes >= maxFaildTimes) {
            if (!error) {
                error = BJLErrorMake(BJLErrorCode_unknown, nil);
            }
            [self showErrorWithTitle:@"哎呀出错了"
                                tips:[NSString stringWithFormat:@"%@: %@(%td-%td)",
                                      error.localizedDescription,
                                      error.localizedFailureReason ?: @"",
                                      step,
                                      reason]];
            self.reloadCallback = ^{
                bjl_strongify(self);
                faildTimes = 0;
                self.reloadCallback = nil;
                [self showReloadingWithVM:nil];
                continueCallback(YES);
            };
        }
        else if (faildTimes > 0) {
            // 0, 1, 2
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(faildTimes * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                continueCallback(YES);
            });
        }
        else {
            continueCallback(YES);
        }
    };
    
    [self bjl_observe:BJLMakeMethod(loadingVM, loadingUpdateProgress:)
             observer:(BJLMethodObserver)^BOOL(CGFloat progress) {
                 bjl_strongify(self);
                 NSLog(@"loading progress: %f", progress);
                 self.loadingProgressView.progress = progress;
                 if (self.supportMessageView
                     && self.room.featureConfig
                     && !self.room.featureConfig.hideSupportMessage) {
                     self.supportMessageView.hidden = NO;
                 }
                 return YES;
             }];
    
    [self bjl_observe:BJLMakeMethod(loadingVM, loadingSuccess)
             observer:^BOOL() {
                 bjl_strongify(self);
                 NSLog(@"loading success");
                 self.view.hidden = YES;
                 [self.supportMessageView removeFromSuperview];
                 self.supportMessageView = nil;
                 if (self.hideCallback) self.hideCallback();
                 return YES;
             }];
    
    [self bjl_observe:BJLMakeMethod(loadingVM, loadingFailureWithError:)
             observer:^BOOL(BJLError *error) {
                 bjl_strongify(self);
                 NSLog(@"loading failure");
                 self.view.hidden = YES;
                 [self.supportMessageView removeFromSuperview];
                 self.supportMessageView = nil;
                 if (self.hideCallbackWithError) self.hideCallbackWithError(error);
                 return YES;
             }];
}

- (void)makeActions {
    bjl_weakify(self);
    
    [self.exitButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.exitCallback) self.exitCallback();
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.reloadButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.reloadCallback) {
            self.reloadCallback();
        }
    } forControlEvents:UIControlEventTouchUpInside];
}

@end

NS_ASSUME_NONNULL_END
