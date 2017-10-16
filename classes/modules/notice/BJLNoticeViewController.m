//
//  BJLNoticeViewController.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-08.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/UITextView+BJLPlaceholder.h>

#import "BJLNoticeViewController.h"

#import "BJLOverlayViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLNoticeViewController ()

@property (nonatomic, readonly, weak) BJLRoom *room;

@property (nonatomic) UITextView *noticeTextView;
@property (nonatomic) UILabel *tipsLabel;

@end

@implementation BJLNoticeViewController

#pragma mark - lifecycle & <BJLRoomChildViewController>

- (instancetype)initWithRoom:(BJLRoom *)room {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self->_room = room;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollView.alwaysBounceVertical = YES;
    
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room, vmsAvailable)
           filter:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
               // bjl_strongify(self);
               return now.boolValue;
           }
         observer:^BOOL(NSNumber * _Nullable old, NSNumber * _Nullable now) {
             bjl_strongify(self);
             [self makeSubviews];
             [self makeConstraints];
             [self makeActions];
             [self makeObserving];
             return YES;
         }];
}

- (void)didMoveToParentViewController:(nullable UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    
    if (!parent && !self.bjl_overlayContainerController) {
        return;
    }
    
    [self.bjl_overlayContainerController updateTitle:@"公告"];
    [self.bjl_overlayContainerController updateRightButtons:nil];
    [self.bjl_overlayContainerController updateFooterView:nil];
    
    [self updateNotice];
}

- (void)makeSubviews {
    self.noticeTextView = ({
        UITextView *textView = [UITextView new];
        textView.backgroundColor = [UIColor bjl_lightGrayBackgroundColor];
        textView.font = [UIFont systemFontOfSize:16.0];
        textView.textColor = [UIColor bjl_darkGrayTextColor];
        textView.bjl_placeholder = @"暂无公告";
        textView.bjl_placeholderColor = textView.bjl_placeholderColor ?: [UIColor colorWithRed:0.0 green:0.0 blue:0.0980392 alpha:0.22];
        textView.textContainer.lineFragmentPadding = 0.0;
        textView.textContainerInset = UIEdgeInsetsMake(BJLViewSpaceM, BJLViewSpaceM, BJLViewSpaceM, BJLViewSpaceM);
        textView.returnKeyType = UIReturnKeyDefault;
        textView.enablesReturnKeyAutomatically = NO;
        textView.editable = NO;
        textView.bounces = NO;
        // textView.delegate = self;
        textView.layer.cornerRadius = BJLButtonCornerRadius;
        textView.layer.masksToBounds = YES;
        [self.scrollView addSubview:textView];
        textView;
    });
    
    self.tipsLabel = ({
        UILabel *label = [UILabel new];
        label.text = @"点击公告可以跳转";
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = [UIColor bjl_grayBorderColor];
        label.textAlignment = NSTextAlignmentRight;
        [self.scrollView addSubview:label];
        label;
    });
}

- (void)makeConstraints {
    [self.noticeTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView).with.inset(BJLViewSpaceL);
        make.left.right.equalTo(@[self.view.bjl_safeAreaLayoutGuide ?: self.view, self.scrollView]).with.inset(BJLViewSpaceL);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.noticeTextView);
        make.top.equalTo(self.noticeTextView.mas_bottom).with.offset(BJLViewSpaceM);
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.tipsLabel.mas_bottom).with.offset(BJLViewSpaceL * 2);
    }];
}

- (void)makeActions {
    bjl_weakify(self);
    [self.noticeTextView addGestureRecognizer:[UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer * _Nullable gesture) {
        bjl_strongify(self);
        if (self.room.roomVM.notice.linkURL) {
            UIApplication *application = [UIApplication sharedApplication];
            if (@available(iOS 10.0, *)) {
                [application openURL:self.room.roomVM.notice.linkURL
                             options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO}
                   completionHandler:nil];
            }
            else if ([application canOpenURL:self.room.roomVM.notice.linkURL]) {
                [application openURL:self.room.roomVM.notice.linkURL];
            }
        }
    }]];
}

- (void)makeObserving {
    bjl_weakify(self);
    
    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, notice)
         observer:^BOOL(id _Nullable old, BJLNotice * _Nullable notice) {
             bjl_strongify(self);
             [self updateNotice];
             return YES;
         }];
}

- (void)updateNotice {
    if (!self.parentViewController) {
        return;
    }
    
    BJLNotice *notice = self.room.roomVM.notice;
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    self.noticeTextView.text = notice.noticeText.length ? notice.noticeText : nil;
    [self.noticeTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat height = [self.noticeTextView sizeThatFits:CGSizeMake(CGRectGetWidth(self.noticeTextView.frame), 0.0)].height;
        make.height.equalTo(@(height + BJLViewSpaceS));
    }];
    
    [self.noticeTextView setNeedsLayout];
    [self.noticeTextView layoutIfNeeded];
    CGRect textContainerRect = UIEdgeInsetsInsetRect(self.noticeTextView.bounds,
                                                     self.noticeTextView.textContainerInset);
    self.noticeTextView.textContainer.size = textContainerRect.size;
    
    self.tipsLabel.hidden = !notice.linkURL;
}

@end

NS_ASSUME_NONNULL_END
