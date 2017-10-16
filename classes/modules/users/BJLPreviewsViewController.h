//
//  BJLPreviewsViewController.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-06-05.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLViewControllerImports.h"

NS_ASSUME_NONNULL_BEGIN

@class BJLPreviewItem;

@interface BJLPreviewsViewController : UIViewController <
UICollectionViewDataSource,
UICollectionViewDelegate,
UIScrollViewDelegate,
BJLRoomChildViewController>

@property (nonatomic, readonly) UICollectionView *collectionView;
@property (nonatomic, readonly) UIImageView *backgroundView;
@property (nonatomic, readonly) UIButton *moreButton;

@property (nonatomic, readonly, nullable) BJLPreviewItem *fullScreenItem;
@property (nonatomic, readonly) NSInteger numberOfItems;

- (void)makeContentSize:(MASConstraintMaker *)make forHorizontal:(BOOL)isHorizontal;
- (CGFloat)viewHeightIfDisplay;

- (void)enterFullScreenWithPPTView;
- (void)showMenuForFullScreenItemSourceView:(nullable UIView *)sourceView;

@end

#pragma mark -

typedef NS_ENUM(NSInteger, BJLPreviewsType) {
    BJLPreviewsType_None,
    BJLPreviewsType_PPT,
    BJLPreviewsType_playing,
    BJLPreviewsType_recording
};

@interface BJLPreviewItem : NSObject

@property (nonatomic, readonly) BJLPreviewsType type;
@property (nonatomic, readonly, nullable) UIView *view; // || viewController
@property (nonatomic, readonly, nullable) UIViewController *viewController; // || view
@property (nonatomic, readonly) CGFloat aspectRatio; // maybe changed
@property (nonatomic, readonly) BJLContentMode contentMode;
@property (nonatomic, readonly, nullable) BJLUser *playingUser;

@end

NS_ASSUME_NONNULL_END
