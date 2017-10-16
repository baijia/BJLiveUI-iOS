//
//  BJLNoticeEditViewController.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-08.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/UITextView+BJLPlaceholder.h>

#import "BJLNoticeEditViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLNoticeEditViewController ()

@property (nonatomic, readonly, weak) BJLRoom *room;

@property (nonatomic) UIView *contentView;

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIButton *doneButton;

@property (nonatomic) UIView *textGroupView, *separatorLine;
@property (nonatomic) UITextView *noticeTextView;
@property (nonatomic, nullable) UITextField *linkTextField;

@end

@implementation BJLNoticeEditViewController

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
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self makeSubviews];
    [self makeConstraints];
    [self makeActions];
    
    [self updateButtonStates];
    
    // layout before keyboard animation
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrameWithNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.noticeTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}

- (void)keyboardWillChangeFrameWithNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (!userInfo) {
        return;
    }
    
    CGRect keyboardFrame = bjl_cast(NSValue, userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
    NSTimeInterval animationDuration = bjl_cast(NSNumber, userInfo[UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
    UIViewAnimationOptions animationOptions = ({
        NSNumber *animationCurveNumber = bjl_cast(NSNumber, userInfo[UIKeyboardAnimationCurveUserInfoKey]);
        UIViewAnimationCurve animationCurve = (animationCurveNumber != nil
                                               ? animationCurveNumber.unsignedIntegerValue
                                               : UIViewAnimationCurveEaseInOut);
        // @see http://stackoverflow.com/a/19490788/456536
        animationCurve | animationCurve << 16; // @see UIViewAnimationOptionCurveXxxx
    });
    
    [self.view layoutIfNeeded];
    CGFloat offset = (CGRectGetMinY(keyboardFrame) >= CGRectGetHeight([UIScreen mainScreen].bounds)
                      ? 0.0 : - CGRectGetHeight(keyboardFrame));
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(offset);
    }];
    [self.view setNeedsLayout];
    // TODO: MingLQ - animate not working
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationOptions
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)makeSubviews {
    self.contentView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor bjl_lightGrayBackgroundColor];
        [self.view addSubview:view];
        view;
    });
    
    self.titleLabel = ({
        UILabel *label = [UILabel new];
        label.text = @"公告";
        label.font = [UIFont systemFontOfSize:16.0];
        label.textColor = [UIColor bjl_darkGrayTextColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        label;
    });
    
    self.doneButton = ({
        UIButton *button = [UIButton new];
        button.titleLabel.font = [UIFont systemFontOfSize:15.0];
        
        // if self.doneButton.selected then save
        // otherwise show valid error
        [button setTitle:@"保存" forState:UIControlStateNormal];
        [button setTitle:@"保存" forState:UIControlStateNormal | UIControlStateHighlighted];
        [button setTitleColor:[[UIColor bjl_blueBrandColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
        [button setTitleColor:[[UIColor bjl_blueBrandColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal | UIControlStateHighlighted];
        
        // self.doneButton.selected = self.doneButton.enabled && [self isValid];
        [button setTitle:@"保存" forState:UIControlStateSelected];
        [button setTitle:@"保存" forState:UIControlStateSelected | UIControlStateHighlighted];
        [button setTitleColor:[UIColor bjl_blueBrandColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor bjl_blueBrandColor] forState:UIControlStateSelected | UIControlStateHighlighted];
        
        // self.doneButton.enabled = [self isChanged];
        [button setTitle:@"已保存" forState:UIControlStateDisabled];
        [button setTitleColor:[UIColor bjl_lightGrayTextColor] forState:UIControlStateDisabled];
        
        [self.contentView addSubview:button];
        button;
    });
    
    self.textGroupView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderWidth = BJLOnePixel;
        view.layer.borderColor = [UIColor bjl_grayBorderColor].CGColor;
        view.layer.cornerRadius = BJLButtonCornerRadius;
        view.layer.masksToBounds = YES;
        [self.contentView addSubview:view];
        view;
    });
    
    self.noticeTextView = ({
        UITextView *textView = [UITextView new];
        textView.font = [UIFont systemFontOfSize:15.0];
        textView.textColor = [UIColor bjl_darkGrayTextColor];
        textView.bjl_placeholder = @"输入公告内容";
        textView.bjl_placeholderColor = textView.bjl_placeholderColor ?: [UIColor colorWithRed:0.0 green:0.0 blue:0.0980392 alpha:0.22];
        textView.textContainer.lineFragmentPadding = 0.0;
        textView.textContainerInset = UIEdgeInsetsMake(BJLViewSpaceM, BJLViewSpaceM, BJLViewSpaceM, BJLViewSpaceM);
        textView.backgroundColor = [UIColor clearColor];
        textView.returnKeyType = UIReturnKeyDefault;
        textView.enablesReturnKeyAutomatically = NO;
        textView.delegate = self;
        [self.textGroupView addSubview:textView];
        textView;
    });
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (MIN(screenSize.width, screenSize.height) > 320.0) {
        self.linkTextField = ({
            BJLTextField *textField = [BJLTextField new];
            textField.font = [UIFont systemFontOfSize:14.0];
            textField.textColor = [UIColor bjl_darkGrayTextColor];
            textField.placeholder = @"为公告添加网址";
            textField.textInsets = textField.editingInsets = UIEdgeInsetsMake(0.0, BJLViewSpaceM, 0.0, 0.0);
            textField.backgroundColor = [UIColor clearColor];
            textField.rightView = ({
                UILabel *label = [UILabel new];
                label.text = @"选填";
                label.font = [UIFont systemFontOfSize:14.0];
                label.textColor = [UIColor bjl_lightGrayTextColor];
                label.textAlignment = NSTextAlignmentLeft;
                label;
            });
            textField.rightViewMode = UITextFieldViewModeAlways;
            [textField.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
                CGSize size = textField.rightView.intrinsicContentSize;
                size.width += BJLViewSpaceM;
                make.size.mas_equalTo(size);
            }];
            // textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.keyboardType = UIKeyboardTypeURL;
            textField.returnKeyType = UIReturnKeyDefault;
            textField.enablesReturnKeyAutomatically = NO;
            textField.delegate = self;
            [self.textGroupView addSubview:textField];
            textField;
        });
        
        self.separatorLine = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor bjl_grayBorderColor];
            [self.textGroupView addSubview:view];
            view;
        });
    }
}

