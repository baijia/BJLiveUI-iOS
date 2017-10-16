//
//  UITableView+HeightCache.h
//  Pods
//
//  Created by HuangJie on 2017/6/29.
//  Copyright © 2017年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+HeightCacheCell.h"

@interface UITableView (HeightCache)

/**
 获取 cell 高度

 #param key           自定义的缓存标识符
 #param identifier    cell 的 identifier
 #param configuration 用于计算 cell 高度的设置
 #return              cell 高度
 */
- (CGFloat)bjl_cellHeightWithKey:(NSString *)key
                      identifier:(NSString *)identifier
                   configuration:(void (^)(id))configuration;

/**
 清空缓存
 */
- (void)clearHeightCaches;

@end
