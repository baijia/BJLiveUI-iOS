//
//  BJLUserCell.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-15.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLUserCell.h"

#import "BJLViewImports.h"

NS_ASSUME_NONNULL_BEGIN

#define canManageFormat     @"[manage-%d]"
#define userRoleFormat      @"[userRole-%td]"
#define userStateFormat     @"[userState-%td]"
#define userStateFormat     @"[userState-%td]"
#define hasVideoFormat      @"[hasVideo-%d]"
#define videoPlayingFormat  @"[videoPlaying-%d]"
#define scanIdentifier(IDENTIFIER, FORMAT, VALUE) ({ \
    [IDENTIFIER rangeOfString:[NSString stringWithFormat:FORMAT, VALUE]].location != NSNotFound; \
})

static const CGFloat avatarSize = 32.0;

@interface BJLUserCell ()

@property (nonatomic) BOOL canManage;
@property (nonatomic) BOOL isTeacher;
@property (nonatomic) BOOL online, request, speaking;
@property (nonatomic) BOOL hasVideo, videoPlaying;

@property (nonatomic) UIImageView *avatarView;
@property (nonatomic) UILabel *nameLabel, *teacherLabel;
@property (nonatomic, nullable) UIButton *videoStateButton;

@property (nonatomic, nullable) UIButton *leftButton, *rightButton;

@end

@implementation BJLUserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.canManage = scanIdentifier(reuseIdentifier, canManageFormat, YES);
        self.isTeacher = scanIdentifier(reuseIdentifier, userRoleFormat, BJLUserRole_teacher);
        self.request = scanIdentifier(reuseIdentifier, userStateFormat, BJLUserState_request);
        self.speaking = scanIdentifier(reuseIdentifier, userStateFormat, BJLUserState_speaking);
        self.online = scanIdentifier(reuseIdentifier, userStateFormat, BJLUserState_online);
        self.hasVideo = scanIdentifier(reuseIdentifier, hasVideoFormat, YES);
        self.videoPlaying = self.hasVideo && scanIdentifier(reuseIdentifier, videoPlayingFormat, YES);;
        
        [self makeSubviews];
        [self makeConstraints];
        [self makeActions];
        
        [self prepareForReuse];
    }
    return self;
}

- (void)makeSubviews {
    self.avatarView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.backgroundColor = [UIColor bjl_grayImagePlaceholderColor];
        imageView.layer.cornerRadius = avatarSize / 2;
        imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:imageView];
        imageView;
    });
    
    self.nameLabel = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor bjl_darkGrayTextColor];
        label.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:label];
        label;
    });
    
    if (self.isTeacher) {
        self.teacherLabel = ({
            UILabel *label = [UILabel new];
            label.text = @"老师";
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor bjl_blueBrandColor];
            label.font = [UIFont systemFontOfSize:11.0];
            label.layer.borderWidth = BJLOnePixel;
            label.layer.borderColor = [UIColor bjl_blueBrandColor].CGColor;
            label.layer.cornerRadius = BJLButtonCornerRadius;
            label.layer.masksToBounds = YES;
            [self.contentView addSubview:label];
            label;
        });
    }
    
    if (self.hasVideo) {
        self.videoStateButton = ({
            UIButton *button = [UIButton new];
            UIImage *icon = [UIImage imageNamed:(self.videoPlaying ? @"bjl_ic_video_opening" : @"bjl_ic_video_close")];
            [button setImage:icon forState:UIControlStateNormal];
            [button setTitleColor:[UIColor bjl_lightGrayTextColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:12.0];
            button.userInteractionEnabled = NO;
            [self.contentView addSubview:button];
            button;
        });
    }
    
    const CGFloat buttonWidth = 64.0, buttonHeight = BJLButtonSizeS;
    if (self.request) {
        if (self.canManage) {
            self.leftButton = ({
                BJLButton *button = [BJLButton makeRoundedRectButtonHighlighted:YES];
                button.intrinsicContentSize = CGSizeMake(buttonWidth, buttonHeight);
                [button setTitle:@"同意" forState:UIControlStateNormal];
                [self.contentView addSubview:button];
                button;
            });
            self.rightButton = ({
                BJLButton *button = [BJLButton makeRoundedRectButtonHighlighted:NO];
                button.intrinsicContentSize = CGSizeMake(buttonWidth, buttonHeight);
                [button setTitle:@"拒绝" forState:UIControlStateNormal];
                [self.contentView addSubview:button];
                button;
            });
        }
    }
    else if (self.speaking) {
        if (self.hasVideo) {
            self.leftButton = ({
                BJLButton *button = [BJLButton makeTextButtonDestructive:NO];
                button.intrinsicContentSize = CGSizeMake(buttonWidth, buttonHeight);
                [button setTitle:self.videoPlaying ? @"关闭视频" : @"打开视频" forState:UIControlStateNormal];
                [self.contentView addSubview:button];
                button;
            });
        }
        if (self.canManage && !self.isTeacher) {
            self.rightButton = ({
                BJLButton *button = [BJLButton makeTextButtonDestructive:YES];
                button.intrinsicContentSize = CGSizeMake(buttonWidth, buttonHeight);
                [button setTitle:@"结束发言" forState:UIControlStateNormal];
                [self.contentView addSubview:button];
                button;
            });
        }
    }
}

