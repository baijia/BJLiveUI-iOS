//
//  UIPanGestureRecognizer+BJLViewPanning.h
//  M9Dev
//
//  Created by MingLQ on 2017-03-30.
//  Copyright (c) 2017 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import <UIKit/UIKit.h>

#import <BJLiveBase/UIKit+BJLHandler.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BJLPanGestureRecognizerDelegate;

@interface UIPanGestureRecognizer (BJLViewPanning)

+ (instancetype)bjl_gestureWithHandlerDelegate:(id<BJLPanGestureRecognizerDelegate>)delegate;

- (id)bjl_addHandlerWithDelegate:(id<BJLPanGestureRecognizerDelegate>)delegate;

@end

#pragma mark -

@protocol BJLPanGestureRecognizerDelegate <NSObject>

@required
- (nullable UIView *)bjl_viewIfPanGestureShouldBegin:(__kindof UIPanGestureRecognizer *)gesture;

@optional
/**
 #return CGPoint origin of view
 */
- (CGPoint)bjl_panGestureBegan:(__kindof UIPanGestureRecognizer *)gesture view:(UIView *)view;
- (void)bjl_panGestureChanged:(__kindof UIPanGestureRecognizer *)gesture view:(UIView *)view origin:(CGPoint)origin translation:(CGPoint)translation;
- (void)bjl_panGestureEnded:(__kindof UIPanGestureRecognizer *)gesture view:(UIView *)view origin:(CGPoint)origin direction:(UISwipeGestureRecognizerDirection)direction;
- (void)bjl_panGestureCancelled:(__kindof UIPanGestureRecognizer *)gesture view:(UIView *)view origin:(CGPoint)origin;

@end

NS_ASSUME_NONNULL_END
