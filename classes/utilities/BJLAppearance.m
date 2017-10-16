//
//  BJLAppearance.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-10.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIColor (BJLColorLegend)

+ (UIColor *)bjl_darkGrayBackgroundColor {
    return [UIColor bjl_colorWithHex:0x1D1D1E];
}

+ (instancetype)bjl_lightGrayBackgroundColor {
    return [UIColor bjl_colorWithHex:0xF8F8F8];
}

+ (UIColor *)bjl_darkGrayTextColor {
    return [UIColor bjl_colorWithHex:0x3D3D3E];
}

+ (instancetype)bjl_grayTextColor {
    return [UIColor bjl_colorWithHex:0x6D6D6E];
}

+ (instancetype)bjl_lightGrayTextColor {
    return [UIColor bjl_colorWithHex:0x9D9D9E];
}

+ (instancetype)bjl_grayBorderColor {
    return [UIColor bjl_colorWithHex:0xCDCDCE];
}

+ (instancetype)bjl_grayLineColor {
    return [UIColor bjl_colorWithHex:0xDDDDDE];
}

+ (instancetype)bjl_grayImagePlaceholderColor {
    return [UIColor bjl_colorWithHex:0xEDEDEE];
}

+ (instancetype)bjl_blueBrandColor {
    return [UIColor bjl_colorWithHex:0x37A4F5];
}

+ (instancetype)bjl_orangeBrandColor {
    return [UIColor bjl_colorWithHex:0xFF9100];
}

+ (instancetype)bjl_redColor {
    return [UIColor bjl_colorWithHex:0xFF5850];
}

#pragma mark -

+ (UIColor *)bjl_lightMostDimColor {
    return [UIColor colorWithWhite:0.0 alpha:0.2];
}

+ (instancetype)bjl_lightDimColor {
    return [UIColor colorWithWhite:0.0 alpha:0.5];
}

+ (instancetype)bjl_dimColor {
    return [UIColor colorWithWhite:0.0 alpha:0.6];
}

+ (instancetype)bjl_darkDimColor {
    return [UIColor colorWithWhite:0.0 alpha:0.7];
}

@end

#pragma mark -

@implementation UIButton (BJLButtons)

+ (instancetype)makeTextButtonDestructive:(BOOL)destructive {
    UIButton *button = [self new];
    UIColor *titleColor = destructive ? [UIColor bjl_redColor] : [UIColor bjl_blueBrandColor];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setTitleColor:[titleColor colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    button.titleLabel.font = [UIFont systemFontOfSize:15.0];
    return button;
}

+ (instancetype)makeRoundedRectButtonHighlighted:(BOOL)highlighted {
    UIButton *button = [self new];
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    if (highlighted) {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor bjl_blueBrandColor];
    }
    else {
        [button setTitleColor:[UIColor bjl_grayTextColor] forState:UIControlStateNormal];
        button.layer.borderWidth = BJLOnePixel;
        button.layer.borderColor = [UIColor bjl_grayBorderColor].CGColor;
    }
    button.layer.cornerRadius = BJLButtonCornerRadius;
    button.layer.masksToBounds = YES;
    return button;
}

@end

NS_ASSUME_NONNULL_END
