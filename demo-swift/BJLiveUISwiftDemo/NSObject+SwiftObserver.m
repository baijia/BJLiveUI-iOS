//
//  NSObject+SwiftObserver.m
//  BJLiveUISwiftDemo
//
//  Created by HuangJie on 2017/7/13.
//  Copyright © 2017年 Baijia Cloud. All rights reserved.
//

#import "NSObject+SwiftObserver.h"

@implementation NSObject (SwiftObserver)

#pragma mark - BJLRoom observe

- (id <BJLObservation>)bjl_observeEnterRoomFailureForTarget:(BJLRoom *)room
                                                     filter:(BOOL (^)(BJLError *error))filter
                                                   observer:(BOOL (^)(BJLError *error))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:room name:@"enterRoomFailureWithError:"]
                      filter:filter
                    observer:observer];
}
    
- (id <BJLObservation>)bjl_observeEnterRoomSuccessForTarget:(BJLRoom *)room
                                                     filter:(nullable BOOL (^)())filter
                                                   observer:(BOOL (^)())observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:room name:@"enterRoomSuccess"]
                      filter:filter
                    observer:observer];
}
    
- (id <BJLObservation>)bjl_observeRoomWillExitWithErrorForTarget:(BJLRoom *)room
                                                          filter:(nullable BOOL (^)(BJLError *error))filter
                                                        observer:(BOOL (^)(BJLError *error))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:room name:@"roomWillExitWithError:"]
                      filter:filter
                    observer:observer];
}

- (id <BJLObservation>)bjl_observeRoomDidExitWithErrorForTarget:(BJLRoom *)room
                                                         filter:(nullable BOOL (^)(BJLError *error))filter
                                                       observer:(BOOL (^)(BJLError *error))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:room name:@"roomDidExitWithError:"]
                      filter:filter
                    observer:observer];
}
    
#pragma mark - BJLRoomVM observe
    
- (id <BJLObservation>)bjl_observeDidReceiveRollcallForTarget:(BJLRoomVM *)roomVM
                                                       filter:(nullable BOOL (^)(NSTimeInterval timeout))filter
                                                     observer:(BOOL (^)(NSTimeInterval timeout))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:roomVM name:@"didReceiveRollcallWithTimeout:"]
                      filter:filter
                    observer:observer];
}
    
- (id <BJLObservation>)bjl_observeRollcallDidFinishForTarget:(BJLRoomVM *)roomVM
                                                      filter:(nullable BOOL (^)())filter
                                                    observer:(BOOL (^)())observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:roomVM name:@"rollcallDidFinish"]
                      filter:filter
                    observer:observer];
}

#pragma mark - BJLChatVM observe

- (id <BJLObservation>)bjl_observeReceivedMessagesDidOverwriteForTarget:(BJLChatVM *)chatVM
                                                                 filter:(nullable BOOL (^)(NSArray<BJLMessage *> *receivedMessages))filter
                                                               observer:(BOOL (^)(NSArray<BJLMessage *> *receivedMessages))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:chatVM name:@"receivedMessagesDidOverwrite:"]
                      filter:filter
                    observer:observer];
}
    
- (id <BJLObservation>)bjl_observeDidReceiveMessageForTarget:(BJLChatVM *)chatVM
                                                      filter:(BOOL (^)(BJLMessage *message))filter
                                                    observer:(BOOL (^)(BJLMessage *message))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:chatVM name:@"didReceiveMessage:"]
                      filter:filter
                    observer:observer];
}
    
- (id <BJLObservation>)bjl_observeDidReceiveForbidUserForTarget:(BJLChatVM *)chatVM
                                                         filter:(nullable BOOL (^)(BJLUser *user, BJLUser *fromUser, NSTimeInterval duration))filter
                                                       observer:(BOOL (^)(BJLUser *user, BJLUser *fromUser, NSTimeInterval duration))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:chatVM name:@"didReceiveForbidUser:fromUser:duration:"]
                      filter:filter
                    observer:observer];
}

