//
//  BJLUsersViewController.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-13.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLUsersViewController.h"

#import "BJLOverlayViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLUsersViewController ()

@property (nonatomic, readonly, weak) BJLRoom *room;

@end

@implementation BJLUsersViewController

#pragma mark - lifecycle & <BJLRoomChildViewController>

- (instancetype)initWithStyle:(UITableViewStyle)style {
    return nil;
}

- (instancetype)initWithRoom:(BJLRoom *)room {
    return [self initWithRoom:room userStates:BJLUserStateMask_all];
}

- (instancetype)initWithRoom:(BJLRoom *)room userStates:(BJLUserStateMask)userStates {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self->_room = room;
        self->_userStates = userStates;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self bjl_setupCommonTableView];
    
    self.tableView.allowsSelection = NO;
    for (NSString *cellIdentifier in [BJLUserCell allCellIdentifiers]) {
        [self.tableView registerClass:[BJLUserCell class] forCellReuseIdentifier:cellIdentifier];
    }
    
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room, vmsAvailable)
           filter:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
               // bjl_strongify(self);
               return now.boolValue;
           }
         observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             [self makeObserving];
             return YES;
         }];
}

- (void)didMoveToParentViewController:(nullable UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    
    if (!parent && !self.bjl_overlayContainerController) {
        return;
    }
    
    [self updateTitleWithOnlineUsersTotalCount];
    [self.bjl_overlayContainerController updateRightButtons:nil];
    [self.bjl_overlayContainerController updateFooterView:nil];
}

#pragma mark -

- (void)makeObserving {
    bjl_weakify(self);
    
    if (self.userStates & BJLUserStateMask_request) {
        [self bjl_kvo:BJLMakeProperty(self.room.speakingRequestVM, speakingRequestUsers)
             observer:^BOOL(id _Nullable old, id _Nullable now) {
                 bjl_strongify(self);
                 [self.tableView reloadData];
                 return YES;
             }];
    }
    
    if (self.userStates & BJLUserStateMask_speaking) {
        [self bjl_kvo:BJLMakeProperty(self.room.playingVM, playingUsers)
             observer:^BOOL(id _Nullable old, id _Nullable now) {
                 bjl_strongify(self);
                 [self.tableView reloadData];
                 return YES;
             }];
        [self bjl_kvo:BJLMakeProperty(self.room.playingVM, videoPlayingUsers)
             observer:^BOOL(id _Nullable old, id _Nullable now) {
                 bjl_strongify(self);
                 [self.tableView reloadData];
                 return YES;
             }];
        [self bjl_observe:BJLMakeMethod(self.room.playingVM, playingUserDidUpdate:old:)
                 observer:^BOOL(BJLUser * _Nullable now, BJLUser * _Nullable old) {
                     bjl_strongify(self);
                     [self.tableView reloadData];
                     return YES;
                 }];
    }
    
    if (self.userStates & BJLUserStateMask_online) {
        [self bjl_kvo:BJLMakeProperty(self.room.onlineUsersVM, onlineUsers)
             observer:^BOOL(id _Nullable old, id _Nullable now) {
                 bjl_strongify(self);
                 [self updateTitleWithOnlineUsersTotalCount];
                 [self.tableView reloadData];
                 return YES;
             }];
        
        [self bjl_kvo:BJLMakeProperty(self.room.onlineUsersVM, onlineUsersTotalCount)
               filter:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
                   // bjl_strongify(self);
                   return now.integerValue != old.integerValue;
               }
             observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
                 bjl_strongify(self);
                 [self updateTitleWithOnlineUsersTotalCount];
                 return YES;
             }];
    }
}

- (void)updateTitleWithOnlineUsersTotalCount {
    if (self.userStates == BJLUserStateMask_request) {
        [self.bjl_overlayContainerController updateTitle:@"举手用户"];
    }
    else if (self.userStates == BJLUserStateMask_speaking
             || self.userStates == (BJLUserStateMask_request | BJLUserStateMask_speaking)) {
        [self.bjl_overlayContainerController updateTitle:@"发言用户"];
    }
    else if (self.userStates == BJLUserStateMask_online) {
        NSString *title = @"在线用户";
        NSInteger totalCount = MAX(self.room.onlineUsersVM.onlineUsersTotalCount,
                                   self.room.onlineUsersVM.onlineUsers.count);
        if (totalCount > 0) {
            title = [title stringByAppendingFormat:@"（%td人）", totalCount];
        }
        [self.bjl_overlayContainerController updateTitle:title];
    }
    else {
        [self.bjl_overlayContainerController updateTitle:@"用户列表"];
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _BJLUserState_count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == BJLUserState_request) {
        return (self.userStates & BJLUserStateMask_request
                ? self.room.speakingRequestVM.speakingRequestUsers.count
                : 0);
    }
    if (section == BJLUserState_speaking) {
        return (self.userStates & BJLUserStateMask_speaking
                ? self.room.playingVM.playingUsers.count
                : 0);
    }
    if (section == BJLUserState_online) {
        return (self.userStates & BJLUserStateMask_online
                ? self.room.onlineUsersVM.onlineUsers.count
                : 0);
    }
    return 0;
}

