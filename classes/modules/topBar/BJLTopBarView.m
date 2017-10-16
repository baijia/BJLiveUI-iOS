//
//  BJLTopBarView.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-01-25.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLTopBarView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLTopBarView ()

@property (nonatomic, readwrite) UIImageView *backgroundView;
@property (nonatomic, readwrite) UIView *customContainerView;

@property (nonatomic) UIButton *exitButton;

@end

@implementation BJLTopBarView

#pragma mark - lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self makeSubviews];
        [self makeConstraints];
    }
    return self;
}

- (void)makeSubviews {
    self.backgroundView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.image = [UIImage imageNamed:@"bjl_bg_topbar"];
        [self addSubview:imageView];
        imageView;
    });
    
    self.exitButton = ({
        UIButton *button = [UIButton new];
        [button setImage:[UIImage imageNamed:@"bjl_ic_exit"] forState:UIControlStateNormal];
        [self addSubview:button];
        button;
    });
    bjl_weakify(self);
    [self.exitButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.exitCallback) self.exitCallback(sender);
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.customContainerView = ({
        UIView *view = [UIView new];
        view.clipsToBounds = YES;
        [self addSubview:view];
        view;
    });
}

- (void)makeConstraints {
    MASAttachKeys(self.backgroundView,
                  self.exitButton,
                  self.customContainerView);
    
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.exitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(self).offset(BJLViewSpaceM);
        // iOS 11
        if (self.bjl_safeAreaLayoutGuide) {
            if (bjl_iPhoneX()) {
                // ver
                make.top.equalTo(self.bjl_safeAreaLayoutGuide)/* .offset(- BJLViewSpaceS) */.priorityHigh();
            }
            else {
                make.top.equalTo(self.bjl_safeAreaLayoutGuide).priorityHigh();
            }
        }
        // earlier
        else {
            CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
            make.top.equalTo(self).with.offset(statusBarHeight);
        }
        make.right.equalTo(self.bjl_safeAreaLayoutGuide ?: self).with.offset(- BJLViewSpaceM);
    }];
    
    [self.customContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.exitButton);
        make.right.equalTo(self.exitButton.mas_left);
        make.left.greaterThanOrEqualTo(self).priorityHigh();
    }];
}

// 解决 button 超出 bounds 之后点击失效的问题
// @see https://stackoverflow.com/questions/5432995/interaction-beyond-bounds-of-uiview
// @see https://developer.apple.com/library/content/qa/qa2013/qa1812.html
- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    if (CGRectContainsPoint(self.exitButton.frame, point)) {
        return YES;
    }
    for (UIView *subview in self.customContainerView.subviews) {
        if (CGRectContainsPoint([self convertRect:subview.bounds fromView:subview], point)) {
            return YES;
        }
    }
    return [super pointInside:point withEvent:event];
}

@end

NS_ASSUME_NONNULL_END
