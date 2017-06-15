//
//  BJLQuizWebViewController.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-05-31.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import "BJLWebViewController.h"
#import "BJLViewControllerImports.h"

#import "BJLOverlayViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLQuizWebViewController : BJLWebViewController

@property (nonatomic, copy, nullable) BJLError * _Nullable (^sendQuizMessageCallback)(NSDictionary<NSString *, id> *message);
@property (nonatomic, copy, nullable) void (^closeWebViewCallback)();

+ (nullable instancetype)instanceWithQuizMessage:(NSDictionary<NSString *, id> *)message roomVM:(BJLRoomVM *)roomVM;
+ (NSDictionary *)quizReqMessageWithUserNumber:(NSString *)userNumber;

- (void)didReceiveQuizMessage:(NSDictionary<NSString *, id> *)message;

@end

NS_ASSUME_NONNULL_END
