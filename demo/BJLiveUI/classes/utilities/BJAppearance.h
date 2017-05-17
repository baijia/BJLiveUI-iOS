//
//  BJAppearance.h
//  LivePlayerApp
//
//  Created by MingLQ on 2016-08-20.
//  Copyright © 2016年 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/UIKit+BJL_M9Dev.h>

#define BJOnePixel ({ 1.0 / [UIScreen mainScreen].scale; })

@interface UIColor (BJColors)

+ (instancetype)bj_brandColor;

+ (instancetype)bj_grayBackgroundColor;
+ (instancetype)bj_grayBorderColor;
+ (instancetype)bj_navigationBarTintColor;

+ (instancetype)bj_darkGrayTextColor;
+ (instancetype)bj_midGrayTextColor;
+ (instancetype)bj_lightGrayTextColor;
+ (instancetype)bj_linkTextColor;

+ (instancetype)bj_redColor;

@end
