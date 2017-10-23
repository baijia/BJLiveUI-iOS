//
//  BJLAnnularProgressView.h
//  ICLProgressView
//
//  Created by MingLQ on 2017-01-14.
//  Copyright © 2017 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLAnnularProgressView : UIView

@property (nonatomic) double progress;

@property (nonatomic) CGFloat size; // default: BJLProgressSizeM, min: 10.0
@property (nonatomic) CGFloat annularWidth; // 0.0_resettable, default: radius(size / 2) / 5, min: 1.0 / screenScale
@property (nonatomic, null_resettable) UIColor *color; // default: #7B7B7B

@end

/**
 S: 14.0 + #FFFFFF + black shadow
 M: 38.0 + #7B7B7B
 */
extern const CGFloat BJLProgressSizeS, BJLProgressSizeM;

NS_ASSUME_NONNULL_END
