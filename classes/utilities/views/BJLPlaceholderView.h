//
//  BJLPlaceholderView.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-04-11.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BJLPlaceholderView;

typedef void (^BJLPlaceholderViewLayoutBlock)(BJLPlaceholderView *placeholder, UIView *superview);
typedef void (^BJLPlaceholderViewTapBlock)(BJLPlaceholderView *placeholder);

@interface BJLPlaceholderView : UIView

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UILabel *textLabel;

+ (instancetype)showInSuperview:(UIView *)superview
                          image:(UIImage *)image
                           text:(NSString *)text
                       tapBlock:(nullable BJLPlaceholderViewTapBlock)tapBlock;
+ (instancetype)showInSuperview:(UIView *)superview
                          image:(UIImage *)image
                           text:(NSString *)text
                    layoutBlock:(nullable BJLPlaceholderViewLayoutBlock)layoutBlock
                       tapBlock:(nullable BJLPlaceholderViewTapBlock)tapBlock;

+ (void)removeAllFromSuperview:(UIView *)superview;

@end

NS_ASSUME_NONNULL_END
