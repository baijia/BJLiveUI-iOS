//
//  BJLUserCell.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-15.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <BJLiveCore/BJLUser.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BJLUserState) {
    BJLUserState_request,
    BJLUserState_speaking,
    BJLUserState_online,
    _BJLUserState_count
};

@interface BJLUserCell : UITableViewCell

@property (nonatomic, copy, nullable) void (^allowRequestCallback)(BJLUserCell * _Nullable cell);
@property (nonatomic, copy, nullable) void (^disallowRequestCallback)(BJLUserCell * _Nullable cell);
@property (nonatomic, copy, nullable) void (^toggleVideoPlayingRequestCallback)(BJLUserCell * _Nullable cell);
@property (nonatomic, copy, nullable) void (^stopSpeakingRequestCallback)(BJLUserCell * _Nullable cell);

- (void)updateWithUser:(nullable __kindof BJLUser *)user;

+ (NSString *)cellIdentifierForUserState:(BJLUserState)userState
                                userRole:(BJLUserRole)userRole
                                hasVideo:(BOOL)hasVideo
                            videoPlaying:(BOOL)videoPlaying
                    isTeacherOrAssistant:(BOOL)isTeacherOrAssistant;
+ (NSArray<NSString *> *)allCellIdentifiers;

@end

NS_ASSUME_NONNULL_END
