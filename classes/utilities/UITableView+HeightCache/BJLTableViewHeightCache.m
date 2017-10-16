//
//  BJLTableViewHeightCache.m
//  Pods
//
//  Created by HuangJie on 2017/6/29.
//  Copyright © 2017年 BaijiaYun. All rights reserved.
//

#import "BJLTableViewHeightCache.h"

@interface BJLTableViewHeightCache ()

@property (nonatomic, strong) NSMutableDictionary *horizonHeightCache; // 横屏高度缓存
@property (nonatomic, strong) NSMutableDictionary *verticalHeightCache; // 竖屏高度缓存
@property (nonatomic, strong) NSMutableDictionary *currentHeightCache; // 当前高度缓存

@end

@implementation BJLTableViewHeightCache

#pragma mark - public

// 缓存高度
- (void)cacheHeight:(CGFloat)height withKey:(NSString *)key {
    [self.currentHeightCache setValue:@(height) forKey:key];
}

// 获取 key 对应的高度缓存
- (CGFloat)heightCacheForKey:(NSString *)key {
    NSNumber *number = [self.currentHeightCache valueForKey:key];
    if (number == nil || ![number isKindOfClass:[NSNumber class]]) {
        return -1;
    }
#if CGFLOAT_IS_DOUBLE
    return [number doubleValue];
#else
    return [number floatValue];
#endif
}

// key 对应缓存是否存在
- (BOOL)cacheExistForKey:(NSString *)key {
    NSNumber *number = [self.currentHeightCache valueForKey:key];
    return (number && [number isKindOfClass:[NSNumber class]]);
}

// 删除 key 对应的缓存
- (void)removeCacheForKey:(NSString *)key {
    [self.horizonHeightCache removeObjectForKey:key];
    [self.verticalHeightCache removeObjectForKey:key];
}

// 删除所有缓存
- (void)removeAllCaches {
    [self.horizonHeightCache removeAllObjects];
    [self.verticalHeightCache removeAllObjects];
}

#pragma mark - getters
- (NSMutableDictionary *)horizonHeightCache {
    if (!_horizonHeightCache) {
        _horizonHeightCache = [NSMutableDictionary dictionary];
    }
    return _horizonHeightCache;
}

- (NSMutableDictionary *)verticalHeightCache {
    if (!_verticalHeightCache) {
        _verticalHeightCache = [NSMutableDictionary dictionary];
    }
    return _verticalHeightCache;
}

// 根据当前横竖屏状态返回对应高度字典
- (NSMutableDictionary *)currentHeightCache {
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)?
                                         self.verticalHeightCache : self.horizonHeightCache;
}

@end
