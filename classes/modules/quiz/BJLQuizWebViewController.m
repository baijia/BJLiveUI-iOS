//
//  BJLQuizWebViewController.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-05-31.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLUserAgent.h>
#import <WebKit/WebKit.h>

#import "BJLQuizWebViewController.h"

#import "BJLViewControllerImports.h"
#import "BJLOverlayViewController.h"

NS_ASSUME_NONNULL_BEGIN

// http://ewiki.baijiahulian.com/%E7%99%BE%E5%AE%B6%E4%BA%91/APP/APP%20%E5%86%85%E5%B5%8C%20H5%20%E5%B0%8F%E6%B5%8B%E9%AA%8C.md
// http://ewiki.baijiahulian.com/%E8%A7%86%E9%A2%91/%E5%89%8D%E7%AB%AF/%E7%9B%B4%E6%92%AD/%E7%9B%B4%E6%92%AD%E4%BF%A1%E4%BB%A4.md#page-nav-123

#define jsLog           "log"
#define jsWebView       "webview"
#define jsWebViewClose      "close"
#define jsMessage       "message"

static NSString * const jsInjection = @
"(function() {\n"
"    var bjlapp = this.bjlapp = this.bjlapp || {};\n"
"    // APP implementation\n"
"    bjlapp.log = function(log) {\n"
"        window.webkit.messageHandlers." jsLog ".postMessage(log);\n"
"    };\n"
"    bjlapp.close = function() {\n"
"        window.webkit.messageHandlers." jsWebView ".postMessage('" jsWebViewClose "');\n"
"    };\n"
"    bjlapp.sendMessage = function(json) {\n"
"        window.webkit.messageHandlers." jsMessage ".postMessage(json);\n"
"    };\n"
"    // H5 implementation\n"
"    bjlapp.receivedMessage = bjlapp.receivedMessage || function(json) {\n"
"        // abstract\n"
"    };\n"
#if DEBUG
"    bjlapp.log('injected');\n"
#endif
"})();\n";

@interface BJLQuizWebViewController () <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic) BOOL closable;
@property (nonatomic) NSURLRequest *request;
@property (nonatomic, nullable) NSMutableArray<NSDictionary<NSString *, id> *> *messages;

@property (nonatomic) UIView *progressView;
@property (nonatomic) UIButton *reloadButton, *closeButton;

@end

@implementation BJLQuizWebViewController

+ (nullable instancetype)instanceWithQuizMessage:(NSDictionary<NSString *, id> *)message roomVM:(BJLRoomVM *)roomVM {
    NSString *messageType = [message bjl_stringForKey:@"message_type"];
    
    BOOL isQuizStart = [messageType isEqualToString:@"quiz_start"];
    BOOL isQuizResponse = [messageType isEqualToString:@"quiz_res"];
    BOOL isQuizSolution = [messageType isEqualToString:@"quiz_solution"];
    if (!isQuizStart && !isQuizResponse && !isQuizSolution) {
        return nil;
    }
    
    NSString *quizID = [message bjl_stringForKey:@"quiz_id"];
    BOOL quizEnd = [message bjl_boolForKey:@"end_flag"];
    BOOL quizDid = [message bjl_dictionaryForKey:@"solution"].count > 0;
    if (isQuizResponse
        && (!quizID.length || quizEnd || quizDid)) {
        return nil;
    }
    
    NSURLRequest *request = [roomVM quizRequestWithID:quizID error:nil];
    if (!request) {
        return nil;
    }
    
    BOOL closable = !isQuizStart || ![message bjl_boolForKey:@"force_join"];
    
    return [[BJLQuizWebViewController alloc] initWithMessage:message
                                                     request:request
                                                    closable:closable];
}

+ (NSDictionary *)quizReqMessageWithUserNumber:(NSString *)userNumber {
    return @{@"message_type": @"quiz_req",
             @"user_number":  userNumber ?: @""};
}

#pragma mark -

