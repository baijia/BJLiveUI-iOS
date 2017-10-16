//
//  BJLPreviewsViewController.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-06-05.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLPreviewsViewController.h"

#import "BJLPreviewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLPreviewItem ()

@property (nonatomic, readwrite) BJLPreviewsType type;
@property (nonatomic, readwrite, nullable) UIView *view;
@property (nonatomic, readwrite, nullable) UIViewController *viewController;
@property (nonatomic, readwrite) CGFloat aspectRatio;
@property (nonatomic, readwrite) BJLContentMode contentMode;
@property (nonatomic, readwrite, nullable) BJLUser *playingUser;

@end

@implementation BJLPreviewItem

@end

#pragma mark -

@interface _BJLPreviewsRootView : BJLHitTestView

@property (nonatomic, weak) UIButton *outsideButton;

@end

@implementation _BJLPreviewsRootView

// 解决 button 超出 bounds 之后点击失效的问题
// @see https://stackoverflow.com/questions/5432995/interaction-beyond-bounds-of-uiview
// @see https://developer.apple.com/library/content/qa/qa2013/qa1812.html
- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event {
    if (!self.outsideButton.hidden) {
        if (CGRectContainsPoint(self.outsideButton.frame, point)) {
            return YES;
        }
    }
    return [super pointInside:point withEvent:event];
}

@end

@interface _BJLPreviewsMoreButton : BJLImageRightButton

@end

@implementation _BJLPreviewsMoreButton

- (CGRect)contentRectForBounds:(CGRect)bounds {
    return UIEdgeInsetsInsetRect([super contentRectForBounds:bounds],
                                 UIEdgeInsetsMake(0.0, - BJLViewSpaceS, 0.0, BJLViewSpaceS));
}

@end

#pragma mark -

typedef NS_ENUM(NSInteger, BJLPreviewsSection) {
    BJLPreviewsSection_PPT,
    BJLPreviewsSection_presenter,
    BJLPreviewsSection_recording,
    BJLPreviewsSection_videoUsers,
    BJLPreviewsSection_audioUsers,
    BJLPreviewsSection_requestUsers,
    _BJLPreviewsSection_count
};

static const NSInteger videoPlayingMaxCount = 6;
static const CGSize moreButtonSize = { .width = 85.0, .height = BJLButtonSizeS };

@interface BJLPreviewsViewController ()

@property (nonatomic, readonly, weak) BJLRoom *room;

@property (nonatomic, readwrite) UICollectionView *collectionView;
@property (nonatomic, readwrite) UIImageView *backgroundView;
@property (nonatomic, readwrite) UIButton *moreButton;

@property (nonatomic, readwrite, nullable) BJLPreviewItem *fullScreenItem;
@property (nonatomic, readwrite) NSInteger numberOfItems;

@property (nonatomic, readonly) BJLUser *presenter; // NON-KVO
@property (nonatomic) BOOL presenterVideoPlaying;
@property (nonatomic) NSMutableSet *autoPlayVideoBlacklist;
@property (nonatomic) NSMutableArray<BJLUser *> *videoUsers, *audioUsers;

@end

@implementation BJLPreviewsViewController

- (instancetype)initWithRoom:(BJLRoom *)room {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self->_room = room;
        self.autoPlayVideoBlacklist = [NSMutableSet new];
        self.videoUsers = [NSMutableArray new];
        self.audioUsers = [NSMutableArray new];
        
        // make sure collectionView, backgroundView, moreButton NOT be nil
        [self makeSubviews];
    }
    return self;
}

- (void)loadView {
    bjl_weakify(self);
    self.view = [_BJLPreviewsRootView viewWithFrame:[UIScreen mainScreen].bounds hitTestBlock:^UIView * _Nullable(UIView * _Nullable hitView, CGPoint point, UIEvent * _Nullable event) {
        bjl_strongify(self);
        if (hitView != self.view && hitView != self.collectionView) {
            return hitView;
        }
        return nil;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room, vmsAvailable)
           filter:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
               // bjl_strongify(self);
               return now.boolValue;
           }
         observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             [self makeConstraints];
             [self makeObserving];
             return YES;
         }];
}

#pragma mark -

- (BJLUser *)presenter {
    return self.room.onlineUsersVM.currentPresenter;
}

#pragma mark -

