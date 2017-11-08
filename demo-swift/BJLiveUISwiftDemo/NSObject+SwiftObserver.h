//
//  NSObject+SwiftObserver.h
//  BJLiveUISwiftDemo
//
//  Created by HuangJie on 2017/7/13.
//  Copyright © 2017年 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BJLiveCore/BJLiveCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SwiftObserver)

#pragma mark - BJLRoom observe

/** enterRoomFailureWithError: */
- (id <BJLObservation>)bjl_observeEnterRoomFailureForTarget:(BJLRoom *)room
                                                     filter:(nullable BOOL (^)(BJLError *error))filter
                                                   observer:(BOOL (^)(BJLError *error))observer;

/** enterRoomSuccess */
- (id <BJLObservation>)bjl_observeEnterRoomSuccessForTarget:(BJLRoom *)room
                                                     filter:(nullable BOOL (^)())filter
                                                   observer:(BOOL (^)())observer;
    
/** roomWillExitWithError: */
- (id <BJLObservation>)bjl_observeRoomWillExitWithErrorForTarget:(BJLRoom *)room
                                                          filter:(nullable BOOL (^)(BJLError *error))filter
                                                        observer:(BOOL (^)(BJLError *error))observer;

/** roomDidExitWithError: */
- (id <BJLObservation>)bjl_observeRoomDidExitWithErrorForTarget:(BJLRoom *)room
                                                         filter:(nullable BOOL (^)(BJLError *error))filter
                                                       observer:(BOOL (^)(BJLError *error))observer;

#pragma mark - BJLRoomVM observe

/** didReceiveRollcallWithTimeout: */
- (id <BJLObservation>)bjl_observeDidReceiveRollcallForTarget:(BJLRoomVM *)roomVM
                                                       filter:(nullable BOOL (^)(NSTimeInterval timeout))filter
                                                     observer:(BOOL (^)(NSTimeInterval timeout))observer;
    
/** rollcallDidFinish */
- (id <BJLObservation>)bjl_observeRollcallDidFinishForTarget:(BJLRoomVM *)roomVM
                                                      filter:(nullable BOOL (^)())filter
                                                    observer:(BOOL (^)())observer;
    
#pragma mark - BJLChatVM observe

/** receivedMessagesDidOverwrite: */
- (id <BJLObservation>)bjl_observeReceivedMessagesDidOverwriteForTarget:(BJLChatVM *)chatVM
                                                                 filter:(nullable BOOL (^)(NSArray<BJLMessage *> *receivedMessages))filter
                                                               observer:(BOOL (^)(NSArray<BJLMessage *> *receivedMessages))observer;

/** didReceiveMessage: */
- (id <BJLObservation>)bjl_observeDidReceiveMessageForTarget:(BJLChatVM *)chatVM
                                                      filter:(nullable BOOL (^)(BJLMessage *message))filter
                                                    observer:(BOOL (^)(BJLMessage *message))observer;

/** didReceiveForbidUser:fromUser:duration: */
- (id <BJLObservation>)bjl_observeDidReceiveForbidUserForTarget:(BJLChatVM *)chatVM
                                                         filter:(nullable BOOL (^)(BJLUser *user, BJLUser *fromUser, NSTimeInterval duration))filter
                                                       observer:(BOOL (^)(BJLUser *user, BJLUser *fromUser, NSTimeInterval duration))observer;

#pragma mark - BJLLoadingVM observe

/** loadingUpdateProgress: */
- (id <BJLObservation>)bjl_observeLoadingUpdateProgressForTarget:(BJLLoadingVM *)loadingVM
                                                          filter:(nullable BOOL (^)(CGFloat progress))filter
                                                        observer:(BOOL (^)(CGFloat progress))observer;
    
/** loadingSuccess */
- (id <BJLObservation>)bjl_observeLoadingSuccessForTarget:(BJLLoadingVM *)loadingVM
                                                   filter:(nullable BOOL (^)())filter
                                                 observer:(BOOL (^)())observer;

/** loadingFailureWithError: */
- (id <BJLObservation>)bjl_observeLoadingFailureWithErrorForTarget:(BJLLoadingVM *)loadingVM
                                                            filter:(nullable BOOL (^)(BJLError *error))filter
                                                          observer:(BOOL (^)(BJLError *error))observer;

#pragma mark - BJLOnlineUsersVM observe

/** onlineUsersDidOverwrite: */
- (id <BJLObservation>)bjl_observeOnlineUsersDidOverwriteForTarget:(BJLOnlineUsersVM *)onlineUsersVM
                                                            filter:(nullable BOOL (^)(NSArray<BJLOnlineUser *> *onlineUsers))filter
                                                          observer:(BOOL (^)(NSArray<BJLOnlineUser *> *onlineUsers))observer;

