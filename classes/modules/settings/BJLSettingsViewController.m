//
//  BJLSettingsViewController.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-06.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLAuthorization.h>

#import "BJLSettingsViewController.h"

#import "BJLOverlayViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLSettingsViewController ()

@property (nonatomic, readonly, weak) BJLRoom *room;

@property (nonatomic) UIView *micLabel, *cameraLabel, *beautifyLabel, *forbidSpeakLabel, *forbidChatLabel;
@property (nonatomic) UISwitch *micSwitch, *cameraSwitch, *beautifySwitch, *forbidSpeakSwitch, *forbidChatSwitch;

@property (nonatomic) UIView *separatorLine;

@property (nonatomic) UILabel *contentModeLabel, *videoDefinitionLabel, *cameraPositionLabel, *linkTypeLabel;
@property (nonatomic) UIButton *contentModeFitButton, *contentModeFillButton;
@property (nonatomic) UIButton *videoDefinitionLowButton, *videoDefinitionHighButton;
@property (nonatomic) UIButton *cameraPositionFrontButton, *cameraPositionRearButton;
@property (nonatomic) UIButton *upLinkTypeTCPButton, *upLinkTypeUDPButton;
@property (nonatomic) UIButton *downLinkTypeTCPButton, *downLinkTypeUDPButton;

@end

@implementation BJLSettingsViewController

#pragma mark - lifecycle & <BJLRoomChildViewController>

- (instancetype)initWithRoom:(BJLRoom *)room {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self->_room = room;
    }
    return self;
}

- (void)didMoveToParentViewController:(nullable UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    
    if (!parent && !self.bjl_overlayContainerController) {
        return;
    }
    
    [self.bjl_overlayContainerController updateTitle:@"设置"];
    [self.bjl_overlayContainerController updateRightButtons:nil];
    [self.bjl_overlayContainerController updateFooterView:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollView.alwaysBounceVertical = YES;
    
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room, vmsAvailable)
           filter:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
               // bjl_strongify(self);
               return now.boolValue;
           }
         observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             [self makeSubviewsAndConstraints];
             [self makeObservingAndActions];
             return YES;
         }];
}