- (void)makeSubviews {
    self.collectionView = ({
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                              collectionViewLayout:({
            UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.itemSize = [BJLPreviewCell cellSize];
            layout.minimumLineSpacing = 0.0;
            layout.minimumInteritemSpacing = 0.0;
            layout.sectionInset = UIEdgeInsetsZero;
            layout;
        })];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.bounces = YES;
        collectionView.alwaysBounceHorizontal = YES;
        collectionView.alwaysBounceVertical = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.clipsToBounds = NO;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        for (NSString *cellIdentifier in [BJLPreviewCell allCellIdentifiers]) {
            [collectionView registerClass:[BJLPreviewCell class]
               forCellWithReuseIdentifier:cellIdentifier];
        }
        [self.view addSubview:collectionView];
        collectionView;
    });
    
    self.backgroundView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.image = [[[UIImage imageNamed:@"bjl_bg_preview"]
                            bjl_imageFillSize:[BJLPreviewCell cellSize] enlarge:YES]
                           resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
        imageView.userInteractionEnabled = YES;
        [self.collectionView insertSubview:imageView atIndex:0];
        imageView;
    });
    
    self.moreButton = ({
        _BJLPreviewsMoreButton *button = [_BJLPreviewsMoreButton new];
        [button setTitle:@"新请求" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"bjl_ic_speakreq_more"] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        button.backgroundColor = [UIColor bjl_blueBrandColor];
        button.layer.cornerRadius = moreButtonSize.height / 2;
        button.layer.masksToBounds = YES;
        button.midSpace = BJLViewSpaceS;
        [self.view addSubview:button];
        button;
    });
    self.moreButton.hidden = YES;
    
    bjl_cast(_BJLPreviewsRootView, self.view).outsideButton = self.moreButton;
    bjl_weakify(self);
    [self.moreButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        CGRect rightEdge = CGRectMake(self.collectionView.contentSize.width - 1.0, 0.0, 1.0, 1.0);
        [self.collectionView scrollRectToVisible:rightEdge animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)makeConstraints {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.collectionView);
        make.left.equalTo(self.collectionView.mas_left).with.offset(self.collectionView.contentSize.width); // !!!: .mas_right NOT work
        make.width.equalTo(self.collectionView).multipliedBy(2.0);
    }];
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.collectionView, contentSize)
           filter:^BOOL(NSValue * _Nullable old, NSValue * _Nullable now) {
               // bjl_strongify(self);
               return now.CGSizeValue.width != old.CGSizeValue.width;
           }
         observer:^BOOL(NSValue * _Nullable old, NSValue * _Nullable now) {
             bjl_strongify(self);
             [self.backgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
                 make.left.equalTo(self.collectionView.mas_left).with.offset(now.CGSizeValue.width); // !!!: .mas_right NOT work
             }];
             return YES;
         }];
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).with.offset(moreButtonSize.height / 2);
        make.top.equalTo(self.view.mas_bottom).with.offset(BJLViewSpaceM);
        make.size.mas_equalTo(moreButtonSize);
    }];
}

