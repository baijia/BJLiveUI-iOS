//
//  BJLPPTManageViewController.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-18.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLViewControllerImports.h"

#import "BJL_iCloudLoading.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLPPTManageViewController : BJLTableViewController <
UITableViewDataSource,
UITableViewDelegate,
BJLRoomChildViewController,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
QBImagePickerControllerDelegate_iCloudLoading>

@property (nonatomic, copy, nullable) void (^uploadingCallback)(NSInteger failedCount, void (^ _Nullable retry)());

- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
- (instancetype)initWithRoom:(BJLRoom *)room NS_DESIGNATED_INITIALIZER;

- (void)startAllUploadingTasks;

@end

NS_ASSUME_NONNULL_END
