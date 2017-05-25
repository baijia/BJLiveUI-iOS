//
//  BJLPreviewsView.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-20.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLViewImports.h"

NS_ASSUME_NONNULL_BEGIN

/**
 auto hidden when no previews
 */
@interface BJLPreviewsView : UIView

- (BOOL)containsPreview:(UIView *)preview;

/**
 @return preview.superview after added
 */
- (nullable UIView *)addPreview:(UIView *)preview aspectRatio:(CGFloat)aspectRatio title:(nullable NSString *)title;

- (void)updatePreview:(UIView *)preview aspectRatio:(CGFloat)aspectRatio title:(nullable NSString *)title;

/**
 currPreview 不为 nil 时 replace，否则 add
 @return animateFinish  动画结束回调
 !!!: 动画结束时调用回调，在此之前请勿调用当前对象的其它方法，否则结果无法预期
 */
- (void (^)())animateReplacePreview:(nullable UIView *)currPreview
                        nextPreview:(nullable UIView *)nextPreview
                        aspectRatio:(CGFloat)aspectRatio
                              title:(nullable NSString *)title;

- (void)removePreview:(UIView *)preview;

@property (nonatomic, copy, nullable) void (^tapCallback)(UIView *preview);
@property (nonatomic, copy, nullable) void (^doubleTapCallback)(UIView *preview);
@property (nonatomic, copy, nullable) void (^contentSizeChangedCallback)(id _Nullable sender);

@end

NS_ASSUME_NONNULL_END
