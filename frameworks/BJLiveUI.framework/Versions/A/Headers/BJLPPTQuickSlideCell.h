//
//  BJLPPTQuickSlideCell.h
//  Pods
//
//  Created by HuangJie on 2017/7/6.
//  Copyright © 2017年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLSlideshowVM.h>

@interface BJLPPTQuickSlideCell : UICollectionViewCell

/** 根据 slidePage 更新 cell 内容*/
- (void)updateContentWithSlidePage:(BJLSlidePage *)slidePage;

@end
