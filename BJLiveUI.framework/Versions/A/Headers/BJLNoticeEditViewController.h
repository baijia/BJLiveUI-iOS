//
//  BJLNoticeEditViewController.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-08.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLViewControllerImports.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLNoticeEditViewController : UIViewController <
UITextFieldDelegate,
UITextViewDelegate,
BJLRoomChildViewController>

@property (nonatomic, copy, nullable) void (^finishCallback)(id _Nullable sender);

@end

NS_ASSUME_NONNULL_END
