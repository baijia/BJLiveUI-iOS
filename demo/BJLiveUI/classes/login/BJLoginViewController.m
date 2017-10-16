//
//  BJLoginViewController.m
//  LivePlayerApp
//
//  Created by MingLQ on 2016-07-01.
//  Copyright © 2016年 Baijiahulian. All rights reserved.
//

#import "BJLoginViewController.h"
#import "BJLoginView.h"

#import "BJViewControllerImports.h"

#import <BJLiveUI/BJLiveUI.h>

// !!!: GSX
#import "BJAppConfig.h"

static NSString * const BJLoginCodeKey = @"BJLoginCode";
static NSString * const BJLoginNameKey = @"BJLoginName";

@interface BJLoginViewController () <UITextFieldDelegate, BJLRoomViewControllerDelegate>

@property (nonatomic) BJLoginView *codeLoginView;

@end

@implementation BJLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.codeLoginView = [self createLoginView];
    
    [self setCode:[userDefaults stringForKey:BJLoginCodeKey]
             name:[userDefaults stringForKey:BJLoginNameKey]];
    
    [self makeSignals];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (BOOL)shouldAutorotate {
    return ([UIApplication sharedApplication].statusBarOrientation
            != UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - subview

- (BJLoginView *)createLoginView {
    BJLoginView *loginView = [BJLoginView new];
    [self.view addSubview:loginView];
    [loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    return loginView;
}

- (void)makeSignals {
    bjl_weakify(self);
    
    // endEditing
    UITapGestureRecognizer *tapGesture = [UITapGestureRecognizer new];
    [self.view addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer *panGesture = [UIPanGestureRecognizer new];
    [self.view addGestureRecognizer:panGesture];
    [[RACSignal merge:@[ tapGesture.rac_gestureSignal,
                         panGesture.rac_gestureSignal ]]
     subscribeNext:^(UIGestureRecognizer *gesture) {
         bjl_strongify(self);
         [self.view endEditing:YES];
     }];
    
    // clear cache if changed
    [[[self.codeLoginView.codeTextField.rac_textSignal
       distinctUntilChanged]
      skip:1]
     subscribeNext:^(NSString *codeText) {
         // bjl_strongify(self);
         NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
         [userDefaults removeObjectForKey:BJLoginCodeKey];
         [userDefaults synchronize];
     }];
    [[[self.codeLoginView.nameTextField.rac_textSignal
       distinctUntilChanged]
      skip:1]
     subscribeNext:^(NSString *nameText) {
         // bjl_strongify(self);
         NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
         [userDefaults removeObjectForKey:BJLoginNameKey];
         [userDefaults synchronize];
     }];
    
    // delegate
    self.codeLoginView.codeTextField.delegate = self;
    self.codeLoginView.nameTextField.delegate = self;
    
    // doneButton.enabled
    [[RACSignal
      combineLatest:@[ [RACSignal merge:@[ self.codeLoginView.codeTextField.rac_textSignal,
                                           RACObserve(self.codeLoginView.codeTextField, text) ]],
                       [RACSignal merge:@[ self.codeLoginView.nameTextField.rac_textSignal,
                                           RACObserve(self.codeLoginView.nameTextField, text) ]] ]
      reduce:^id(NSString *codeText, NSString *nameText) {
          // bjl_strongify(self);
          return @(codeText.length && nameText.length);
      }]
     subscribeNext:^(NSNumber *enabled) {
         bjl_strongify(self);
         self.codeLoginView.doneButton.enabled = enabled.boolValue;
     }];
    
    // login
    [[self.codeLoginView.doneButton rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(UIButton *button) {
         bjl_strongify(self);
         [self doneWithButton:button];
     }];
}

#pragma mark - events

- (void)doneWithButton:(UIButton *)button {
    [self.view endEditing:YES];
    
    [self enterRoomWithJoinCode:self.codeLoginView.codeTextField.text
                       userName:self.codeLoginView.nameTextField.text];
}

#pragma mark - actions

- (void)enterRoomWithJoinCode:(NSString *)joinCode userName:(NSString *)userName {
    [self storeCodeAndName];
    
//    BJLRoomViewController *roomViewController = [BJLRoomViewController
//                                                 instanceWithID:@"170314xxxxxxxx"
//                                                 apiSign:@"b8a5eddbxxxxxxxxxxxxxxxxxxxxe5a8"
//                                                 user:[BJLUser
//                                                       userWithNumber:@"100000000"
//                                                       name:@"mlq"
//                                                       avatar:@"https://xxxx.png"
//                                                       role:BJLUserRole_student]];
    
    BJLRoomViewController *roomViewController = [BJLRoomViewController
                                                 instanceWithSecret:joinCode
                                                 userName:userName
                                                 userAvatar:nil];
    roomViewController.delegate = self;
    [self presentViewController:roomViewController animated:YES completion:nil];
}

#pragma mark - state

- (void)setCode:(NSString *)code name:(NSString *)name {
    BJLoginView *loginView = self.codeLoginView;
    loginView.codeTextField.text = code;
    loginView.nameTextField.text = name;
    loginView.doneButton.enabled = code.length && name.length;
}

- (void)storeCodeAndName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.codeLoginView.codeTextField.text
                     forKey:BJLoginCodeKey];
    [userDefaults setObject:self.codeLoginView.nameTextField.text
                     forKey:BJLoginNameKey];
    [userDefaults synchronize];
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.codeLoginView.codeTextField) {
        [self.codeLoginView.nameTextField becomeFirstResponder];
    }
    else if (textField == self.codeLoginView.nameTextField) {
        if (self.codeLoginView.doneButton.enabled) {
            [self doneWithButton:self.codeLoginView.doneButton];
        }
    }
    return NO;
}

#pragma mark - <BJLRoomViewControllerDelegate>

/** 进入教室 - 成功 */
- (void)roomViewControllerEnterRoomSuccess:(BJLRoomViewController *)roomViewController {
    NSLog(@"[%@ %@]", NSStringFromSelector(_cmd), roomViewController);
}

/** 进入教室 - 失败 */
- (void)roomViewController:(BJLRoomViewController *)roomViewController
 enterRoomFailureWithError:(BJLError *)error {
    NSLog(@"[%@ %@, %@]", NSStringFromSelector(_cmd), roomViewController, error);
}

/**
 退出教室 - 正常/异常
 正常退出 `error` 为 `nil`，否则为异常退出
 参考 `BJLErrorCode` */
- (void)roomViewController:(BJLRoomViewController *)roomViewController
         willExitWithError:(nullable BJLError *)error {
    NSLog(@"[%@ %@, %@]", NSStringFromSelector(_cmd), roomViewController, error);
}

/**
 退出教室 - 正常/异常
 正常退出 `error` 为 `nil`，否则为异常退出
 参考 `BJLErrorCode` */
- (void)roomViewController:(BJLRoomViewController *)roomViewController
          didExitWithError:(nullable BJLError *)error {
    NSLog(@"[%@ %@, %@]", NSStringFromSelector(_cmd), roomViewController, error);
}

/**
 点击教室右上方自定义按钮回调
 此方法返回的 view-controller 可以像用户列表一样显示在教室内
 `didMoveToParentViewController:` 后 view-controller 的 `bjl_overlayContainerController` 属性可用
 通过该属性可以设置统一样式的标题、导航栏按钮、底部按钮、以及关闭等，参考 `BJLOverlayContainerController`
 */
- (nullable UIViewController *)roomViewController:(BJLRoomViewController *)roomViewController
        viewControllerToShowForTopBarCustomButton:(UIButton *)button {
    return nil;
}

@end