#pragma mark - BJLLoadingVM observe

- (id <BJLObservation>)bjl_observeLoadingUpdateProgressForTarget:(BJLLoadingVM *)loadingVM
                                                          filter:(nullable BOOL (^)(CGFloat progress))filter
                                                        observer:(BOOL (^)(CGFloat progress))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:loadingVM name:@"loadingUpdateProgress:"]
                      filter:(BJLMethodFilter)filter
                    observer:(BJLMethodObserver)observer];
}
    
- (id <BJLObservation>)bjl_observeLoadingSuccessForTarget:(BJLLoadingVM *)loadingVM
                                                   filter:(nullable BOOL (^)())filter
                                                 observer:(BOOL (^)())observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:loadingVM name:@"loadingSuccess"]
                      filter:filter
                    observer:observer];
}
    
- (id <BJLObservation>)bjl_observeLoadingFailureWithErrorForTarget:(BJLLoadingVM *)loadingVM
                                                            filter:(nullable BOOL (^)(BJLError *error))filter
                                                          observer:(BOOL (^)(BJLError *error))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:loadingVM name:@"loadingFailureWithError:"]
                      filter:filter
                    observer:observer];
}
    
#pragma mark - BJLOnlineUsersVM observe
    
- (id <BJLObservation>)bjl_observeOnlineUsersDidOverwriteForTarget:(BJLOnlineUsersVM *)onlineUsersVM
                                                            filter:(nullable BOOL (^)(NSArray<BJLOnlineUser *> *onlineUsers))filter
                                                          observer:(BOOL (^)(NSArray<BJLOnlineUser *> *onlineUsers))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:onlineUsersVM name:@"onlineUsersDidOverwrite:"]
                      filter:filter
                    observer:observer];
}
    
- (id <BJLObservation>)bjl_observeOnlineUserDidEnterForTarget:(BJLOnlineUsersVM *)onlineUsersVM
                                                       filter:(nullable BOOL (^)(BJLOnlineUser *user))filter
                                                     observer:(BOOL (^)(BJLOnlineUser *user))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:onlineUsersVM name:@"onlineUserDidEnter:"]
                      filter:filter
                    observer:observer];
}

- (id <BJLObservation>)bjl_observeOnlineUserDidExitForTarget:(BJLOnlineUsersVM *)onlineUsersVM
                                                      filter:(nullable BOOL (^)(BJLOnlineUser *user))filter
                                                    observer:(BOOL (^)(BJLOnlineUser *user))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:onlineUsersVM name:@"onlineUserDidExit:"]
                      filter:filter
                    observer:observer];
}
    
#pragma mark - BJLPlayingVM observe

- (id <BJLObservation>)bjl_observePlayingUsersDidOverwriteForTarget:(BJLPlayingVM *)playingVM
                                                             filter:(nullable BOOL (^)(NSArray<BJLOnlineUser *> *playingUsers))filter
                                                           observer:(BOOL (^)(NSArray<BJLOnlineUser *> *playingUsers))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:playingVM name:@"playingUsersDidOverwrite:"]
                      filter:filter
                    observer:observer];
}
    
- (id <BJLObservation>)bjl_observePlayingUserDidUpdateForTarget:(BJLPlayingVM *)playingVM
                                                         filter:(nullable BOOL (^)(BJLOnlineUser *now, BJLOnlineUser *old))filter
                                                       observer:(BOOL (^)(BJLOnlineUser *now, BJLOnlineUser *old))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:playingVM name:@"playingUserDidUpdate:old:"]
                      filter:filter
                    observer:observer];
}

#pragma mark - BJLRecordingVM observe

