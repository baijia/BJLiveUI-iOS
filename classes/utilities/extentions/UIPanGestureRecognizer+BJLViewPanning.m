//
//  UIPanGestureRecognizer+BJLViewPanning.m
//  M9Dev
//
//  Created by MingLQ on 2017-03-30.
//  Copyright (c) 2017 MingLQ <minglq.9@gmail.com>. Released under the MIT license.
//

#import "UIPanGestureRecognizer+BJLViewPanning.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIPanGestureRecognizer (BJLViewPanning)

+ (instancetype)bjl_gestureWithHandlerDelegate:(id<BJLPanGestureRecognizerDelegate>)delegate {
    UIPanGestureRecognizer *gesture = [self new];
    [gesture bjl_addHandlerWithDelegate:delegate];
    return gesture;
}

- (id)bjl_addHandlerWithDelegate:(id<BJLPanGestureRecognizerDelegate>)delegate {
    __block UIView * __weak view = nil;
    __block CGPoint origin = CGPointZero;
    __block CGPoint translation = CGPointZero;
    
    typeof(delegate) __weak __delegate__ = delegate;
    return [self bjl_addHandler:^(__kindof UIGestureRecognizer * _Nullable gesture) {
        typeof(__delegate__) __strong delegate = __delegate__;
        
        if (gesture.state == UIGestureRecognizerStateBegan) {
            view = [delegate bjl_viewIfPanGestureShouldBegin:gesture];
        }
        
        if (!view || !delegate) {
            return;
        }
        
        BOOL reset = NO;
        
        if (gesture.state == UIGestureRecognizerStateBegan) {
            translation = CGPointZero; // init
            if ([delegate respondsToSelector:@selector(bjl_panGestureBegan:view:)]) {
                origin = [delegate bjl_panGestureBegan:gesture view:view];
            }
        }
        else if (gesture.state == UIGestureRecognizerStateChanged) {
            translation = [gesture translationInView:gesture.view]; // update
            if ([delegate respondsToSelector:@selector(bjl_panGestureChanged:view:origin:translation:)]) {
                [delegate bjl_panGestureChanged:gesture view:view origin:origin translation:translation];
            }
        }
        else if (gesture.state == UIGestureRecognizerStateEnded) {
            if ([delegate respondsToSelector:@selector(bjl_panGestureEnded:view:origin:direction:)]) {
                CGPoint velocity = [gesture velocityInView:gesture.view]; // points/second
                CGFloat minTranslation = 20.0, minVelocity = 500.0;
                UISwipeGestureRecognizerDirection direction = (UISwipeGestureRecognizerDirection)0;
                // TODO: ABS(translation.x) + ABS(velocity.x) * 0.1? > CGRectGetWidth(view.frame) / 2)
                if (ABS(velocity.x) > minVelocity) {
                    direction |= (velocity.x > 0.0
                                  ? UISwipeGestureRecognizerDirectionRight
                                  : UISwipeGestureRecognizerDirectionLeft);
                }
                else if (ABS(translation.x) > MAX(minTranslation, CGRectGetWidth(view.frame) / 2)) {
                    direction |= (translation.x > 0
                                  ? UISwipeGestureRecognizerDirectionRight
                                  : UISwipeGestureRecognizerDirectionLeft);
                }
                if (ABS(velocity.y) > minVelocity) {
                    direction |= (velocity.y > 0.0
                                  ? UISwipeGestureRecognizerDirectionDown
                                  : UISwipeGestureRecognizerDirectionUp);
                }
                else if (ABS(translation.y) > MAX(minTranslation, CGRectGetHeight(view.frame) / 2)) {
                    direction |= (translation.y > 0.0
                                  ? UISwipeGestureRecognizerDirectionDown
                                  : UISwipeGestureRecognizerDirectionUp);
                }
                [delegate bjl_panGestureEnded:gesture view:view origin:origin direction:direction];
            }
            reset = YES;
        }
        else if (gesture.state == UIGestureRecognizerStateCancelled) {
            if ([delegate respondsToSelector:@selector(bjl_panGestureCancelled:view:origin:)]) {
                [delegate bjl_panGestureCancelled:gesture view:view origin:origin];
            }
            reset = YES;
        }
        
        if (reset) {
            view = nil;
            origin = CGPointZero;
            translation = CGPointZero;
        }
    }];
}

@end

NS_ASSUME_NONNULL_END