- (void)makeSubviewsAndConstraints {
    BJLTuple *micControls = [self makeSwitchWithLabel:@"麦克风"];
    BJLTupleUnpack(micControls) = ^(UIView *label, UISwitch *swiitch) {
        self.micLabel = label;
        self.micSwitch = swiitch;
    };
    BJLTuple *cameraControls = [self makeSwitchWithLabel:@"摄像头"];
    BJLTupleUnpack(cameraControls) = ^(UIView *label, UISwitch *swiitch) {
        self.cameraLabel = label;
        self.cameraSwitch = swiitch;
    };
    BJLTuple *beautifyControls = [self makeSwitchWithLabel:@"美颜"];
    BJLTupleUnpack(beautifyControls) = ^(UIView *label, UISwitch *swiitch) {
        self.beautifyLabel = label;
        self.beautifySwitch = swiitch;
    };
    NSArray *tuples = nil;
    if (self.room.loginUser.isTeacherOrAssistant) {
        BJLTuple *forbidSpeakControls = [self makeSwitchWithLabel:@"禁止举手"];
        BJLTupleUnpack(forbidSpeakControls) = ^(UIView *label, UISwitch *swiitch) {
            self.forbidSpeakLabel = label;
            self.forbidSpeakSwitch = swiitch;
        };
        BJLTuple *forbidChatControls = [self makeSwitchWithLabel:@"全体禁言"];
        BJLTupleUnpack(forbidChatControls) = ^(UIView *label, UISwitch *swiitch) {
            self.forbidChatLabel = label;
            self.forbidChatSwitch = swiitch;
        };
        tuples = @[micControls, cameraControls, beautifyControls, forbidSpeakControls, forbidChatControls];
    }
    else {
        tuples = @[micControls, cameraControls, beautifyControls];
    }
    
    static const NSInteger columnsPerLine = 3;
    NSMutableArray<UIView *> *spaceViews = [NSMutableArray new], *placeholders = [NSMutableArray new];
    
    UIView *lastSpaceView = nil, *lastPlaceholder = nil;
    for (NSInteger column = 0; column < columnsPerLine; column++) {
        UIView *spaceView = [self makeInvisibleView];
        // spaceView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.3];
        [spaceViews addObject:spaceView];
        [spaceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lastPlaceholder.mas_right ?: self.scrollView);
            if (lastSpaceView) {
                make.width.equalTo(lastSpaceView);
            }
            make.top.bottom.equalTo(self.scrollView);
        }];
        
        UIView *placeholder = [self makeInvisibleView];
        // placeholder.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3];
        [placeholders bjl_addObjectOrNil:placeholder];
        [placeholder mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(spaceView.mas_right);
            if (lastPlaceholder) {
                make.width.equalTo(lastPlaceholder);
            }
            else {
                static const CGFloat switchSize = 50.0;
                make.width.equalTo(@(switchSize));
            }
            make.top.bottom.equalTo(self.scrollView);
        }];
        
        lastSpaceView = spaceView;
        lastPlaceholder = placeholder;
    }
    
    UIView *spaceView = [self makeInvisibleView];
    // spaceView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.3];
    [spaceViews addObject:spaceView];
    [spaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lastPlaceholder.mas_right ?: self.scrollView);
        if (lastSpaceView) {
            make.width.equalTo(lastSpaceView);
        }
        make.right.equalTo(@[self.scrollView, self.view.bjl_safeAreaLayoutGuide ?: self.view]); // right
        make.top.bottom.equalTo(self.scrollView);
    }];
    
    lastSpaceView = nil;
    lastPlaceholder = nil;
    
    __block UIView *lastLabel = nil;
    __block UISwitch *lastSwitch = nil;
    for (NSInteger index = 0; index < tuples.count; index++) {
        NSInteger column = index % columnsPerLine;
        BJLTuple *tuple = [tuples objectAtIndex:index];
        UIView *placeholder = [placeholders objectAtIndex:column];
        
        BJLTupleUnpack(tuple) = ^(UIView *label, UISwitch *swiitch) {
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(placeholder);
                if (column == 0) {
                    make.top.equalTo(lastSwitch.mas_bottom ?: self.scrollView).with.offset(BJLViewSpaceL);
                }
                else {
                    make.top.equalTo(lastLabel.mas_top);
                }
            }];
            [swiitch mas_makeConstraints:^(MASConstraintMaker *make) {
                if (index == 0) {
                    make.width.equalTo(placeholder); // fixed width
                }
                make.centerX.equalTo(placeholder);
                make.top.equalTo(label.mas_bottom).with.offset(BJLViewSpaceM);
            }];
            
            lastLabel = label;
            lastSwitch = swiitch;
        };
    }
    
    self.separatorLine = ({
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor bjl_grayLineColor];
        [self.scrollView addSubview:line];
        line;
    });
    [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.scrollView).with.offset(BJLViewSpaceL);
        make.right.equalTo(self.scrollView);
        make.top.equalTo(lastSwitch.mas_bottom).with.offset(BJLViewSpaceL);
        make.height.equalTo(@(BJLOnePixel));
    }];
    
    self.contentModeLabel = [self makeLabelWithText:@"课件展示："];
    self.contentModeFitButton = [self makeSelectButtonWithTitle:@"全屏"];
    self.contentModeFillButton = [self makeSelectButtonWithTitle:@"铺满"];
    
    self.videoDefinitionLabel = [self makeLabelWithText:@"画质设置："];
    self.videoDefinitionLowButton = [self makeSelectButtonWithTitle:@"标清"];
    self.videoDefinitionHighButton = [self makeSelectButtonWithTitle:@"高清"];
    
    self.cameraPositionLabel = [self makeLabelWithText:@"摄像头切换："];
    self.cameraPositionFrontButton = [self makeSelectButtonWithTitle:@"前"];
    self.cameraPositionRearButton = [self makeSelectButtonWithTitle:@"后"];
    
    self.linkTypeLabel = [self makeLabelWithText:@"线路选择："];
    self.upLinkTypeTCPButton = [self makeSelectButtonWithTitle:@"发送1"];
    self.upLinkTypeUDPButton = [self makeSelectButtonWithTitle:@"发送2"];
    self.downLinkTypeTCPButton = [self makeSelectButtonWithTitle:@"接收1"];
    self.downLinkTypeUDPButton = [self makeSelectButtonWithTitle:@"接收2"];
    
    [self makeConstraintsForSubviewsAfterSeparatorLine];
}

