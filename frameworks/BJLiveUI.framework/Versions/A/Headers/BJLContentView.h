//
//  BJLContentView.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-22.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLConstants.h>

#import "BJLViewImports.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLContentView : UIView

// contentView.superview is its container
@property (nonatomic, readonly, nullable) UIView *content;
@property (nonatomic, readonly) BJLContentMode contentMode;
@property (nonatomic, readonly) CGFloat aspectRatio;

@property (nonatomic, copy, nullable) void (^toggleTopBarCallback)(id _Nullable sender);
@property (nonatomic, copy, nullable) void (^showMenuCallback)(id _Nullable sender);

@property (nonatomic) BOOL showsPageControlButton;
@property (nonatomic) NSInteger pageIndex, pageCount;
@property (nonatomic, copy, nullable) void (^pageControlCallback)(id _Nullable sender);

@property (nonatomic) BOOL showsClearDrawingButton;
@property (nonatomic, copy, nullable) void (^clearDrawingCallback)(id _Nullable sender);

/**
 #return animateFinish 动画结束时调用，动画结束前请勿调用其它方法，否则结果无法预期
 */
- (void (^)(void))animateUpdateContent:(UIView *)content
                           contentMode:(BJLContentMode)contentMode
                           aspectRatio:(CGFloat)aspectRatio;
- (void)updateContent:(UIView *)content
          contentMode:(BJLContentMode)contentMode
          aspectRatio:(CGFloat)aspectRatio;

- (void)updateWithContentMode:(BJLContentMode)contentMode
                  aspectRatio:(CGFloat)aspectRatio;

- (void)removeContent;

@end

NS_ASSUME_NONNULL_END
