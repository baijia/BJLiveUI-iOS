//
//  BJLTopBarView.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-01-25.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLViewImports.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLTopBarView : UIView

@property (nonatomic, copy, nullable) void (^exitCallback)(id _Nullable sender);

@property (nonatomic, readonly) UIView *customContainerView;

@end

NS_ASSUME_NONNULL_END
