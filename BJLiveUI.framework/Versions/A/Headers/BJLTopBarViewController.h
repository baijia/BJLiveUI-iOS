//
//  BJLTopBarViewController.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-01-25.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLViewControllerImports.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLTopBarViewController : UIViewController <BJLRoomChildViewController>

@property (nonatomic, readonly) UIView *customContainerView;

#pragma mark - callback

@property (nonatomic, copy, nullable) void (^backCallback)(id _Nullable sender);
@property (nonatomic, copy, nullable) void (^showOnlineUsersCallback)(id _Nullable sender);

@end

NS_ASSUME_NONNULL_END
