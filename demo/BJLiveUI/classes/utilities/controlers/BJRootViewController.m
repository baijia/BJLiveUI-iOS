//
//  BJRootViewController.m
//  LivePlayerApp
//
//  Created by MingLQ on 2016-08-22.
//  Copyright © 2016年 Baijia Cloud. All rights reserved.
//

#import <M9Dev/M9Dev.h>

#import "BJRootViewController.h"

@interface BJRootViewController ()

@property (nonatomic, readwrite) UIViewController *activeViewController;

@end

@implementation BJRootViewController

+ (instancetype)sharedInstance {
    static BJRootViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [BJRootViewController new];
    });
    return sharedInstance;
}

- (void)switchViewController:(UIViewController *)viewController
                  completion:(void (^)(BOOL finished))completion {
    [self.activeViewController removeFromParentViewControllerAndSuperiew];
    [self addChildViewController:viewController superview:self.view];
    self.activeViewController = viewController;
    [self setNeedsStatusBarAppearanceUpdate];
    [UIViewController attemptRotationToDeviceOrientation];
    if (completion) completion(YES);
    
    /* 切换动画
    if (!self.activeViewController) {
        [self addChildViewController:viewController superview:self.view];
        self.activeViewController = viewController;
        [self setNeedsStatusBarAppearanceUpdate];
        return;
    }
    
    [UIView transitionFromView:self.activeViewController.view
                        toView:viewController.view
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    completion:^(BOOL finished) {
                        [self.activeViewController removeFromParentViewControllerAndSuperiew];
                        [self addChildViewController:viewController superview:self.view];
                        self.activeViewController = viewController;
                        [self setNeedsStatusBarAppearanceUpdate];
                        if (completion) completion(finished);
                    }]; // */
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.activeViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.activeViewController;
}

- (BOOL)shouldAutorotate {
    // NSLog(@"shouldAutorotate: %d - %@", shouldAutorotate, self.activeViewController);
    return (self.activeViewController
            ? [self.activeViewController shouldAutorotate]
            : [super shouldAutorotate]);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    // NSLog(@"orientations: %d - %@", orientations, self.activeViewController);
    return (self.activeViewController
            ? [self.activeViewController supportedInterfaceOrientations]
            : [super supportedInterfaceOrientations]);
}

@end
