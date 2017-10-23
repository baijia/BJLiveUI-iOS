//
//  BJLProgressView.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-01-19.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLProgressView : UIView

@property (nonatomic) double progress;

@property (nonatomic, readwrite, null_resettable) UIColor *color; // default: #7B7B7B

@end

NS_ASSUME_NONNULL_END
