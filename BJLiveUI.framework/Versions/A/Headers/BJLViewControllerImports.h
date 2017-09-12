//
//  BJLViewControllerImports.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-08.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <libextobjc/EXTScope.h>
#import <Masonry/Masonry.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <YYModel/YYModel.h>

#import <BJLiveCore/BJLiveCore.h>
#import <BJLiveCore/BJLScrollViewController.h>
#import <BJLiveCore/BJLTableViewController.h>
#import <BJLiveCore/BJLWebImage.h>
#import <BJLiveCore/NSObject+BJL_M9Dev.h>
#import <BJLiveCore/NSObject+BJLObserving.h>
#import <BJLiveCore/UIKit+BJL_M9Dev.h>
#import <BJLiveCore/UIKit+BJLHandler.h>

#import "BJLTableViewController+style.h"

#import "BJLAppearance.h"
#import "BJLButton.h"
#import "BJLPlaceholderView.h"
#import "BJLProgressHUD.h"
#import "BJLHitTestView.h"
#import "BJLTextField.h"

#import "Masonry+BJLExt.h"
#import "UIAlertController+BJLAddAction.h"
#import "UIControl+BJLManagedState.h"

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
 *  @weakify(self);
 *  [self bjl_kvo:BJLMakeProperty(self.room, vmsAvailable)
 *         filter:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
 *             // @strongify(self);
 *             return now.boolValue;
 *         }
 *       observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
 *           @strongify(self);
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