- (void)makeObserving {
    bjl_weakify(self);
    
    [self enterFullScreenWithPPTView];
    
    // 举手用户
    [self bjl_kvo:BJLMakeProperty(self.room.speakingRequestVM, speakingRequestUsers)
         observer:^BOOL(NSArray<BJLUser *> * _Nullable old, NSArray<BJLUser *> * _Nullable now) {
             bjl_strongify(self);
             [self reloadCollectionView];
             // 举手提示
             if (self.room.loginUser.isTeacherOrAssistant) {
                 if (now.count > old.count) {
                     [self tryToShowMoreButton];
                 }
                 else {
                     [self tryToHideMoreButton];
                 }
             }
             return YES;
         }];
    // 举手提示
    if (self.room.loginUser.isTeacherOrAssistant) {
        [self bjl_kvo:BJLMakeProperty(self.collectionView, contentSize)
             observer:^BOOL(id _Nullable old, id _Nullable now) {
                 bjl_strongify(self);
                 if (!self.moreButton.hidden) {
                     [self tryToHideMoreButton];
                 }
                 return YES;
             }];
        [self bjl_kvo:BJLMakeProperty(self.collectionView, contentOffset)
             observer:^BOOL(id _Nullable old, id _Nullable now) {
                 bjl_strongify(self);
                 if (!self.moreButton.hidden) {
                     [self tryToHideMoreButton];
                 }
                 return YES;
             }];
    }
    
    // 音视频用户 - 覆盖更新
    [self bjl_observe:BJLMakeMethod(self.room.playingVM, playingUsersDidOverwrite:)
             observer:^BOOL(NSArray<BJLUser *> * _Nullable users) {
                 bjl_strongify(self);
                 [self updateVideoUsers];
                 [self updateAudioUsers];
                 [self reloadCollectionView];
                 [self tryAutoPlayVideoWithUsers:users];
                 return YES;
             }];
    // 音视频用户 - 单个更新
    [self bjl_observe:BJLMakeMethod(self.room.playingVM, playingUserDidUpdate:old:)
             observer:^BOOL(BJLUser * _Nullable user, BJLUser * _Nullable old) {
                 bjl_strongify(self);
                 [self updateVideoUsers];
                 [self updateAudioUsers];
                 [self reloadCollectionView];
                 if (user) {
                     [self tryAutoPlayVideoWithUser:user];
                 }
                 return YES;
             }];
    
    // 播放视频
    [self bjl_kvo:BJLMakeProperty(self.room.playingVM, videoPlayingUsers)
         observer:^BOOL(id _Nullable old, id _Nullable now) {
             bjl_strongify(self);
             [self updateVideoUsers];
             [self updateAudioUsers];
             [self reloadCollectionView];
             return YES;
         }];
    
    // 主讲
    [self bjl_kvo:BJLMakeProperty(self.room.onlineUsersVM, currentPresenter)
           filter:^BOOL(id _Nullable old, id _Nullable now) {
               // bjl_strongify(self);
               return now != old;
           }
         observer:^BOOL(BJLUser * _Nullable old, BJLUser * _Nullable user) {
             bjl_strongify(self);
             [self reloadCollectionView];
             if (self.presenterVideoPlaying && ![user isSameUser:old]) {
                 [self.room.playingVM updatePlayingUserWithID:old.ID videoOn:NO];
             }
             if (user) {
                 [self tryAutoPlayVideoWithUser:user];
             }
             return YES;
         }];
    
    // 全屏
    [self bjl_kvo:BJLMakeProperty(self, fullScreenItem)
         observer:^BOOL(BJLPreviewItem * _Nullable old, BJLPreviewItem * _Nullable now) {
             bjl_strongify(self);
             if (old.type == BJLPreviewsType_playing
                 || now.type == BJLPreviewsType_playing) {
                 [self updateVideoUsers];
             }
             [self reloadCollectionView];
             return YES;
         }];
    [self bjl_observe:BJLMakeMethod(self.room.playingVM, playingViewAspectRatioChanged:forUserWithID:)
               filter:(BJLMethodFilter)^BOOL(CGFloat videoAspectRatio, NSString *userID) {
                   bjl_strongify(self);
                   return (self.fullScreenItem.type == BJLPreviewsType_playing
                           && [self.fullScreenItem.playingUser.ID isEqualToString:userID]);
               }
             observer:(BJLMethodObserver)^BOOL(CGFloat videoAspectRatio, NSString *userID) {
                 bjl_strongify(self);
                 self.fullScreenItem.aspectRatio = videoAspectRatio;
                 return YES;
             }];
    [self bjl_observe:BJLMakeMethod(self.room.playingVM, playingUserWantsShowInFullScreen:)
               filter:^BOOL(BJLUser *user) {
                   bjl_strongify(self);
                   return ([user isSameUser:self.room.onlineUsersVM.currentPresenter]
                           // 正在播视频
                           && [self.room.playingVM.videoPlayingUsers containsObject:user]
                           // 但没有全屏
                           && !(self.fullScreenItem.type == BJLPreviewsType_playing
                                && [self.fullScreenItem.playingUser isSameUser:user]));
               }
             observer:^BOOL(BJLUser *user) {
                 bjl_strongify(self);
                 [self enterFullScreenWithViewForVideoPlayingUser:user];
                 return YES;
             }];
    
    // 自己
    [self bjl_kvo:BJLMakeProperty(self.room.recordingVM, recordingVideo)
         observer:^BOOL(id _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             if (self.fullScreenItem.type == BJLPreviewsType_recording) {
                 if (!now.boolValue) {
                     self.fullScreenItem = nil;
                 }
             }
             else {
                 [self reloadCollectionView];
             }
             return YES;
         }];
    
    // PPT
    [self bjl_kvo:BJLMakeProperty(self.room.slideshowViewController, isBlank)
         observer:^BOOL(id _Nullable old, id _Nullable now) {
             bjl_strongify(self);
             [self reloadCollectionView];
             return YES;
         }];
}

- (BOOL)atTheEndOfCollectionView {
    CGFloat contentOffsetX = self.collectionView.contentOffset.x;
    CGFloat rightInset = self.collectionView.contentInset.right;
    CGFloat viewWidth = CGRectGetWidth(self.collectionView.frame);
    CGFloat contentWidth = self.collectionView.contentSize.width;
    CGFloat bottomOffset = contentOffsetX + viewWidth - rightInset - contentWidth;
    return bottomOffset >= 0.0 - [BJLPreviewCell cellSize].width / 2;
}

