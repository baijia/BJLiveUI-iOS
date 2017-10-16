//
//  BJLPlaceholderView.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-04-11.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "BJLPlaceholderView.h"

#import "BJLViewImports.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLPlaceholderView ()

@property (nonatomic, readwrite) UIImageView *imageView;
@property (nonatomic, readwrite) UILabel *textLabel;

@end

@implementation BJLPlaceholderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *contentView = ({
            UIView *view = [UIView new];
            [self addSubview:view];
            view;
        });
        self.imageView = ({
            UIImageView *imageView = [UIImageView new];
            [contentView addSubview:imageView];
            imageView;
        });
        self.textLabel = ({
            UILabel *label = [UILabel new];
            label.font = [UIFont systemFontOfSize:15.0];
            label.textColor = [UIColor bjl_lightGrayTextColor];
            [contentView addSubview:label];
            label;
        });
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.centerY.equalTo(self);
        }];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.equalTo(contentView);
        }];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).with.offset(BJLViewSpaceL);
            make.bottom.centerX.equalTo(contentView);
        }];
    }
    return self;
}

+ (instancetype)showInSuperview:(UIView *)superview
                          image:(UIImage *)image
                           text:(NSString *)text
                       tapBlock:(nullable BJLPlaceholderViewTapBlock)tapBlock {
    return [self showInSuperview:superview
                           image:image
                            text:text
                     layoutBlock:nil
                        tapBlock:tapBlock];
}

+ (instancetype)showInSuperview:(UIView *)superview
                          image:(UIImage *)image
                           text:(NSString *)text
                    layoutBlock:(nullable BJLPlaceholderViewLayoutBlock)layoutBlock
                       tapBlock:(nullable BJLPlaceholderViewTapBlock)tapBlock {
    BJLPlaceholderView *placeholder = [BJLPlaceholderView new];
    placeholder.imageView.image = image;
    placeholder.textLabel.text = text;
    [superview addSubview:placeholder];
    if (layoutBlock) {
        layoutBlock(placeholder, superview);
    }
    else {
        [placeholder mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superview.bjl_safeAreaLayoutGuide ?: superview);
        }];
    }
    if (tapBlock) {
        bjl_weakify(placeholder);
        [placeholder addGestureRecognizer:[UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer * _Nullable gesture) {
            bjl_strongify(placeholder);
            tapBlock(placeholder);
        }]];
    }
    return placeholder;
}

+ (void)removeAllFromSuperview:(UIView *)superview {
    for (UIView *view in superview.subviews) {
        if ([view isKindOfClass:[BJLPlaceholderView class]]) {
            [view removeFromSuperview];
        }
    }
}

@end

NS_ASSUME_NONNULL_END
