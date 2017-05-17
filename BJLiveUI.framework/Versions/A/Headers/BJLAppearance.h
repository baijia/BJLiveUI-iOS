//
//  BJLAppearance.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-10.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLButton.h"

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat BJLViewSpaceS, BJLViewSpaceM, BJLViewSpaceL;
extern const CGFloat BJLControlSize;

extern const CGFloat BJLButtonSizeM, BJLButtonSizeL, BJLButtonCornerRadius;
extern const CGFloat BJLBadgeSize;
extern const CGFloat BJLScrollIndicatorSize;

extern const CGFloat BJLAnimateDurationS, BJLAnimateDurationM;
extern const CGFloat BJLRobotDelayS, BJLRobotDelayM;

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

@interface BJLButton (BJLButtons)

+ (instancetype)makeTextButtonDestructive:(BOOL)destructive;
+ (instancetype)makeRoundedRectButtonHighlighted:(BOOL)highlighted;

@end

NS_ASSUME_NONNULL_END
