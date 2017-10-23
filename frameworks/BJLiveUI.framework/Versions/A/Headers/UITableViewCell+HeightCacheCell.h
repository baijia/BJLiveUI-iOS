//
//  UITableViewCell+HeightCacheCell.h
//  Pods
//
//  Created by HuangJie on 2017/6/29.
//  Copyright © 2017年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (HeightCacheCell)

/**
 是否使用自适应布局
 */
- (BOOL)autoSizing;
- (void)setAutoSizing:(BOOL)autoSizing;

/**
 是否为用于计算的 cell
 */
- (BOOL)usedForCalculating;
- (void)setUsedForCalculating:(BOOL)usedForCalculating;

@end