- (UIView *)makeInvisibleView {
    UIView *view = [UIView new];
    view.hidden = NO;
    [self.scrollView addSubview:view];
    [self.scrollView sendSubviewToBack:view];
    return view;
}

// - (BJLTuple<BJLTupleGeneric(UILabel *, UISwitch *)> *)makeLabelButtonAndSwitchWithTitle:(NSString *)title
- (BJLTupleType(UIView *, UISwitch *))makeSwitchWithLabel:(NSString *)text {
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = [UIColor bjl_darkGrayTextColor];
    label.font = [UIFont systemFontOfSize:15.0];
    [self.scrollView addSubview:label];
    
    UISwitch *swiitch = [UISwitch new];
    swiitch.onTintColor = [UIColor bjl_blueBrandColor];
    swiitch.tintColor = [UIColor bjl_grayBorderColor];
    swiitch.backgroundColor = [UIColor bjl_grayBorderColor];
    swiitch.layer.cornerRadius = CGRectGetHeight(swiitch.frame) / 2;
    swiitch.layer.masksToBounds = YES;
    [self.scrollView addSubview:swiitch];
    
    return BJLTuplePack((UIView *, UISwitch *), label, swiitch);
}

- (UILabel *)makeLabelWithText:(NSString *)text {
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:15.0];
    label.textColor = [UIColor bjl_darkGrayTextColor];
    label.text = text;
    [self.scrollView addSubview:label];
    return label;
}

- (UIButton *)makeSelectButtonWithTitle:(NSString *)title {
    BJLButton *button = [BJLButton new];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor bjl_darkGrayTextColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage bjl_imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13.0];
    
    UIColor *selectedColor = [UIColor whiteColor];
    [button setTitleColor:selectedColor forState:UIControlStateSelected];
    [button setTitleColor:selectedColor forState:UIControlStateSelected | UIControlStateHighlighted];
    [button setTitleColor:selectedColor forState:UIControlStateSelected | UIControlStateDisabled];
    
    UIImage *selectedImage = [UIImage bjl_imageWithColor:[UIColor bjl_blueBrandColor]];
    [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
    [button setBackgroundImage:selectedImage forState:UIControlStateSelected | UIControlStateHighlighted];
    [button setBackgroundImage:selectedImage forState:UIControlStateSelected | UIControlStateDisabled];
    
    button.layer.borderColor = [UIColor bjl_grayBorderColor].CGColor;
    button.layer.cornerRadius = BJLButtonSizeS / 2;
    button.layer.masksToBounds = YES;
    bjl_weakify(button);
    [button bjl_kvo:BJLMakeProperty(button, selected)
           observer:^BOOL(id _Nullable old, id _Nullable now) {
               bjl_strongify(button);
               button.layer.borderWidth = button.selected ? 0.0 : BJLOnePixel;
               return YES;
           }];
    [button bjl_kvo:BJLMakeProperty(button, enabled)
           observer:^BOOL(id _Nullable old, id _Nullable now) {
               bjl_strongify(button);
               button.alpha = button.enabled ? 1.0 : 0.5;
               return YES;
           }];
    
    button.intrinsicContentSize = CGSizeMake(64.0, BJLButtonSizeS);
    
    [self.scrollView addSubview:button];
    return button;
}

