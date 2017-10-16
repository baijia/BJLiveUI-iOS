//
//  BJLMoreViewController.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-04.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLMoreViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLMoreViewController ()

@property (nonatomic) BOOL isTeacher;

@property (nonatomic) UIImageView *backgroundView;
@property (nonatomic) UIView *contentView;

@property (nonatomic) UIButton *noticeButton, *serverRecordingButton, *helpButton, *settingsButton;

@end

@implementation BJLMoreViewController

#pragma mark - lifecycle & <BJLRoomChildViewController>

- (instancetype)initWithForTeacher:(BOOL)isTeacher {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.isTeacher = isTeacher;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self makeSubviews];
    [self makeConstraints];
    [self makeActions];
    
    bjl_weakify(self);
    [self.view addGestureRecognizer:[UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer * _Nullable gesture) {
        bjl_strongify(self);
        CGPoint location = [gesture locationInView:gesture.view];
        UIView *subview = [gesture.view hitTest:location withEvent:nil];
        if (subview != self.view) {
            return;
        }
        
        if (self.closeCallback) {
            self.closeCallback(self);
        }
    }]];
}

- (void)makeSubviews {
    self.backgroundView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.image = [[UIImage imageNamed:@"bjl_menubg"] bjl_resizableImage];
        imageView.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        imageView.layer.shadowRadius = 4.0;
        imageView.layer.shadowOpacity = 0.3;
        imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        [self.view addSubview:imageView];
        imageView;
    });
    
    self.contentView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        [self.view addSubview:view];
        view;
    });
    
    self.noticeButton = ({
        UIButton *button = [self makeButtonWithTitle:@"公告"
                                           imageName:@"bjl_ic_announcement"];
        [self.contentView addSubview:button];
        button;
    });
    
    self.serverRecordingButton = ({
        UIButton *button = [self makeButtonWithTitle:@"录课"
                                           imageName:@"bjl_ic_luxiang"
                                       selectedTitle:@"录课中"
                                   selectedImageName:@"bjl_ic_luxiang_on"];
        [self.contentView addSubview:button];
        button;
    });
    
    self.helpButton = ({
        UIButton *button = [self makeButtonWithTitle:@"求助"
                                           imageName:@"bjl_ic_help"];
        [self.contentView addSubview:button];
        button;
    });
    
    self.settingsButton = ({
        UIButton *button = [self makeButtonWithTitle:@"设置"
                                           imageName:@"bjl_ic_setting"];
        [self.contentView addSubview:button];
        button;
    });
}

- (UIButton *)makeButtonWithTitle:(NSString *)title
                        imageName:(NSString *)imageName {
    return [self makeButtonWithTitle:title
                           imageName:imageName
                       selectedTitle:nil
                   selectedImageName:nil];
}

- (UIButton *)makeButtonWithTitle:(NSString *)title
                        imageName:(NSString *)imageName
                    selectedTitle:(nullable NSString *)selectedTitle
                selectedImageName:(nullable NSString *)selectedImageName {
    const CGFloat fontSize = 13.0;
    BJLButton *button = [BJLVerticalButton new];
    button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor bjl_grayTextColor] forState:UIControlStateNormal];
    if (selectedTitle) {
        [button setTitle:selectedTitle forState:UIControlStateSelected];
        [button setTitle:selectedTitle forState:UIControlStateSelected | UIControlStateHighlighted];
        [button setTitleColor:[UIColor bjl_redColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor bjl_redColor] forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    if (selectedImageName) {
        UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
        [button setImage:selectedImage forState:UIControlStateSelected];
        [button setImage:selectedImage forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    button.midSpace = BJLViewSpaceM;
    return button;
}

- (void)makeConstraints {
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.backgroundView);
        make.top.equalTo(self.backgroundView).with.offset(BJLViewSpaceM);
        make.bottom.equalTo(self.backgroundView).with.offset(- (BJLViewSpaceM + 6.0)); // 6.0: arrow size
    }];
    
    UIButton *last = nil;
    NSArray<UIButton *> *buttons = (self.isTeacher
                                    ? @[self.noticeButton, self.serverRecordingButton/* , self.helpButton */, self.settingsButton]
                                    : @[self.noticeButton/* , self.helpButton */, self.settingsButton]);
    for (UIButton *button in buttons) {
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            if (!last) {
                make.left.equalTo(self.contentView).with.offset(BJLViewSpaceM + BJLViewSpaceS);
            }
            else {
                make.left.equalTo(last.mas_right).with.offset(BJLViewSpaceM);
            }
            make.width.equalTo(@(BJLButtonSizeM + BJLViewSpaceS * 2));
            make.top.equalTo(self.contentView).with.offset(BJLViewSpaceL);
            make.bottom.equalTo(self.contentView).with.offset(- (BJLViewSpaceM + BJLViewSpaceS));
        }];
        last = button;
    }
    [last mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(- BJLViewSpaceM);
    }];
}

- (void)updateArrowWithRight:(id)rightAttribute bottom:(id)bottomAttribute {
    [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(rightAttribute ?: self.view);
        make.bottom.equalTo(bottomAttribute ?: self.view);
    }];
}

- (void)makeActions {
    bjl_weakify(self);
    
    [self.noticeButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.noticeCallback) self.noticeCallback(sender);
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.serverRecordingButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.serverRecordingCallback) self.serverRecordingCallback(sender);
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.helpButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.helpCallback) self.helpCallback(sender);
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.settingsButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.settingsCallback) self.settingsCallback(sender);
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)setServerRecordingEnabled:(BOOL)enabled {
    self.serverRecordingButton.selected = enabled;
}

@end

NS_ASSUME_NONNULL_END
