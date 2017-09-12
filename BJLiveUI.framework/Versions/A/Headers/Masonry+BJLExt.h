//
//  Masonry+BJLExt.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-04-05.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @see https://github.com/SnapKit/Masonry/pull/388
 */
@interface MASConstraint (BJLExt)

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (MASConstraint * (^)(CGFloat inset))bjl_inset;

/**
 *	Modifies the NSLayoutConstraint constant,
 *  only affects MASConstraints in which the first item's NSLayoutAttribute is one of the following
 *  NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight
 */
- (void)bjl_setInset:(CGFloat)inset;

- (MASConstraint * (^)())bjl_priorityRequired;

@end

NS_ASSUME_NONNULL_END