- (void)makeConstraintsForSubviewsAfterSeparatorLine {
    [self.contentModeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.micSwitch);
        make.centerY.equalTo(self.contentModeFitButton);
    }];
    [self.contentModeFitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.cameraSwitch);
        make.top.equalTo(self.separatorLine).with.offset(BJLViewSpaceL);
    }];
    [self.contentModeFillButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.beautifySwitch);
        make.centerY.equalTo(self.contentModeFitButton);
    }];
    
    [self.videoDefinitionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentModeLabel);
        make.centerY.equalTo(self.videoDefinitionLowButton);
    }];
    [self.videoDefinitionLowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentModeFitButton);
        make.top.equalTo(self.contentModeFitButton.mas_bottom).with.offset(BJLViewSpaceL);
    }];
    [self.videoDefinitionHighButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentModeFillButton);
        make.centerY.equalTo(self.videoDefinitionLowButton);
    }];
    
    [self.cameraPositionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentModeLabel);
        make.centerY.equalTo(self.cameraPositionFrontButton);
    }];
    [self.cameraPositionFrontButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentModeFitButton);
        make.top.equalTo(self.videoDefinitionLowButton.mas_bottom).with.offset(BJLViewSpaceL);
    }];
    [self.cameraPositionRearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentModeFillButton);
        make.centerY.equalTo(self.cameraPositionFrontButton);
    }];
    
    [self.linkTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentModeLabel);
        make.centerY.equalTo(self.upLinkTypeTCPButton);
    }];
    [self.upLinkTypeTCPButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentModeFitButton);
        make.top.equalTo(self.cameraPositionFrontButton.mas_bottom).with.offset(BJLViewSpaceL);
    }];
    [self.upLinkTypeUDPButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentModeFillButton);
        make.centerY.equalTo(self.upLinkTypeTCPButton);
    }];
    [self.downLinkTypeTCPButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentModeFitButton);
        make.top.equalTo(self.upLinkTypeTCPButton.mas_bottom).with.offset(BJLViewSpaceL);
    }];
    [self.downLinkTypeUDPButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentModeFillButton);
        make.centerY.equalTo(self.downLinkTypeTCPButton);
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.downLinkTypeTCPButton).with.offset(BJLViewSpaceL * 2);
    }];
}

