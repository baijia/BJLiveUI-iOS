//
//  BJLControlsViewController.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-15.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLViewControllerImports.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLControlsViewController : UIViewController <BJLRoomChildViewController>

@property (nonatomic) BOOL _penDisabled; // 可以在视频上画之后干掉

@property (nonatomic, readonly) MASViewAttribute *rightLayoutGuide, *bottomLayoutGuide;

@property (nonatomic, copy, nullable) void (^usersCallback)(id _Nullable sender);
@property (nonatomic, copy, nullable, setter=setPPTCallback:) void (^pptCallback)(id _Nullable sender);
@property (nonatomic, copy, nullable) void (^handCallback)(id _Nullable sender);
@property (nonatomic, copy, nullable) void (^penCallback)(id _Nullable sender);

@property (nonatomic, copy, nullable) void (^moreCallback)(UIButton * _Nullable button);
@property (nonatomic, copy, nullable) void (^rotateCallback)(id _Nullable sender);
@property (nonatomic, copy, nullable) void (^micCallback)(id _Nullable sender);
@property (nonatomic, copy, nullable) void (^cameraCallback)(id _Nullable sender);

@property (nonatomic, copy, nullable) void (^chatCallback)(id _Nullable sender);

@end

NS_ASSUME_NONNULL_END