/** onlineUserDidEnter: */
- (id <BJLObservation>)bjl_observeOnlineUserDidEnterForTarget:(BJLOnlineUsersVM *)onlineUsersVM
                                                       filter:(nullable BOOL (^)(BJLOnlineUser *user))filter
                                                     observer:(BOOL (^)(BJLOnlineUser *user))observer;
    
/** onlineUserDidExit: */
- (id <BJLObservation>)bjl_observeOnlineUserDidExitForTarget:(BJLOnlineUsersVM *)onlineUsersVM
                                                      filter:(nullable BOOL (^)(BJLOnlineUser *user))filter
                                                    observer:(BOOL (^)(BJLOnlineUser *user))observer;
    
#pragma mark - BJLPlayingVM observe

/** playingUsersDidOverwrite: */
- (id <BJLObservation>)bjl_observePlayingUsersDidOverwriteForTarget:(BJLPlayingVM *)playingVM
                                                             filter:(nullable BOOL (^)(NSArray<BJLOnlineUser *> *playingUsers))filter
                                                           observer:(BOOL (^)(NSArray<BJLOnlineUser *> *playingUsers))observer;
    
/** playingUserDidUpdate:old: */
- (id <BJLObservation>)bjl_observePlayingUserDidUpdateForTarget:(BJLPlayingVM *)playingVM
                                                         filter:(nullable BOOL (^)(BJLOnlineUser *now, BJLOnlineUser *old))filter
                                                       observer:(BOOL (^)(BJLOnlineUser *now, BJLOnlineUser *old))observer;

#pragma mark - BJLRecordingVM observe

/** recordingDidRemoteChangedRecordingAudio:recordingVideo:recordingAudioChanged:recordingVideoChanged: */
- (id <BJLObservation>)bjl_observeRecordingDidRemoteChangedForTarget:(BJLRecordingVM *)recordingVM
                                                              filter:(nullable BOOL (^)(BOOL, BOOL, BOOL, BOOL))filter
                                                            observer:(BOOL (^)(BOOL, BOOL, BOOL, BOOL))observer;

#pragma mark - BJLServerRecordingVM observe

/** requestServerRecordingDidFailed: */
- (id <BJLObservation>)bjl_observeRequestServerRecordingDidFailedForTarget:(BJLServerRecordingVM *)serverRecordingVM
                                                                    filter:(nullable BOOL (^)(NSString *message))filter
                                                                  observer:(BOOL (^)(NSString *message))observer;

#pragma mark - BJLSlideshowVM observe

/** allDocumentsDidOverwrite: */
- (id <BJLObservation>)bjl_observeAllDocumentsDidOverwriteForTarget:(BJLSlideshowVM *)slideshowVM
                                                             filter:(nullable BOOL (^)(NSArray<BJLDocument *> *allDocuments))filter
                                                           observer:(BOOL (^)(NSArray<BJLDocument *> *allDocuments))observer;
    
/** didAddDocument: */
- (id <BJLObservation>)bjl_observeDidAddDocumentForTarget:(BJLSlideshowVM *)slideshowVM
                                                   filter:(nullable BOOL (^)(BJLDocument *documents))filter
                                                 observer:(BOOL (^)(BJLDocument *document))observer;
    
/** didDeleteDocument: */
- (id <BJLObservation>)bjl_observeDidDeleteDocumentForTarget:(BJLSlideshowVM *)slideshowVM
                                                      filter:(nullable BOOL (^)(BJLDocument *documents))filter
                                                    observer:(BOOL (^)(BJLDocument *document))observer;

#pragma mark - BJLSpeakingRequestVM observe

/** receivedSpeakingRequestFromUser: */
- (id <BJLObservation>)bjl_observeReceivedSpeakingRequestForTarget:(BJLSpeakingRequestVM *)speakingRequestVM
                                                            filter:(nullable BOOL (^)(BJLUser *user))filter
                                                          observer:(BOOL (^)(BJLUser *user))observer;
    
/** speakingRequestDidReplyEnabled:isUserCancelled:user: */
- (id <BJLObservation>)bjl_observeSpeakingRequestDidReplyForTarget:(BJLSpeakingRequestVM *)speakingRequestVM
                                                            filter:(nullable BOOL (^)(BOOL speakingEnabled, BOOL isUserCancelled, BJLUser *user))filter
                                                          observer:(BOOL (^)(BOOL speakingEnabled, BOOL isUserCancelled, BJLUser *user))observer;
    
/** speakingDidRemoteEnabled: */
- (id <BJLObservation>)bjl_observeSpeakingDidRemoteEnabledForTarget:(BJLSpeakingRequestVM *)speakingRequestVM
                                                            filter:(nullable BOOL (^)(BOOL enabled))filter
                                                          observer:(BOOL (^)(BOOL enabled))observer;
    
@end

NS_ASSUME_NONNULL_END