- (void)makeConstraints {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(0); // to be update
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView.bjl_safeAreaLayoutGuide ?: self.contentView).inset(BJLViewSpaceL);
        make.top.equalTo(self.contentView).inset(BJLViewSpaceL);
    }];
    
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.titleLabel);
        make.centerY.equalTo(self.titleLabel);
    }];
    
    [self.textGroupView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.bottom.equalTo(self.contentView).with.inset(BJLViewSpaceL);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(BJLViewSpaceM);
    }];
    
    NSString *originText = self.noticeTextView.text;
    self.noticeTextView.text = [@[@"", @""] // 2 lines
                                componentsJoinedByString:@"\n"];
    CGFloat height = [self.noticeTextView sizeThatFits:CGSizeMake(CGRectGetWidth(self.noticeTextView.frame), 0)].height;
    self.noticeTextView.text = originText;
    
    [self.noticeTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.textGroupView);
        make.height.equalTo(@(height));
        if (!self.linkTextField) {
            make.bottom.equalTo(self.textGroupView);
        }
    }];
    
    if (self.linkTextField) {
        [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.textGroupView);
            make.top.equalTo(self.noticeTextView.mas_bottom);
            make.height.equalTo(@(BJLOnePixel));
        }];
        
        [self.linkTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.noticeTextView);
            make.top.equalTo(self.separatorLine);
            make.bottom.equalTo(self.textGroupView);
            make.height.equalTo(@40.0);
        }];
    }
}

- (void)makeActions {
    bjl_weakify(self);
    
    [self.doneButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (!self.doneButton.selected) {
            return;
        }
        [sender bjl_disableForSeconds:BJLRobotDelayS];
        [self done];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.linkTextField bjl_addHandler:^(__kindof UITextField * _Nullable textField) {
        bjl_strongify(self);
        [self updateButtonStates];
    } forControlEvents:UIControlEventAllEditingEvents];
}

- (void)makeObserving {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room.roomVM, notice)
         observer:^BOOL(id _Nullable old, BJLNotice * _Nullable notice) {
             bjl_strongify(self);
             [self reset];
             return YES;
         }];
}

// @see self.doneButton = ...
- (void)updateButtonStates {
    BOOL isChanged = [self isChanged];
    self.doneButton.enabled = isChanged;
    self.doneButton.selected = isChanged && [self isValid];
}

- (BOOL)isChanged {
    BJLNotice *notice = self.room.roomVM.notice;
    return (![self.noticeTextView.text ?: @"" isEqualToString:notice.noticeText ?: @""]
             || ![self.linkTextField.text ?: @"" isEqualToString:notice.linkURL.absoluteString ?: @""]);
}

- (BOOL)isValid {
    return !self.linkTextField.text.length || [self validURLWithFromString:self.linkTextField.text];
}

- (NSURL *)validURLWithFromString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if (urlString.length && !url.scheme.length) {
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:urlString]];
    }
    return [@[@"http", @"https", @"tel", @"mailto"] containsObject:[url.scheme lowercaseString]] ? url : nil;
}

- (void)reset {
    BJLNotice *notice = self.room.roomVM.notice;
    self.noticeTextView.text = (notice.noticeText.length ? notice.noticeText : nil);
    self.linkTextField.text = [notice.linkURL absoluteString];
    
    [self updateButtonStates];
}

- (void)done {
    NSURL *url = [self validURLWithFromString:self.linkTextField.text];
    if (url) {
        self.linkTextField.text = [url absoluteString];
    }
    [self.room.roomVM sendNoticeWithText:self.noticeTextView.text linkURL:url];
}

#pragma mark - <UITextFieldDelegate>

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    /*
    if (textField == self.linkTextField) {
        [self.view endEditing:YES];
    } */
    return NO;
}

#pragma mark - <UITextViewDelegate>

- (void)textViewDidBeginEditing:(UITextView *)textView {
}

- (void)textViewDidEndEditing:(UITextView *)textView {
}

- (void)textViewDidChange:(UITextView *)textView {
    // max length
    if (textView.text.length > BJLTextMaxLength_notice) {
        UITextRange *markedTextRange = textView.markedTextRange;
        if (!markedTextRange || markedTextRange.isEmpty) {
            textView.text = [textView.text substringToIndex:BJLTextMaxLength_notice];
        }
    }
    [self updateButtonStates];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    /*
    if ([text isEqualToString:@"\n"]) {
        return NO;
    } */
    return YES;
}

@end

NS_ASSUME_NONNULL_END
