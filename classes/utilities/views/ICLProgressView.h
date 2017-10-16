//
//  ICLProgressView.h
//  ICLProgressView
//
//  Created by MingLQ on 2017-01-14.
//  Copyright © 2017 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 iCloud style loading
 */
@interface ICLProgressView : UIView

@property (nonatomic) double progress;

@property (nonatomic) CGFloat size; // default: ICLProgressSizeM, min: 10.0
@property (nonatomic, null_resettable) UIColor *color; // default: #7B7B7B

@end

/**
 S: 14.0 + #FFFFFF + black shadow
 M: 38.0 + #7B7B7B
 */
extern const CGFloat ICLProgressSizeS, ICLProgressSizeM;

NS_ASSUME_NONNULL_END