- (void)tryToShowMoreButton {
    if (self.moreButton.hidden && ![self atTheEndOfCollectionView]) {
        self.moreButton.hidden = NO;
    }
}

- (void)tryToHideMoreButton {
    if (!self.moreButton.hidden && [self atTheEndOfCollectionView]) {
        self.moreButton.hidden = YES;
    }
}

// videoUsers = playingVM.videoPlayingUsers - self.presenter - fullScreenItem.playingUser
- (void)updateVideoUsers {
    [self.videoUsers removeAllObjects];
    
    self.presenterVideoPlaying = NO;
    
    BOOL fullScreenPlaying = (self.fullScreenItem.type == BJLPreviewsType_playing);
    BJLUser *fullScreenUser = nil;
    
    for (BJLUser *videoPlayingUser in self.room.playingVM.videoPlayingUsers) {
        BOOL isPresenter = [videoPlayingUser isSameUser:self.presenter];
        if (isPresenter) {
            self.presenterVideoPlaying = YES;
        }
        
        BOOL isFullScreenUser = fullScreenPlaying && [videoPlayingUser isSameUser:self.fullScreenItem.playingUser];
        if (isFullScreenUser) {
            fullScreenUser = videoPlayingUser;
        }
        
        if (!isPresenter && !isFullScreenUser) {
            [self.videoUsers addObject:videoPlayingUser];
        }
    }
    
    if (fullScreenPlaying) {
        if (fullScreenUser) {
            self.fullScreenItem.playingUser = fullScreenUser;
        }
        else {
            self.fullScreenItem = nil;
        }
    }
}

// audioUsers = playingVM.playingUsers - self.presenter - playingVM.videoPlayingUsers
- (void)updateAudioUsers {
    [self.audioUsers removeAllObjects];
    
    for (BJLUser *playingUser in self.room.playingVM.playingUsers) {
        if (![playingUser isSameUser:self.presenter]
            && ![self.room.playingVM.videoPlayingUsers containsObject:playingUser]) {
            [self.audioUsers addObject:playingUser];
        }
    }
}

- (void)autoEnterFullScreen {
    if (self.fullScreenItem && self.fullScreenItem.type != BJLPreviewsType_None) {
        return;
    }
    
    if (!self.room.slideshowViewController.isBlank) {
        [self enterFullScreenWithPPTView];
    }
    else {
        if ([self.room.loginUser isSameUser:self.room.onlineUsersVM.currentPresenter]) {
            [self enterFullScreenWithRecordingView];
        }
        else {
            [self enterFullScreenWithViewForVideoPlayingUser:self.room.onlineUsersVM.currentPresenter];
        }
    }
}

- (void)enterFullScreenWithPPTView {
    self.fullScreenItem = ({
        BJLPreviewItem *item = [BJLPreviewItem new];
        item.type = BJLPreviewsType_PPT;
        item.view = nil;
        item.viewController = self.room.slideshowViewController;
        item.aspectRatio = 4.0 / 3;
        item.contentMode = BJLContentMode_scaleToFill;
        item.playingUser = nil;
        item;
    });
}

- (void)enterFullScreenWithRecordingView {
    if (!self.room.recordingVM.recordingVideo) {
        return;
    }
    self.fullScreenItem = ({
        BJLPreviewItem *item = [BJLPreviewItem new];
        item.type = BJLPreviewsType_recording;
        item.view = self.room.recordingView;
        item.viewController = nil;
        item.aspectRatio = self.room.recordingVM.inputVideoAspectRatio;
        item.contentMode = BJLContentMode_scaleToFill;
        item.playingUser = nil;
        item;
    });
}

- (void)enterFullScreenWithViewForVideoPlayingUser:(BJLUser *)videoPlayingUser {
    if (![self.room.playingVM.videoPlayingUsers containsObject:videoPlayingUser]) {
        return;
    }
    self.fullScreenItem = ({
        BJLPreviewItem *item = [BJLPreviewItem new];
        item.type = BJLPreviewsType_playing;
        item.view = [self.room.playingVM playingViewForUserWithID:videoPlayingUser.ID];
        item.viewController = nil;
        item.aspectRatio = [self.room.playingVM playingViewAspectRatioForUserWithID:videoPlayingUser.ID];
        item.contentMode = BJLContentMode_scaleToFill;
        item.playingUser = videoPlayingUser;
        item;
    });
}

