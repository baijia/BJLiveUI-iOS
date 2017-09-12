//
//  BJLPPTQuickSlideViewController.h
//  Pods
//
//  Created by HuangJie on 2017/7/5.
//  Copyright © 2017年 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BJLViewControllerImports.h"

@interface BJLPPTQuickSlideViewController : UIViewController <
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
BJLRoomChildViewController>

@property (nonatomic, copy, nullable) void (^selectPPTCallback)();

@end
