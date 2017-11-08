//
//  BJLOverlayViewController.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-11.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLOverlayViewController.h"

#import "BJLViewControllerImports.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLOverlayViewController ()

@property (nonatomic) BJLOverlayContainerController *containerController;
@property (nonatomic, nullable) void (^remakeConstraintsBlock)(MASConstraintMaker *make, UIView *superView, BOOL isHorizontal);

@property (nonatomic) UIRectEdge horEdges, verEdges;
@property (nonatomic) CGSize horSize, verSize;

@end

@implementation BJLOverlayViewController

#pragma mark - lifecycle

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.horEdges = self.verEdges = UIRectEdgeNone;
        self.horSize = self.verSize = CGSizeZero;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self resetToDefaultStyle];
    
    self.containerController = ({
        BJLOverlayContainerController *controller = [BJLOverlayContainerController new];
        [self bjl_addChildViewController:controller superview:self.view];
        controller;
    });
    
    bjl_weakify(self);
    UITapGestureRecognizer *tap = [UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer * _Nullable gesture) {
        bjl_strongify(self);
        CGPoint location = [gesture locationInView:gesture.view];
        UIView *subview = [gesture.view hitTest:location withEvent:nil];
        if (subview != self.view) {
            return;
        }
        
        [self hide];
    }];
    // !!!: tap.cancelsTouchesInView 默认 YES，导致 childVC 的 `tableView:didSelectRowAtIndexPath:` 方法不被调用
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)updateViewConstraints {
    CGSize size = self.view.bounds.size;
    BOOL isHorizontal = size.width > size.height; // BJLIsHorizontalUI(self)
    [self updateConstraintsForHorizontal:isHorizontal];
    [super updateViewConstraints];
}

- (void)updateConstraintsForHorizontal:(BOOL)isHorizontal {
    [self.containerController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.remakeConstraintsBlock) {
            self.remakeConstraintsBlock(make, self.view, isHorizontal);
            return;
        }
        
        UIRectEdge edges = isHorizontal ? self.horEdges : self.verEdges;
        CGSize size = isHorizontal ? self.horSize : self.verSize;
        
        BOOL centerX = !(edges & UIRectEdgeLeft || edges & UIRectEdgeRight);
        if (centerX) {
            make.centerX.equalTo(self.view);
        }
        else {
            if (edges & UIRectEdgeLeft) make.left.equalTo(self.view);
            if (edges & UIRectEdgeRight) make.right.equalTo(self.view);
        }
        
        BOOL centerY = !(edges & UIRectEdgeTop || edges & UIRectEdgeBottom);
        if (centerY) {
            make.centerY.equalTo(self.view);
        }
        else {
            if (edges & UIRectEdgeTop) make.top.equalTo(self.view);
            if (edges & UIRectEdgeBottom) make.bottom.equalTo(self.view);
        }
        
        BOOL ignoreWidth = size.width <= 0.0 || (edges & UIRectEdgeLeft && edges & UIRectEdgeRight);
        if (!ignoreWidth) {
            make.width.equalTo(@(size.width));
        }
        
        BOOL ignoreHeight = size.height <= 0.0 || (edges & UIRectEdgeTop && edges & UIRectEdgeBottom);
        if (!ignoreHeight) {
            make.height.equalTo(@(size.height));
        }
        
        make.left.top.greaterThanOrEqualTo(self.view).priorityHigh();
        make.right.bottom.lessThanOrEqualTo(self.view).priorityHigh();
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    {
        // TODO: MingLQ - 选图过程中键盘来回隐藏、显示体验太差
        // 解决 iOS8&9 聊天输入页面选图、返回后，布局出错的问题
        // 解决 iOS10 横屏时聊天输入页面拍照、返回后，布局出错的问题
        // @see - [self updateViewConstraints]
        [self.view setNeedsUpdateConstraints];
    }
}

#pragma mark - style

@synthesize prefersStatusBarHidden = _prefersStatusBarHidden, preferredStatusBarStyle = _preferredStatusBarStyle;

@dynamic backgroundColor;
- (UIColor *)backgroundColor {
    return self.view.backgroundColor;
}
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.view.backgroundColor = backgroundColor;
}

- (BOOL)isHidden {
    return self.view.hidden;
}

- (void)resetToDefaultStyle {
    self.preferredStatusBarStyle = UIStatusBarStyleLightContent;
    self.prefersStatusBarHidden = YES;
    self.view.backgroundColor = [UIColor bjl_lightDimColor];
    self.view.hidden = YES;
}

#pragma mark - <UIContentContainer>

/**
 在 iPad 需要根据屏幕尺寸区分横竖屏，否则竖屏时内容可能会全屏盖住整个页面
 `willTransitionToTraitCollection:withTransitionCoordinator:` 方法在 iPad 上不执行、即使执行也无法区分横竖屏
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSLog(@"%@ viewWillTransitionToSize: %@",
          NSStringFromClass([self class]), NSStringFromCGSize(size));
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        // @see - [self updateViewConstraints]
        [self.view setNeedsUpdateConstraints];
    } completion:nil];
}

#pragma mark - public

- (void)showWithContentViewController:(UIViewController *)contentViewController
               remakeConstraintsBlock:(void (^)(MASConstraintMaker *make, UIView *superView, BOOL isHorizontal))remakeConstraintsBlock {
    self.containerController.contentViewController = contentViewController;
    
    self.remakeConstraintsBlock = remakeConstraintsBlock;
    
    self.view.hidden = NO;
    [self.view setNeedsUpdateConstraints];
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (self.showCallback) self.showCallback(self);
}

- (void)showWithContentViewController:(UIViewController *)contentViewController
                             horEdges:(UIRectEdge)horEdges horSize:(CGSize)horSize
                             verEdges:(UIRectEdge)verEdges verSize:(CGSize)verSize {
    self.containerController.contentViewController = contentViewController;
    
    self.horEdges = horEdges;
    self.horSize = horSize;
    self.verEdges = verEdges;
    self.verSize = verSize;
    
    self.view.hidden = NO;
    [self.view setNeedsUpdateConstraints];
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (self.showCallback) self.showCallback(self);
}

- (void)showWithContentViewController:(UIViewController *)contentViewController {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat screenMin = MIN(screenSize.width, screenSize.height);
    CGFloat screenMax = MAX(screenSize.width, screenSize.height);
    CGFloat horWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
                        ? screenMin : screenMax / 2);
    [self showWithContentViewController:contentViewController
                               horEdges:UIRectEdgeRight | UIRectEdgeTop | UIRectEdgeBottom
                                horSize:CGSizeMake(horWidth, screenMin)
                               verEdges:UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight
                                verSize:CGSizeMake(screenMin, screenMin)];
}

- (void)hide {
    [self bjl_dismissPresentedViewControllerAnimated:NO completion:nil];
    
    [self resetToDefaultStyle];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.containerController.contentViewController = nil;
    self.remakeConstraintsBlock = nil;
    [self.containerController updateTitle:nil];
    [self.containerController updateRightButtons:nil];
    [self.containerController updateFooterView:nil];
    
    if (self.hideCallback) self.hideCallback(self);
}

@end

NS_ASSUME_NONNULL_END
