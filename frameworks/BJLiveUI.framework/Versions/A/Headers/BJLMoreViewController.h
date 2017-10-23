//
//  BJLMoreViewController.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-04.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLViewControllerImports.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLMoreViewController : UIViewController

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithForTeacher:(BOOL)isTeacher NS_DESIGNATED_INITIALIZER;

- (void)updateArrowWithRight:(id)rightAttribute bottom:(id)bottomAttribute;

@property (nonatomic, copy, nullable) void (^noticeCallback)(id _Nullable sender);
@property (nonatomic, copy, nullable) void (^serverRecordingCallback)(id _Nullable sender);
@property (nonatomic, copy, nullable) void (^helpCallback)(id _Nullable sender);
@property (nonatomic, copy, nullable) void (^settingsCallback)(id _Nullable sender);
- (void)setServerRecordingEnabled:(BOOL)enabled;

/**
 关闭回调
 需在 closeCallback 中自行关闭
 */
@property (nonatomic, copy, nullable) void (^closeCallback)(id _Nullable sender);

@end

NS_ASSUME_NONNULL_END
