//
//  UITableView+HeightCache.m
//  Pods
//
//  Created by HuangJie on 2017/6/29.
//  Copyright © 2017年 BaijiaYun. All rights reserved.
//

#import "UITableView+HeightCache.h"
#import "BJLTableViewHeightCache.h"
#import <objc/runtime.h>

@implementation UITableView (HeightCache)

#pragma mark - public
- (CGFloat)bjl_cellHeightWithKey:(NSString *)key
                      identifier:(NSString *)identifier
                   configuration:(void (^)(id))configuration {
    // 宽度为 0
    if (self.bounds.size.width <= 0.0) {
        return 0;
    }
    
    // key 不可用
    if (!key || key.length <= 0) {
        return 0;
    }
    
    // 从缓存中取 cell 高度
    CGFloat height = [self.cache heightCacheForKey:key];
    if (height <= 0) {
        // 高度缓存不存在或非法，计算高度
        height = [self bjl_calculateCellHeightWithIdentyfier:identifier configuration:configuration];
        // 缓存高度
        [self.cache cacheHeight:height withKey:key];
    }
    return height;
}

- (void)clearHeightCaches {
    [self.cache removeAllCaches];
}

#pragma mark - private
// 取出 cell 并进行指定处理后，计算高度
- (CGFloat)bjl_calculateCellHeightWithIdentyfier:(NSString *)identifier
                                   configuration:(void(^)(id cell))configuration {
    if (!identifier || identifier.length <= 0) {
        return 0;
    }
    UITableViewCell *cell = [self bjl_cellForCalculatingWithIdentifier:identifier];
    [cell prepareForReuse];
    if (configuration) {
        configuration(cell);
    }
    return [self bjl_calculateCellHeightWithCell:cell];
}

// 从重用池中返回计算用的 cell
- (__kindof UITableViewCell *)bjl_cellForCalculatingWithIdentifier:(NSString *)identifier {
    if (!identifier || identifier.length <= 0) {
        return nil;
    }
    
    // 获取只用于计算高度的 cell 的字典
    NSMutableDictionary<NSString *, UITableViewCell *> *dictionaryForCalculatingCells = objc_getAssociatedObject(self, _cmd);
    if (!dictionaryForCalculatingCells) {
        dictionaryForCalculatingCells = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, dictionaryForCalculatingCells, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UITableViewCell *cell = [dictionaryForCalculatingCells objectForKey:identifier];
    if (!cell || ![cell isKindOfClass:[UITableViewCell class]]) {
        // 从重用池取一个 cell 用来计算， 必须以本方式从重用池中取，若以 indexPath 方式取则会由于 heightForRowAtIndexPath 方法会造成循环
        cell = [self dequeueReusableCellWithIdentifier:identifier];
        if (cell) {
            cell.contentView.translatesAutoresizingMaskIntoConstraints = NO; // 开启约束
            cell.usedForCalculating = YES;
            [dictionaryForCalculatingCells setObject:cell forKey:identifier];
        }
    }
    return cell;
}

// 根据 cell 计算高度
- (CGFloat)bjl_calculateCellHeightWithCell:(UITableViewCell *)cell {
    CGFloat contentViewWidth = CGRectGetWidth(self.frame);
    CGRect cellBounds = cell.bounds;
    cellBounds.size.width = contentViewWidth;
    cell.bounds = cellBounds;
    
    // 根据辅助视图校正 contentViewWidth
    CGFloat accessoryWidth = 0;
    if (cell.accessoryView) {
        accessoryWidth = CGRectGetWidth(cell.accessoryView.frame) + 16;
    }
    else {
        static const CGFloat systemAccessoryWidths[] = {
            [UITableViewCellAccessoryNone] = 0,
            [UITableViewCellAccessoryDisclosureIndicator] = 34,
            [UITableViewCellAccessoryDetailDisclosureButton] = 68,
            [UITableViewCellAccessoryCheckmark] = 40,
            [UITableViewCellAccessoryDetailButton] = 48
        };
        accessoryWidth = systemAccessoryWidths[cell.accessoryType];
    }
    contentViewWidth -= accessoryWidth;
    
    CGFloat height = 0;
    //自动计算
    if (cell.autoSizing && contentViewWidth > 0) {
        // 创建约束
        NSLayoutConstraint *widthConatraint = [NSLayoutConstraint constraintWithItem:cell.contentView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:1.0 constant:contentViewWidth];
        // 系统版本高于 10.2 的特殊处理
        static BOOL isSystemVersionEqualOrGreaterThan10_2 = 0;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            isSystemVersionEqualOrGreaterThan10_2 = [UIDevice.currentDevice.systemVersion compare:@"10.2" options:NSNumericSearch] != NSOrderedAscending;
        });
        NSArray<NSLayoutConstraint *> *edgeConstraints;
        if (isSystemVersionEqualOrGreaterThan10_2) {
            widthConatraint.priority = UILayoutPriorityRequired - 1;
            
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView
                                                                              attribute:NSLayoutAttributeLeft
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:cell
                                                                              attribute:NSLayoutAttributeLeft
                                                                             multiplier:1.0
                                                                               constant:0];
            NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView
                                                                               attribute:NSLayoutAttributeRight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:cell
                                                                               attribute:NSLayoutAttributeRight
                                                                              multiplier:1.0
                                                                                constant:accessoryWidth];
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:cell
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0
                                                                              constant:0];
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView
                                                                                attribute:NSLayoutAttributeBottom
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:cell
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1.0
                                                                                 constant:0];
            edgeConstraints = @[leftConstraint, rightConstraint, topConstraint, bottomConstraint];
            [cell addConstraints:edgeConstraints];
        }
        
        // 添加约束，计算高度
        [cell.contentView addConstraint:widthConatraint];
        height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        // 移除约束
        [cell.contentView removeConstraint:widthConatraint];
    }
    
    if (height == 0) {
        // 如果约束错误可能导致计算结果为0，或者 autoSize 为 NO，自适应模式再次计算
        // 需要重写 sizeThatFits: 方法以返回期望的高度值
        height = [cell sizeThatFits:CGSizeMake(contentViewWidth, 0)].height;
    }
    
    if (height == 0) {
        // 如果计算结果仍然为0, 则给出默认高度
        height = 44;
    }
    
    if (self.separatorStyle != UITableViewCellSelectionStyleNone) {
        //如果不为无分割线模式则添加分割线高度
        height += 1.0 / [UIScreen mainScreen].scale;
    }
    return height;
}

#pragma mark - setters and getters
- (BJLTableViewHeightCache *)cache {
    BJLTableViewHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [[BJLTableViewHeightCache alloc] init];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

- (void)setCache:(BJLTableViewHeightCache *)cache {
    objc_setAssociatedObject(self, @selector(cache), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
