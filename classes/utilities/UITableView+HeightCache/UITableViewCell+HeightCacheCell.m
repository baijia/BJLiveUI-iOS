//
//  UITableViewCell+HeightCacheCell.m
//  Pods
//
//  Created by HuangJie on 2017/6/29.
//  Copyright © 2017年 BaijiaYun. All rights reserved.
//

#import "UITableViewCell+HeightCacheCell.h"
#import <objc/runtime.h>

@implementation UITableViewCell (HeightCacheCell)

#pragma mark - setters and getters
- (BOOL)autoSizing {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setAutoSizing:(BOOL)autoSizing {
    objc_setAssociatedObject(self, @selector(autoSizing), @(autoSizing), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)usedForCalculating {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setUsedForCalculating:(BOOL)usedForCalculating {
    objc_setAssociatedObject(self, @selector(usedForCalculating), @(usedForCalculating), OBJC_ASSOCIATION_RETAIN);
}

@end