- (void)makeObservingAndActions {
    bjl_weakify(self);
    
    if (!self.room.loginUser.isTeacherOrAssistant) {
        [self bjl_kvo:BJLMakeProperty(self.room.speakingRequestVM, speakingEnabled)
             observer:^BOOL(id _Nullable old, NSNumber * _Nullable now) {
                 bjl_strongify(self);
                 BOOL enabled = (!self.room.featureConfig.disableSpeakingRequest
                                 && (self.room.speakingRequestVM.speakingEnabled
                                     || self.room.roomInfo.roomType != BJLRoomType_1toN));
                 self.micSwitch.enabled = enabled;
                 self.cameraSwitch.enabled = enabled;
                 return YES;
             }];
    }
    
    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, recordingAudio)
         observer:^BOOL(id _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             self.micSwitch.on = now.boolValue;
             return YES;
         }];
    [self.micSwitch bjl_addHandler:^(UISwitch * _Nullable sender) {
        bjl_strongify(self);
        [sender bjl_disableForSeconds:BJLRobotDelayS];
        [BJLAuthorization checkMicrophoneAccessAndRequest:YES callback:^(BOOL granted, UIAlertController * _Nullable alert) {
            if (granted) {
                BJLError *error = [self.room.recordingVM setRecordingAudio:sender.on
                                                            recordingVideo:self.room.recordingVM.recordingVideo];
                if (error) {
                    [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                    // 避免触发 UIControlEventValueChanged
                    bjl_dispatch_async_main_queue(^{
                        [self.micSwitch setOn:NO animated:NO];
                    });
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
    } forControlEvents:UIControlEventValueChanged];
    
    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, recordingVideo)
         observer:^BOOL(id _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             BOOL on = now.boolValue;
             self.cameraSwitch.on = on;
             /*
             self.beautifySwitch.enabled = on;
             self.videoDefinitionLowButton.enabled = on;
             self.videoDefinitionHighButton.enabled = on;
             self.cameraPositionFrontButton.enabled = on;
             self.cameraPositionRearButton.enabled = on;
             self.upLinkTypeTCPButton.enabled = on;
             self.upLinkTypeUDPButton.enabled = on; */
             return YES;
         }];
    [self.cameraSwitch bjl_addHandler:^(UISwitch * _Nullable sender) {
        bjl_strongify(self);
        [sender bjl_disableForSeconds:BJLRobotDelayS];
        if (self.room.featureConfig.mediaLimit == BJLMediaLimit_audioOnly) {
            [self showProgressHUDWithText:@"音频课不能打开摄像头"];
            // 避免触发 UIControlEventValueChanged
            bjl_dispatch_async_main_queue(^{
                [self.cameraSwitch setOn:NO animated:NO];
            });
            return;
        }
        [BJLAuthorization checkCameraAccessAndRequest:YES callback:^(BOOL granted, UIAlertController * _Nullable alert) {
            if (granted) {
                BJLError *error = [self.room.recordingVM setRecordingAudio:self.room.recordingVM.recordingAudio
                                                            recordingVideo:sender.on];
                if (error) {
                    [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                    bjl_dispatch_async_main_queue(^{
                        [self.cameraSwitch setOn:NO animated:NO];
                    });
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
    } forControlEvents:UIControlEventValueChanged];
    
    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, videoBeautifyLevel)
         observer:^BOOL(id _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             self.beautifySwitch.on = (now.integerValue != BJLVideoBeautifyLevel_off);
             return YES;
         }];
    [self.beautifySwitch bjl_addHandler:^(UISwitch * _Nullable sender) {
        bjl_strongify(self);
        [sender bjl_disableForSeconds:BJLRobotDelayS];
        [self.room.recordingVM setVideoBeautifyLevel:(sender.on
                                                      ? BJLVideoBeautifyLevel_on
                                                      : BJLVideoBeautifyLevel_off)];
    } forControlEvents:UIControlEventValueChanged];
    
    [self bjl_kvo:BJLMakeProperty(self.room.speakingRequestVM, forbidSpeakingRequest)
         observer:^BOOL(id _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             self.forbidSpeakSwitch.on = now.boolValue;
             return YES;
         }];
    [self.forbidSpeakSwitch bjl_addHandler:^(UISwitch * _Nullable sender) {
        bjl_strongify(self);
        [sender bjl_disableForSeconds:BJLRobotDelayS];
        [self.room.speakingRequestVM requestForbidSpeakingRequest:sender.on];
    } forControlEvents:UIControlEventValueChanged];
    
    [self bjl_kvo:BJLMakeProperty(self.room.chatVM, forbidAll)
         observer:^BOOL(id _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             self.forbidChatSwitch.on = now.boolValue;
             return YES;
         }];
    [self.forbidChatSwitch bjl_addHandler:^(UISwitch * _Nullable sender) {
        bjl_strongify(self);
        [sender bjl_disableForSeconds:BJLRobotDelayS];
        [self.room.chatVM sendForbidAll:sender.on];
    } forControlEvents:UIControlEventValueChanged];
    
    [self bjl_kvo:BJLMakeProperty(self.room, slideshowViewController)
           filter:^BOOL(id _Nullable old, id _Nullable now) {
               // bjl_strongify(self);
               return !old && now;
           }
         observer:^(id _Nullable old, id _Nullable now) {
             bjl_strongify(self);
             self.contentModeFitButton.enabled
             = self.contentModeFillButton.enabled
             = (self.room.disablePPTAnimation
                || self.room.featureConfig.disablePPTAnimation);
             return NO;
         }];
    
    [self bjl_kvo:BJLMakeProperty(self.room.slideshowViewController, contentMode)
         observer:^BOOL(id _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             BJLContentMode contentMode = now.integerValue;
             self.contentModeFitButton.selected = (contentMode == BJLContentMode_scaleAspectFit);
             self.contentModeFillButton.selected = (contentMode == BJLContentMode_scaleAspectFill);
             return YES;
         }];
    [self.contentModeFitButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (!self.contentModeFitButton.selected) {
            self.room.slideshowViewController.contentMode = BJLContentMode_scaleAspectFit;
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self.contentModeFillButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (!self.contentModeFillButton.selected) {
            self.room.slideshowViewController.contentMode = BJLContentMode_scaleAspectFill;
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, videoDefinition)
         observer:^BOOL(id _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             BJLVideoDefinition videoDefinition = now.integerValue;
             self.videoDefinitionLowButton.selected = (videoDefinition == BJLVideoDefinition_low);
             self.videoDefinitionHighButton.selected = (videoDefinition == BJLVideoDefinition_high);
             return YES;
         }];
    [self.videoDefinitionLowButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (!self.videoDefinitionLowButton.selected) {
            self.room.recordingVM.videoDefinition = BJLVideoDefinition_low;
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self.videoDefinitionHighButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (!self.videoDefinitionHighButton.selected) {
            self.room.recordingVM.videoDefinition = BJLVideoDefinition_high;
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, usingRearCamera)
         observer:^BOOL(id _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             BOOL usingRearCamera = now.boolValue;
             self.cameraPositionFrontButton.selected = !usingRearCamera;
             self.cameraPositionRearButton.selected = usingRearCamera;
             return YES;
         }];
    [self.cameraPositionFrontButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (!self.cameraPositionFrontButton.selected) {
            self.room.recordingVM.usingRearCamera = NO;
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self.cameraPositionRearButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (!self.cameraPositionRearButton.selected) {
            self.room.recordingVM.usingRearCamera = YES;
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self bjl_kvo:BJLMakeProperty(self.room.mediaVM, upLinkType)
         observer:^BOOL(id _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             BJLLinkType upLinkType = now.integerValue;
             self.upLinkTypeTCPButton.selected = (upLinkType == BJLLinkType_TCP);
             self.upLinkTypeUDPButton.selected = (upLinkType == BJLLinkType_UDP);
             return YES;
         }];
    NSString *linkTypeReadonlyText = @"暂时不能切换线路";
    [self.upLinkTypeTCPButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (!self.upLinkTypeTCPButton.selected) {
            if (self.room.mediaVM.upLinkTypeReadOnly) {
                [self showProgressHUDWithText:linkTypeReadonlyText];
                return;
            }
            self.room.mediaVM.upLinkType = BJLLinkType_TCP;
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self.upLinkTypeUDPButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (!self.upLinkTypeUDPButton.selected) {
            if (self.room.mediaVM.upLinkTypeReadOnly) {
                [self showProgressHUDWithText:linkTypeReadonlyText];
                return;
            }
            self.room.mediaVM.upLinkType = BJLLinkType_UDP;
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self bjl_kvo:BJLMakeProperty(self.room.mediaVM, downLinkType)
         observer:^BOOL(id _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             BJLLinkType downLinkType = now.integerValue;
             self.downLinkTypeTCPButton.selected = (downLinkType == BJLLinkType_TCP);
             self.downLinkTypeUDPButton.selected = (downLinkType == BJLLinkType_UDP);
             return YES;
         }];
    [self.downLinkTypeTCPButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (!self.downLinkTypeTCPButton.selected) {
            if (self.room.mediaVM.downLinkTypeReadOnly) {
                [self showProgressHUDWithText:linkTypeReadonlyText];
                return;
            }
            self.room.mediaVM.downLinkType = BJLLinkType_TCP;
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self.downLinkTypeUDPButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (!self.downLinkTypeUDPButton.selected) {
            if (self.room.mediaVM.downLinkTypeReadOnly) {
                [self showProgressHUDWithText:linkTypeReadonlyText];
                return;
            }
            self.room.mediaVM.downLinkType = BJLLinkType_UDP;
        }
    } forControlEvents:UIControlEventTouchUpInside];
}

@end

NS_ASSUME_NONNULL_END
