//
//  BJLImageViewController.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-22.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// TODO: MingLQ - hide & hideCallback
// showCallback/hideCallback: wants to show/hide
// shownCallback/hiddenCallback: did show/hide
@interface BJLImageViewController : UIViewController

@property (nonatomic, readonly) UIImageView *imageView;

@property (nonatomic, copy, nullable) void (^hideCallback)(id _Nullable sender);

- (void)hide;

@end

NS_ASSUME_NONNULL_END