- (id <BJLObservation>)bjl_observeRecordingDidRemoteChangedForTarget:(BJLRecordingVM *)recordingVM
                                                              filter:(nullable BOOL (^)(BOOL, BOOL, BOOL, BOOL))filter
                                                            observer:(BOOL (^)(BOOL, BOOL, BOOL, BOOL))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:recordingVM name:@"recordingDidRemoteChangedRecordingAudio:recordingVideo:recordingAudioChanged:recordingVideoChanged:"]
                      filter:(BJLMethodFilter)filter
                    observer:(BJLMethodObserver)observer];
}
 
#pragma mark - BJLServerRecordingVM observe

- (id <BJLObservation>)bjl_observeRequestServerRecordingDidFailedForTarget:(BJLServerRecordingVM *)serverRecordingVM
                                                                    filter:(nullable BOOL (^)(NSString *message))filter
                                                                  observer:(BOOL (^)(NSString *message))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:serverRecordingVM name:@"requestServerRecordingDidFailed:"]
                      filter:filter
                    observer:observer];
}

#pragma mark - BJLSlideshowVM observe

- (id <BJLObservation>)bjl_observeAllDocumentsDidOverwriteForTarget:(BJLSlideshowVM *)slideshowVM
                                                             filter:(nullable BOOL (^)(NSArray<BJLDocument *> *allDocuments))filter
                                                           observer:(BOOL (^)(NSArray<BJLDocument *> *allDocuments))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:slideshowVM name:@"allDocumentsDidOverwrite:"]
                      filter:filter
                    observer:observer];
}
    
- (id <BJLObservation>)bjl_observeDidAddDocumentForTarget:(BJLSlideshowVM *)slideshowVM
                                                   filter:(nullable BOOL (^)(BJLDocument *documents))filter
                                                 observer:(BOOL (^)(BJLDocument *document))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:slideshowVM name:@"didAddDocument:"]
                      filter:filter
                    observer:observer];
}
    
- (id <BJLObservation>)bjl_observeDidDeleteDocumentForTarget:(BJLSlideshowVM *)slideshowVM
                                                      filter:(nullable BOOL (^)(BJLDocument *documents))filter
                                                    observer:(BOOL (^)(BJLDocument *document))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:slideshowVM name:@"didDeleteDocument:"]
                      filter:filter
                    observer:observer];
}

#pragma mark - BJLSpeakingRequestVM observe

- (id <BJLObservation>)bjl_observeReceivedSpeakingRequestForTarget:(BJLSpeakingRequestVM *)speakingRequestVM
                                                            filter:(nullable BOOL (^)(BJLUser *user))filter
                                                          observer:(BOOL (^)(BJLUser *user))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:speakingRequestVM name:@"receivedSpeakingRequestFromUser:"]
                      filter:filter
                    observer:observer];
}
    
- (id <BJLObservation>)bjl_observeSpeakingRequestDidReplyForTarget:(BJLSpeakingRequestVM *)speakingRequestVM
                                                            filter:(nullable BOOL (^)(BOOL speakingEnabled, BOOL isUserCancelled, BJLUser *user))filter
                                                          observer:(BOOL (^)(BOOL speakingEnabled, BOOL isUserCancelled, BJLUser *user))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:speakingRequestVM name:@"speakingRequestDidReplyEnabled:isUserCancelled:user:"]
                      filter:(BJLMethodFilter)filter
                    observer:(BJLMethodObserver)observer];
}
    
- (id <BJLObservation>)bjl_observeSpeakingDidRemoteEnabledForTarget:(BJLSpeakingRequestVM *)speakingRequestVM
                                                             filter:(nullable BOOL (^)(BOOL enabled))filter
                                                           observer:(BOOL (^)(BOOL enabled))observer {
    return [self bjl_observe:[BJLMethodMeta instanceWithTarget:speakingRequestVM name:@"speakingDidRemoteEnabled:"]
                      filter:(BJLMethodFilter)filter
                    observer:(BJLMethodObserver)observer];
}
    
@end