- (void)reloadCollectionView {
    [self.collectionView reloadData];
    
    NSInteger numberOfItems = 0;
    for (BJLPreviewsSection section = (BJLPreviewsSection)0; section < _BJLPreviewsSection_count; section++) {
        numberOfItems += [self.collectionView numberOfItemsInSection:section];
    }
    
    if (numberOfItems != self.numberOfItems) {
        self.numberOfItems = numberOfItems;
        [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
            BOOL isHorizontal = BJLIsHorizontalUI(self);
            [self makeContentSize:make forHorizontal:isHorizontal];
        }];
        // !!!: `collectionView:cellForItemAtIndexPath:` bug
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        [self.collectionView reloadData];
    }
    
    [self autoEnterFullScreen];
}

// !!!: `collectionView:cellForItemAtIndexPath:` will not be called if height is 0
- (void)makeContentSize:(MASConstraintMaker *)make forHorizontal:(BOOL)isHorizontal {
    CGSize size = [BJLPreviewCell cellSize];
    // size.width = self.numberOfItems > 0 ? size.width *= self.numberOfItems : 0.0;
    size.height = self.numberOfItems > 0 ? size.height : 0.0;
    // make.width.equalTo(@(size.width)).priorityHigh();
    make.height.equalTo(@(size.height));
    
    self.collectionView.contentInset = bjl_structSet(self.collectionView.contentInset, {
        // TODO: - size.width should be BJLTopBarView.customContainerView.left
        set.right = isHorizontal ? size.width : 0.0;
    });
}

