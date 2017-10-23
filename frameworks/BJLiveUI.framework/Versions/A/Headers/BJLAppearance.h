//
//  BJLAppearance.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-10.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveBase/UIKit+BJL_M9Dev.h>

NS_ASSUME_NONNULL_BEGIN

#define BJLViewSpaceS   5.0
#define BJLViewSpaceM   10.0
#define BJLViewSpaceL   15.0

// 44.0 - 12.0 = 32.0 for verInsets.top, horInsets.left, horInsets.right
#define BJLiPhoneXInsetsAdjustment 12.0

#define BJLControlSize  44.0

#define BJLButtonSizeS  30.0
#define BJLButtonSizeM  36.0
#define BJLButtonSizeL  46.0
#define BJLButtonCornerRadius 3.0

#define BJLBadgeSize    20.0
#define BJLScrollIndicatorSize 8.5 // 8.5 = 2.5 + 3.0 * 2

#define BJLAnimateDurationS 0.2
#define BJLAnimateDurationM 0.4
#define BJLRobotDelayS  1.0
#define BJLRobotDelayM  2.0

#define UIPopoverArrowDirectionVertical (UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown)

#pragma mark -

@interface UIColor (BJLColorLegend)

// common
@property (class, nonatomic, readonly) UIColor
*bjl_darkGrayBackgroundColor,
*bjl_lightGrayBackgroundColor,

*bjl_darkGrayTextColor,
*bjl_grayTextColor,
*bjl_lightGrayTextColor,

*bjl_grayBorderColor,
*bjl_grayLineColor,
*bjl_grayImagePlaceholderColor, // == bjl_grayLineColor

*bjl_blueBrandColor,
*bjl_orangeBrandColor,
*bjl_redColor;

// dim
@property (class, nonatomic, readonly) UIColor
*bjl_lightMostDimColor, // black-0.2
*bjl_lightDimColor, // black-0.5
*bjl_dimColor,      // black-0.6
*bjl_darkDimColor;  // black-0.7

@end

#pragma mark -

@interface UIButton (BJLButtons)

+ (instancetype)makeTextButtonDestructive:(BOOL)destructive;
+ (instancetype)makeRoundedRectButtonHighlighted:(BOOL)highlighted;

@end

NS_ASSUME_NONNULL_END
