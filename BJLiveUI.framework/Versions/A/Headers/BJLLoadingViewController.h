//
//  BJLLoadingViewController.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-01-19.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLViewControllerImports.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BJLLoadingViewControllerDelegate;

@interface BJLLoadingViewController : UIViewController <BJLRoomChildViewController>

#pragma mark - callback

@property (nonatomic, copy, nullable) void (^showCallback)(BOOL reloading);
@property (nonatomic, copy, nullable) void (^hideCallback)();
@property (nonatomic, copy, nullable) void (^hideCallbackWithError)(BJLError * _Nullable error);
@property (nonatomic, copy, nullable) void (^backCallback)();

@end

NS_ASSUME_NONNULL_END