- (CGFloat)viewHeightIfDisplay {
    return [BJLPreviewCell cellSize].height;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _BJLPreviewsSection_count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case BJLPreviewsSection_PPT: {
            return (self.room.slideshowViewController
                    && self.fullScreenItem.type != BJLPreviewsType_PPT
                    && !self.room.slideshowViewController.isBlank) ? 1 : 0;
        }
        case BJLPreviewsSection_presenter: {
            BOOL presenterFullScreen = (self.fullScreenItem.type == BJLPreviewsType_playing
                                        && self.fullScreenItem.playingUser
                                        && [self.fullScreenItem.playingUser isSameUser:self.presenter]);
            return (!self.room.loginUserIsPresenter
                    && self.presenter
                    && !presenterFullScreen) ? 1 : 0;
        }
        case BJLPreviewsSection_recording: {
            return (self.room.recordingVM.recordingVideo
                    && self.fullScreenItem.type != BJLPreviewsType_recording) ? 1 : 0;
        }
        case BJLPreviewsSection_videoUsers: {
            return self.videoUsers.count;
        }
        case BJLPreviewsSection_audioUsers: {
            return self.audioUsers.count;
        }
        case BJLPreviewsSection_requestUsers: {
            return (self.room.loginUser.isTeacherOrAssistant
                    ? self.room.speakingRequestVM.speakingRequestUsers.count
                    : 0);
        }
        default: {
            return 0;
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = nil;
    switch (indexPath.section) {
        case BJLPreviewsSection_PPT:
            cellIdentifier = BJLPreviewCellID_view;
            break;
        case BJLPreviewsSection_presenter:
            cellIdentifier = (self.presenter && self.presenterVideoPlaying
                              ? BJLPreviewCellID_view_label
                              : BJLPreviewCellID_avatar_label);
            break;
        case BJLPreviewsSection_recording:
            // cellIdentifier = BJLPreviewCellID_view;
            cellIdentifier = BJLPreviewCellID_view_label;
            break;
        case BJLPreviewsSection_videoUsers:
            cellIdentifier = BJLPreviewCellID_view_label;
            break;
        case BJLPreviewsSection_audioUsers:
            cellIdentifier = BJLPreviewCellID_avatar_label;
            break;
        case BJLPreviewsSection_requestUsers:
            cellIdentifier = BJLPreviewCellID_avatar_label_buttons;
            break;
        default:
            cellIdentifier = BJLPreviewCellID_view;
            break;
    }
    
    BJLPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    bjl_weakify(self);
    cell.doubleTapsCallback = cell.doubleTapsCallback = ^(BJLPreviewCell *cell) {
        bjl_strongify(self);
        switch (indexPath.section) {
            case BJLPreviewsSection_PPT: {
                [self enterFullScreenWithPPTView];
                break;
            }
            case BJLPreviewsSection_presenter: {
                [self enterFullScreenWithViewForVideoPlayingUser:self.presenter];
                break;
            }
            case BJLPreviewsSection_recording: {
                [self enterFullScreenWithRecordingView];
                break;
            }
            case BJLPreviewsSection_videoUsers: {
                BJLUser *user = [self.videoUsers bjl_objectOrNilAtIndex:indexPath.row];
                [self enterFullScreenWithViewForVideoPlayingUser:user];
                break;
            }
            case BJLPreviewsSection_audioUsers: {
                break;
            }
            case BJLPreviewsSection_requestUsers: {
                break;
            }
            default: {
                break;
            }
        }
    };
    
    switch (indexPath.section) {
        case BJLPreviewsSection_PPT: {
            [self bjl_addChildViewController:self.room.slideshowViewController addSubview:^(UIView * _Nonnull parentView, UIView * _Nonnull childView) {
                [cell updateWithView:self.room.slideshowViewController.view];
            }];
            break;
        }
        case BJLPreviewsSection_presenter: {
            NSString *title = [NSString stringWithFormat:@"%@(%@)",
                               self.presenter.name,
                               self.presenter.isTeacher ? @"老师" : @"主讲"];
            if (self.presenterVideoPlaying) {
                [cell updateWithView:[self.room.playingVM playingViewForUserWithID:self.presenter.ID]
                               title:title];
            }
            else {
                [cell updateWithImageURLString:self.presenter.avatar
                                         title:title
                                      hasVideo:self.presenter.videoOn];
            }
            break;
        }
        case BJLPreviewsSection_recording: {
            // [cell updateWithView:self.room.recordingView];
            [cell updateWithView:self.room.recordingView
                           title:self.room.loginUser.name];
            break;
        }
        case BJLPreviewsSection_videoUsers: {
            BJLUser *user = [self.videoUsers bjl_objectOrNilAtIndex:indexPath.row];
            [cell updateWithView:[self.room.playingVM playingViewForUserWithID:user.ID]
                           title:user.name];
            break;
        }
        case BJLPreviewsSection_audioUsers: {
            BJLUser *user = [self.audioUsers bjl_objectOrNilAtIndex:indexPath.row];
            [cell updateWithImageURLString:user.avatar
                                     title:user.name
                                  hasVideo:user.videoOn];
            break;
        }
        case BJLPreviewsSection_requestUsers: {
            BJLUser *user = [self.room.speakingRequestVM.speakingRequestUsers bjl_objectOrNilAtIndex:indexPath.row];
            [cell updateWithImageURLString:user.avatar
                                     title:[NSString stringWithFormat:@"%@举手中", user.name ?: @""]
                                  hasVideo:NO];
            if (self.room.loginUser.isTeacherOrAssistant) {
                bjl_weakify(self);
                cell.actionCallback = cell.actionCallback ?: ^(BJLPreviewCell *cell, BOOL allowed) {
                    bjl_strongify(self);
                    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
                    BJLUser *user = [self.room.speakingRequestVM.speakingRequestUsers bjl_objectOrNilAtIndex:indexPath.row];
                    if (user) {
                        [self.room.speakingRequestVM replySpeakingRequestToUserID:user.ID allowed:allowed];
                    }
                };
            }
            break;
        }
        default: {
            break;
        }
    }
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    switch (indexPath.section) {
        case BJLPreviewsSection_PPT: {
            [self showMenuForPPTViewSourceView:cell];
            break;
        }
        case BJLPreviewsSection_presenter: {
            [self showMenuForPlayingUser:self.presenter sourceView:cell];
            break;
        }
        case BJLPreviewsSection_recording: {
            [self showMenuForRecordingViewSourceView:cell];
            break;
        }
        case BJLPreviewsSection_videoUsers: {
            BJLUser *user = [self.videoUsers bjl_objectOrNilAtIndex:indexPath.row];
            [self showMenuForPlayingUser:user sourceView:cell];
            break;
        }
        case BJLPreviewsSection_audioUsers: {
            BJLUser *user = [self.audioUsers bjl_objectOrNilAtIndex:indexPath.row];
            [self showMenuForPlayingUser:user sourceView:cell];
            break;
        }
        case BJLPreviewsSection_requestUsers: {
            break;
        }
        default: {
            break;
        }
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - menu

- (void)showMenuForFullScreenItemSourceView:(nullable UIView *)sourceView {
    switch (self.fullScreenItem.type) {
        case BJLPreviewsType_PPT:
            [self showMenuForPPTViewSourceView:sourceView];
            break;
        case BJLPreviewsType_playing:
            [self showMenuForPlayingUser:self.fullScreenItem.playingUser sourceView:sourceView];
            break;
        case BJLPreviewsType_recording:
            [self showMenuForRecordingViewSourceView:sourceView];
            break;
        default:
            break;
    }
}

- (void)showMenuForPPTViewSourceView:(nullable UIView *)sourceView {
    if (self.fullScreenItem.type == BJLPreviewsType_PPT) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"PPT"
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert bjl_addActionWithTitle:@"全屏"
                            style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * _Nonnull action) {
                              if (self.fullScreenItem.type == BJLPreviewsType_PPT) {
                                  return;
                              }
                              [self enterFullScreenWithPPTView];
                          }];
    
    [alert bjl_addActionWithTitle:@"取消"
                            style:UIAlertActionStyleCancel
                          handler:nil];
    
    [self showAlert:alert sourceView:sourceView];
}

- (void)showMenuForRecordingViewSourceView:(nullable UIView *)sourceView {
    if (!self.room.recordingVM.recordingVideo) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"采集视频"
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (self.fullScreenItem.type != BJLPreviewsType_recording) {
        [alert bjl_addActionWithTitle:@"全屏"
                                style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * _Nonnull action) {
                                  if (!self.room.recordingVM.recordingVideo) {
                                      return;
                                  }
                                  [self enterFullScreenWithRecordingView];
                              }];
    }
    
    [alert bjl_addActionWithTitle:@"切换摄像头"
                            style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * _Nonnull action) {
                              if (!self.room.recordingVM.recordingVideo) {
                                  return;
                              }
                              self.room.recordingVM.usingRearCamera = !self.room.recordingVM.usingRearCamera;
                          }];
    
    [alert bjl_addActionWithTitle:(self.room.recordingVM.videoBeautifyLevel == BJLVideoBeautifyLevel_off
                                   ? @"开启美颜" : @"关闭美颜")
                            style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * _Nonnull action) {
                              if (!self.room.recordingVM.recordingVideo) {
                                  return;
                              }
                              self.room.recordingVM.videoBeautifyLevel = (self.room.recordingVM.videoBeautifyLevel == BJLVideoBeautifyLevel_off
                                                                          ? BJLVideoBeautifyLevel_on : BJLVideoBeautifyLevel_off);
                          }];
    
    [alert bjl_addActionWithTitle:@"关闭摄像头"
                            style:UIAlertActionStyleDestructive
                          handler:^(UIAlertAction * _Nonnull action) {
                              if (!self.room.recordingVM.recordingVideo) {
                                  return;
                              }
                              BJLError *error = [self.room.recordingVM setRecordingAudio:self.room.recordingVM.recordingAudio
                                                                          recordingVideo:NO];
                              if (error) {
                                  [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
                              }
                              else {
                                  [self showProgressHUDWithText:(self.room.recordingVM.recordingVideo
                                                                 ? @"摄像头已打开"
                                                                 : @"摄像头已关闭")];
                              }
                          }];
    
    [alert bjl_addActionWithTitle:@"取消"
                            style:UIAlertActionStyleCancel
                          handler:nil];
    
    [self showAlert:alert sourceView:sourceView];
}