- (instancetype)initWithMessage:(NSDictionary<NSString *, id> *)message
                        request:(NSURLRequest *)request
                       closable:(BOOL)closable {
    self = [super initWithConfiguration:({
        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsInjection
                                                          injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                       forMainFrameOnly:YES];
        WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
        configuration.userContentController = [WKUserContentController new];
        [configuration.userContentController addUserScript:userScript];
        [configuration.userContentController addScriptMessageHandler:self.wtfScriptMessageHandler
                                                                name:@(jsLog)];
        [configuration.userContentController addScriptMessageHandler:self.wtfScriptMessageHandler
                                                                name:@(jsWebView)];
        [configuration.userContentController addScriptMessageHandler:self.wtfScriptMessageHandler
                                                                name:@(jsMessage)];
        configuration;
    })];
    if (self) {
        self.request = request;
        self.closable = closable;
        self.messages = [NSMutableArray new];
        [self.messages bjl_addObjectOrNil:message];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userAgentSuffix = [BJLUserAgent defaultInstance].sdkUserAgent;
    
    self.progressView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor bjl_blueBrandColor];
        view;
    });
    
    self.reloadButton = ({
        UIButton *button = [UIButton new];
        [button setTitle:@"加载失败，点击重试" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor bjl_lightGrayTextColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor whiteColor];
        button;
    });
    
    self.closeButton = ({
        UIButton *button = [BJLButton makeTextButtonDestructive:NO];
        [button setTitle:@"关闭" forState:UIControlStateNormal];
        button;
    });
    
    bjl_weakify(self);
    
    [self bjl_kvo:BJLMakeProperty(self.webView, estimatedProgress)
         observer:^BOOL(id _Nullable old, id _Nullable now) {
             bjl_strongify(self);
             if (self.progressView.superview) {
                 [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
                     make.left.top.equalTo(self.view);
                     make.width.equalTo(self.view).multipliedBy(self.webView.estimatedProgress);
                     make.height.equalTo(@(BJLOnePixel));
                 }];
             }
             return YES;
         }];
    
    [self.reloadButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        [self.webView stopLoading];
        [self.webView loadRequest:self.request];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.closeButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"确认关闭测验？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert bjl_addActionWithTitle:@"确认"
                                style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction * _Nonnull action) {
                                  [self.webView stopLoading];
                                  if (self.closeWebViewCallback) self.closeWebViewCallback();
                              }];
        [alert bjl_addActionWithTitle:@"取消"
                                style:UIAlertActionStyleCancel
                              handler:nil];
        [self presentViewController:alert animated:YES completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    NSLog(@"[quiz] request: %@", self.request.URL);
    [self.webView loadRequest:self.request];
}

- (void)didMoveToParentViewController:(nullable UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    
    [self.bjl_overlayContainerController updateTitle:@"测验"]; // 问卷
    
    if (self.closable) {
        [self.bjl_overlayContainerController updateRightButton:self.closeButton];
    }
    else {
        [self.bjl_overlayContainerController updateRightButton:nil];
    }
}

#pragma mark -

- (void)didReceiveQuizMessage:(NSDictionary<NSString *, id> *)message {
    if (self.messages) {
        [self.messages bjl_addObjectOrNil:message];
    }
    else {
        [self forwardQuizMessage:message];
    }
}

- (void)forwardQuizMessage:(NSDictionary<NSString *, id> *)message {
    NSString *js = [NSString stringWithFormat:@"bjlapp.receivedMessage(%@)", ({
        NSData *data = [NSJSONSerialization dataWithJSONObject:message options:0 error:NULL];
        NSString *json = data.length ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        bjl_return json;
    })];
    NSLog(@"[quiz] %@", js);
    // bjl_weakify(self);
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        // bjl_strongify(self);
        NSLog(@"[quiz] return: %@ || %@", result, error);
    }];
}

#pragma mark - loading state

- (void)didStartLoading {
    [self.view addSubview:self.progressView];
    [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(self.webView.estimatedProgress);
        make.height.equalTo(@(BJLOnePixel));
    }];
    
    [self.reloadButton removeFromSuperview];
    
    if (!self.closable) {
        [self.bjl_overlayContainerController updateRightButton:nil];
    }
}

- (void)didFailLoading {
    [self.progressView removeFromSuperview];
    
    [self.view addSubview:self.reloadButton];
    [self.reloadButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    if (!self.closable) {
        [self.bjl_overlayContainerController updateRightButton:self.closeButton];
    }
}

- (void)didFinishLoading {
    [self.progressView removeFromSuperview];
    
    NSArray<NSDictionary<NSString *, id> *> *messages = [self.messages copy];
    self.messages = nil;
    
    for (NSDictionary<NSString *, id> *message in messages) {
        [self forwardQuizMessage:message];
    }
}

#pragma mark - <WKNavigationDelegate>

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"[quiz] didStartProvisionalNavigation: %@", navigation);
    [self didStartLoading];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"[quiz] didFailProvisionalNavigation: %@ || %@", navigation, error);
    [self didFailLoading];
}

/*
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"[quiz] didCommitNavigation: %@", navigation);
} */

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"[quiz] didFailNavigation: %@ || %@", navigation, error);
    [self didFailLoading];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"[quiz] didFinishNavigation: %@", navigation);
    [self didFinishLoading];
}

#pragma mark - <WKUIDelegate>

#pragma mark - <WKScriptMessageHandler>

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"[quiz] %@.postMessage(%@)", message.name, message.body);
    
    if (message.webView != self.webView) {
        return;
    }
    
    if ([message.name isEqualToString:@(jsMessage)]) {
        NSDictionary *json = bjl_cast(NSDictionary, message.body);
        if (self.sendQuizMessageCallback) self.sendQuizMessageCallback(json);
        return;
    }
    
    if ([message.name isEqualToString:@(jsWebView)]) {
        NSString *action = message.body;
        if ([action isEqualToString:@(jsWebViewClose)]) {
            if (self.closeWebViewCallback) self.closeWebViewCallback();
        }
        return;
    }
}

@end

NS_ASSUME_NONNULL_END