- (void)makeConstraints {
    [self.nameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow
                                                     forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(avatarSize));
        make.left.equalTo(self.contentView).with.offset(BJLViewSpaceL);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarView.mas_right).with.offset(BJLViewSpaceM);
        make.centerY.equalTo(self.contentView);
        make.right.lessThanOrEqualTo(self.teacherLabel.mas_left ?: self.videoStateButton.mas_left ?: self.leftButton.mas_left ?: self.rightButton.mas_left ?: self.contentView).with.offset(- BJLViewSpaceM);
    }];
    
    [self.teacherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).with.offset(BJLViewSpaceM);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(32.0, 16.0));
        make.right.lessThanOrEqualTo(self.videoStateButton.mas_left ?: self.leftButton.mas_left ?: self.rightButton.mas_left ?: self.contentView).with.offset(- BJLViewSpaceM);
    }];
    
    [self.videoStateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.teacherLabel.mas_right ?: self.nameLabel.mas_right).with.offset(BJLViewSpaceM);
        make.centerY.equalTo(self.contentView);
        make.right.lessThanOrEqualTo(self.leftButton.mas_left ?: self.rightButton.mas_left ?: self.contentView).with.offset(- BJLViewSpaceM);
    }];
    
    UIButton *right1st = self.rightButton ?: self.leftButton;
    [right1st mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).with.offset(- BJLViewSpaceM);
        make.centerY.equalTo(self.contentView);
    }];
    
    UIButton *right2nd = self.rightButton ? self.leftButton : nil;
    [right2nd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.rightButton.mas_left).with.offset(- BJLViewSpaceM);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)makeActions {
    bjl_weakify(self);
    
    [self.leftButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.request) {
            if (self.allowRequestCallback) self.allowRequestCallback(self);
        }
        else if (self.speaking) {
            const NSTimeInterval LIMIT = BJLRobotDelayM;
            static NSTimeInterval LAST = 0;
            NSTimeInterval NOW = [NSDate timeIntervalSinceReferenceDate];
            if (NOW - LAST < LIMIT) {
                return;
            }
            if (self.toggleVideoPlayingRequestCallback) self.toggleVideoPlayingRequestCallback(self);
            LAST = NOW;
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.rightButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.request) {
            if (self.disallowRequestCallback) self.disallowRequestCallback(self);
        }
        else if (self.speaking) {
            if (self.stopSpeakingRequestCallback) self.stopSpeakingRequestCallback(self);
        }
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.avatarView.image = nil;
    self.nameLabel.text = nil;
}

- (void)updateWithUser:(nullable __kindof BJLUser *)user {
    [self.avatarView bjl_setImageWithURL:[NSURL URLWithString:user.avatar]
                             placeholder:nil
                              completion:nil];
    self.nameLabel.text = user.name;
}

+ (NSString *)cellIdentifierForUserState:(BJLUserState)userState
                                userRole:(BJLUserRole)userRole
                                hasVideo:(BOOL)hasVideo
                            videoPlaying:(BOOL)videoPlaying
                    isTeacherOrAssistant:(BOOL)isTeacherOrAssistant {
    return [NSString stringWithFormat:
            canManageFormat userRoleFormat userStateFormat hasVideoFormat videoPlayingFormat,
            isTeacherOrAssistant, userRole, userState, hasVideo, hasVideo && videoPlaying];
}

+ (NSArray<NSString *> *)allCellIdentifiers {
    NSMutableArray *allCellIdentifiers = [NSMutableArray new];
    for (NSNumber *userRole in @[@(BJLUserRole_student), @(BJLUserRole_teacher), @(BJLUserRole_assistant), @(BJLUserRole_guest)]) {
        for (BJLUserState userState = (BJLUserState)0; userState < _BJLUserState_count; userState++) {
            for (NSNumber *hasVideo in @[@NO, @YES]) {
                NSArray<NSNumber *> *videoPlayingStates = @[@NO, @YES];
                for (NSNumber *videoPlaying in videoPlayingStates) {
                    for (NSNumber *isTeacherOrAssistant in @[@NO, @YES]) {
                        NSString *cellIdentifier = [self
                                                    cellIdentifierForUserState:userState
                                                    userRole:(BJLUserRole)userRole.integerValue
                                                    hasVideo:hasVideo.boolValue
                                                    videoPlaying:videoPlaying.boolValue
                                                    isTeacherOrAssistant:isTeacherOrAssistant.boolValue];
                        [allCellIdentifiers bjl_addObjectOrNil:cellIdentifier];
                    }
                }
            }
        }
    }
    return allCellIdentifiers;
}

@end

NS_ASSUME_NONNULL_END