- (void)showMenuForPlayingUser:(BJLUser *)playingUser sourceView:(nullable UIView *)sourceView {
    if (![self.room.playingVM.playingUsers containsObject:playingUser]) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:playingUser.name
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    BOOL playingVideo = (([playingUser isSameUser:self.presenter] && self.presenterVideoPlaying)
                         || [self.room.playingVM.videoPlayingUsers containsObject:playingUser]);
    
    if (playingVideo) {
        BOOL isFullScreen = (self.fullScreenItem.type == BJLPreviewsType_playing
                             && self.fullScreenItem.playingUser == playingUser);
        if (!isFullScreen) {
            [alert bjl_addActionWithTitle:@"全屏"
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * _Nonnull action) {
                                      if (![self.videoUsers containsObject:playingUser]
                                          && [self.audioUsers containsObject:playingUser]) {
                                          return;
                                      }
                                      BOOL playingVideo = (([playingUser isSameUser:self.presenter] && self.presenterVideoPlaying)
                                                           || [self.room.playingVM.videoPlayingUsers containsObject:playingUser]);
                                      BOOL isFullScreen = (self.fullScreenItem.type == BJLPreviewsType_playing
                                                           && self.fullScreenItem.playingUser == playingUser);
                                      if (playingVideo && !isFullScreen) {
                                          [self enterFullScreenWithViewForVideoPlayingUser:playingUser];
                                      }
                                  }];
        }
        
        [alert bjl_addActionWithTitle:@"关闭视频"
                                style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * _Nonnull action) {
                                  if (![self.videoUsers containsObject:playingUser]
                                      && [self.audioUsers containsObject:playingUser]) {
                                      return;
                                  }
                                  BOOL playingVideo = (([playingUser isSameUser:self.presenter] && self.presenterVideoPlaying)
                                                       || [self.self.room.playingVM.videoPlayingUsers containsObject:playingUser]);
                                  if (playingVideo) {
                                      [self.room.playingVM updatePlayingUserWithID:playingUser.ID videoOn:NO];
                                  }
                                  // 主动关闭老师视频后不再自动打开
                                  [self.autoPlayVideoBlacklist addObject:playingUser.number ?: @""];
                              }];
    }
    else if (playingUser.videoOn) {
        [alert bjl_addActionWithTitle:@"打开视频"
                                style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * _Nonnull action) {
                                  [self playVideoWithUser:playingUser];
                              }];
    }
    else {
        alert.message = @"对方没有开启摄像头";
    }
    
    if (self.room.loginUser.isTeacherOrAssistant
        && self.room.roomInfo.roomType == BJLRoomType_1toN) {
        [alert bjl_addActionWithTitle:@"结束发言"
                                style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction * _Nonnull action) {
                                  /*
                                  if (![self.videoUsers containsObject:playingUser]
                                      && ![self.audioUsers containsObject:playingUser]) {
                                      return;
                                  } */
                                  [self.room.recordingVM remoteChangeRecordingWithUser:playingUser
                                                                               audioOn:NO
                                                                               videoOn:NO];
                              }];
    }
    
    [alert bjl_addActionWithTitle:alert.actions.count ? @"取消" : @"知道了"
                            style:UIAlertActionStyleCancel
                          handler:nil];
    
    [self showAlert:alert sourceView:sourceView];
}

