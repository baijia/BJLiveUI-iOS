//
//  UIAlertController+BJLAddAction.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-01-20.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (BJLAddAction)

- (UIAlertAction *)bjl_addActionWithTitle:(nullable NSString *)title
                                    style:(UIAlertActionStyle)style
                                  handler:(void (^ __nullable)(UIAlertAction *action))handler;

@end

NS_ASSUME_NONNULL_END
