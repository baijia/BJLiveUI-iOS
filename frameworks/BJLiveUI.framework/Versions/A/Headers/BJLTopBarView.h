//
//  BJLTopBarView.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-01-25.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLViewImports.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLTopBarView : UIView

@property (nonatomic, readonly) UIImageView *backgroundView;
@property (nonatomic, readonly) UIView *customContainerView;

@property (nonatomic, copy, nullable) void (^exitCallback)(id _Nullable sender);

@end

NS_ASSUME_NONNULL_END
