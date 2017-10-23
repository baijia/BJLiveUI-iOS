//
//  BJLLoadingViewController.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-01-19.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLViewControllerImports.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BJLLoadingViewControllerDelegate;

@interface BJLLoadingViewController : UIViewController <BJLRoomChildViewController>

@property (nonatomic, readonly, getter=isHidden) BOOL hidden;

#pragma mark - callback

@property (nonatomic, copy, nullable) void (^showCallback)(BOOL reloading);
@property (nonatomic, copy, nullable) void (^hideCallback)(void);
@property (nonatomic, copy, nullable) void (^hideCallbackWithError)(BJLError * _Nullable error);
@property (nonatomic, copy, nullable) void (^exitCallback)(void);

@end

NS_ASSUME_NONNULL_END
