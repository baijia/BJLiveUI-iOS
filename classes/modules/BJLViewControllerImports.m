//
//  BJLViewControllerImports.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-08.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLViewControllerImports.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIViewController (BJLRoomActions)

- (void)showProgressHUDWithText:(NSString *)text {
    UIViewController *vc = [self targetViewControllerForAction:_cmd sender:self];
    if (vc && vc != self) {
        [vc showProgressHUDWithText:text];
    }
}

@end

NS_ASSUME_NONNULL_END
