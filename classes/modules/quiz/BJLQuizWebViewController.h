//
//  BJLQuizWebViewController.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-05-31.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <BJLiveCore/BJLiveCore.h>
#import <BJLiveBase/BJLWebViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLQuizWebViewController : BJLWebViewController

@property (nonatomic, copy, nullable) BJLError * _Nullable (^sendQuizMessageCallback)(NSDictionary<NSString *, id> *message);
@property (nonatomic, copy, nullable) void (^closeWebViewCallback)(void);

+ (nullable instancetype)instanceWithQuizMessage:(NSDictionary<NSString *, id> *)message roomVM:(BJLRoomVM *)roomVM;
+ (NSDictionary *)quizReqMessageWithUserNumber:(NSString *)userNumber;

- (void)didReceiveQuizMessage:(NSDictionary<NSString *, id> *)message;

@end

NS_ASSUME_NONNULL_END
