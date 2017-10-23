//
//  BJLTableViewHeightCache.h
//  Pods
//
//  Created by HuangJie on 2017/6/29.
//  Copyright © 2017年 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BJLTableViewHeightCache : NSObject

/**
 缓存高度

 #param height 高度值
 #param key    缓存标识符
 */
- (void)cacheHeight:(CGFloat)height withKey:(NSString *)key;

/**
 获取 key 对应的高度缓存

 #param key 缓存标识符
 #return    缓存的高度值
 */
- (CGFloat)heightCacheForKey:(NSString *)key;

/**
 key 对应缓存是否存在

 #param key 缓存标识符
 #return    是否存在
 */
- (BOOL)cacheExistForKey:(NSString *)key;

/**
 删除 key 对应的高度缓存

 #param key 缓存标识符
 */
- (void)removeCacheForKey:(NSString *)key;

/**
 删除所有高度缓存
 */
- (void)removeAllCaches;

@end
