//
//  BJLViewControllerImports.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-08.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Masonry/Masonry.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <YYModel/YYModel.h>

#import <BJLiveBase/BJL_EXTScope.h>
#import <BJLiveBase/BJLHitTestView.h>
#import <BJLiveBase/BJLProgressHUD.h>
#import <BJLiveBase/BJLScrollViewController.h>
#import <BJLiveBase/BJLTableViewController.h>
#import <BJLiveBase/BJLWebImage.h>
#import <BJLiveBase/Masonry+BJLAdditions.h>
#import <BJLiveBase/NSObject+BJL_M9Dev.h>
#import <BJLiveBase/NSObject+BJLObserving.h>
#import <BJLiveBase/UIAlertController+BJLAddAction.h>
#import <BJLiveBase/UIControl+BJLManagedState.h>
#import <BJLiveBase/UIKit+BJL_M9Dev.h>
#import <BJLiveBase/UIKit+BJLHandler.h>

#import <BJLiveCore/BJLiveCore.h>

#import "BJLTableViewController+style.h"

#import "BJLAppearance.h"
#import "BJLButton.h"
#import "BJLPlaceholderView.h"
#import "BJLTextField.h"


NS_ASSUME_NONNULL_BEGIN

/**
 用于判断 BJLiveUI 是否使用横屏模式，BJLiveUI 以外可能不适用
 */
static inline BOOL BJLIsHorizontalUI(id<UITraitEnvironment> traitEnvironment) {
    return !(traitEnvironment.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact
             && traitEnvironment.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular);
}

@protocol BJLRoomChildViewController <NSObject>

@required

/** 初始化
 注意需要 KVO 监听 `room.vmsAvailable` 属性，当值为 YES 时 room 的 view-model 才可用
 *  bjl_weakify(self);
 *  [self bjl_kvo:BJLMakeProperty(self.room, vmsAvailable)
 *         filter:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
 *             // bjl_strongify(self);
 *             return now.boolValue;
 *         }
 *       observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
 *           bjl_strongify(self);
 *           // room 的 view-model 可用
 *           return NO; // 停止监听 vmsAvailable
 *       }];
 u need: 
 *  @property (nonatomic, readonly, weak) BJLRoom *room;
 *  self->_room = room;
 */
- (instancetype)initWithRoom:(BJLRoom *)room;

@end

@interface UIViewController (BJLRoomActions)

- (void)showProgressHUDWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