#pragma mark - play & auto-play

- (void)playVideoWithUser:(BJLUser *)user {
    if ([self.videoUsers containsObject:user]
        || (![self.audioUsers containsObject:user]
            && user != self.presenter)) {
        return;
    }
    
    BOOL playingUser = [self.room.playingVM.videoPlayingUsers containsObject:user];
    if (!playingUser && user.videoOn) {
        BOOL imPresenter = [self.room.loginUser isSameUser:self.presenter];
        BOOL isPresenter = [user isSameUser:self.presenter];
        BOOL playingPresenter = self.presenterVideoPlaying;
        BOOL reachMaxCount = ((!imPresenter && isPresenter)
                              || (self.room.playingVM.videoPlayingUsers.count - (playingPresenter ? 1 : 0)
                                  < videoPlayingMaxCount - (!imPresenter ? 1 : 0)));
        if (reachMaxCount) {
            BJLError *error = [self.room.playingVM updatePlayingUserWithID:user.ID videoOn:YES];
            if (error) {
                [self showProgressHUDWithText:error.localizedFailureReason ?: error.localizedDescription];
            }
        }
        else {
            [self showProgressHUDWithText:@"请先关闭一路学生视频"];
        }
    }
    // 主动打开老师视频后回复自动打开逻辑
    [self.autoPlayVideoBlacklist removeObject:user.number ?: @""];
}

// 有事件发生时(有人开启摄像头): 如果对方是老师，并且本地未进行过开关对方摄像头的操作的情况下【自动】打开对方视频
- (BOOL)tryAutoPlayVideoWithUser:(BJLUser *)user {
    // self.presenter 可能比 self.room.playingVM.playingUsers 先更新，后者更新才尝试自动播放
    if ([user isSameUser:self.presenter]
        && ![self.room.playingVM.playingUsers containsObject:self.presenter]) {
        return NO;
    }
    
    if (user.videoOn && ![self.autoPlayVideoBlacklist containsObject:user.number ?: @""]) {
        [self playVideoWithUser:user];
        return YES; // YES - tried, 满足自动播放条件，是否播放成功无所谓
    }
    return NO;
}

- (void)tryAutoPlayVideoWithUsers:(NSArray<BJLUser *> *)users {
    for (BJLUser *user in users) {
        [self tryAutoPlayVideoWithUser:user];
    }
}

#pragma mark -

- (void)showAlert:(UIAlertController *)alert sourceView:(nullable UIView *)sourceView {
    if (alert.preferredStyle == UIAlertControllerStyleActionSheet) {
        sourceView = sourceView ?: self.view;
        alert.popoverPresentationController.sourceView = sourceView;
        alert.popoverPresentationController.sourceRect = ({
            CGRect rect = sourceView.bounds;
            rect.origin.y = CGRectGetMaxY(rect) - 1.0;
            rect.size.height = 1.0;
            rect;
        });
        alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
    }
    [self presentViewController:alert animated:YES completion:nil];
}

@end

NS_ASSUME_NONNULL_END