#pragma mark - <UITableViewDelegate>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BJLUser *user = nil;
    BJLUser *onlineUser = nil;
    if (indexPath.section == BJLUserState_request) {
        user = [self.room.speakingRequestVM.speakingRequestUsers bjl_objectOrNilAtIndex:indexPath.row];
    }
    else if (indexPath.section == BJLUserState_speaking) {
        user = onlineUser = [self.room.playingVM.playingUsers bjl_objectOrNilAtIndex:indexPath.row];
    }
    else { // if (indexPath.section == BJLUserState_online)
        // 在线列表取不到音视频状态
        user = /* onlineUser = */[self.room.onlineUsersVM.onlineUsers bjl_objectOrNilAtIndex:indexPath.row];
    }
    
    BOOL isTeacherOrAssistant = self.room.loginUser.isTeacherOrAssistant;
    BOOL isVideoPlayingUser = onlineUser && [self.room.playingVM.videoPlayingUsers containsObject:onlineUser];
    NSString *cellIdentifier = [BJLUserCell
                                cellIdentifierForUserState:(BJLUserState)indexPath.section
                                userRole:user.role
                                hasVideo:onlineUser.videoOn
                                videoPlaying:isVideoPlayingUser
                                isTeacherOrAssistant:isTeacherOrAssistant];
    
    BJLUserCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell updateWithUser:user];
    [self makeActionsForCell:cell userState:(BJLUserState)indexPath.section];
    
    return cell;
}

- (void)makeActionsForCell:(BJLUserCell *)cell userState:(BJLUserState)userState {
    bjl_weakify(self);
    if (userState == BJLUserState_request) {
        cell.allowRequestCallback = cell.allowRequestCallback ?: ^(BJLUserCell * _Nullable cell) {
            bjl_strongify(self);
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            BJLUser *user = [self.room.speakingRequestVM.speakingRequestUsers bjl_objectOrNilAtIndex:indexPath.row];
            [self.room.speakingRequestVM replySpeakingRequestToUserID:user.ID allowed:YES];
        };
        cell.disallowRequestCallback = cell.disallowRequestCallback ?: ^(BJLUserCell * _Nullable cell) {
            bjl_strongify(self);
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            BJLUser *user = [self.room.speakingRequestVM.speakingRequestUsers bjl_objectOrNilAtIndex:indexPath.row];
            [self.room.speakingRequestVM replySpeakingRequestToUserID:user.ID allowed:NO];
        };
    }
    else if (userState == BJLUserState_speaking) {
        cell.toggleVideoPlayingRequestCallback = cell.toggleVideoPlayingRequestCallback ?: ^(BJLUserCell * _Nullable cell) {
            bjl_strongify(self);
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            BJLUser *onlineUser = [self.room.playingVM.playingUsers bjl_objectOrNilAtIndex:indexPath.row];
            BOOL playVideo = onlineUser.videoOn && ![self.room.playingVM.videoPlayingUsers containsObject:onlineUser];
            [self.room.playingVM updatePlayingUserWithID:onlineUser.ID videoOn:playVideo];
            if (self.updateVideoPlayingUserCallback) self.updateVideoPlayingUserCallback(onlineUser.isTeacher, playVideo);
        };
        cell.stopSpeakingRequestCallback = cell.stopSpeakingRequestCallback ?: ^(BJLUserCell * _Nullable cell) {
            bjl_strongify(self);
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            BJLUser *onlineUser = [self.room.playingVM.playingUsers bjl_objectOrNilAtIndex:indexPath.row];
            [self.room.recordingVM remoteChangeRecordingWithUser:onlineUser audioOn:NO videoOn:NO];
            if (self.updateVideoPlayingUserCallback) self.updateVideoPlayingUserCallback(onlineUser.isTeacher, NO);
        };
    }
}

@end

NS_ASSUME_NONNULL_END
