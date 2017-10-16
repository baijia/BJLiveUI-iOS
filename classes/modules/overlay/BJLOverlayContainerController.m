//
//  BJLOverlayContainerController.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-14.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/NSObject+BJL_M9Dev.h>
#import <Masonry/Masonry.h>

#import "BJLViewControllerImports.h"
#import "BJLOverlayContainerController.h"
#import "BJLOverlayViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLOverlayContainerController ()

@property (nonatomic) UIView *headerContainerView, *contentContainerView, *footerContainerView;

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIView *buttonsStackView;
@property (nonatomic, copy, nullable) NSArray<UIButton *> *rightButtons;

@property (nonatomic, nullable) UIView *footerView;

@end

@implementation BJLOverlayContainerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    
    [self makeSubviews];
    [self makeConstraints];
    
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self, contentViewController)
         observer:^BOOL(UIViewController * _Nullable old, UIViewController * _Nullable now) {
             bjl_strongify(self);
             [old bjl_removeFromParentViewControllerAndSuperiew];
             if (now) {
                 [self bjl_addChildViewController:self.contentViewController
                                        superview:self.contentContainerView];
                 [self.contentViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
                     make.edges.equalTo(self.contentContainerView);
                 }];
             }
             return YES;
         }];
}

- (void)updateViewConstraints {
    [self updateHeaderViewConstraints];
    [super updateViewConstraints];
}

#pragma mark - <UIContentContainer>

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    NSLog(@"%@ willTransitionToSizeClasses: %td-%td",
          NSStringFromClass([self class]), newCollection.horizontalSizeClass, newCollection.verticalSizeClass);
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        // @see - [self updateViewConstraints]
        [self.view setNeedsUpdateConstraints];
    } completion:nil];
}

#pragma mark - private

- (void)makeSubviews {
    self.headerContainerView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor bjl_grayLineColor];
        [view addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).with.offset(BJLViewSpaceL);
            make.right.greaterThanOrEqualTo(view); // fix warning if view.width == 0.0
            make.bottom.equalTo(view);
            make.height.equalTo(@(BJLOnePixel));
        }];
        
        [self.view addSubview:view];
        view;
    });
    
    self.footerContainerView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:view];
        view;
    });
    
    self.contentContainerView = ({
        UIView *view = [UIView new];
        [self.view insertSubview:view atIndex:0];
        view;
    });
    
    self.titleLabel = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:16.0];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor blackColor];
        [self.headerContainerView addSubview:label];
        label;
    });
    
    self.buttonsStackView = ({
        UIView *view = [UIView new];
        view.clipsToBounds = YES;
        [self.headerContainerView addSubview:view];
        view;
    });
}

- (void)makeConstraints {
    // degbug
    MASAttachKeys(self.view,
                  self.headerContainerView,
                  self.contentContainerView,
                  self.footerContainerView,
                  self.titleLabel,
                  self.buttonsStackView);
    
    [self.headerContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.top.equalTo(self.view);
        if (self.view.bjl_safeAreaLayoutGuideTop) {
            make.bottom.greaterThanOrEqualTo(self.view.bjl_safeAreaLayoutGuideTop).offset(0.0); // to be update
        }
        else {
            make.height.equalTo(@0.0); // to be update
        }
    }];
    
    [self.footerContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(@0.0).priorityHigh();
    }];
    
    [self.contentContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.headerContainerView.mas_bottom);
        make.bottom.equalTo(self.footerContainerView.mas_top);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerContainerView.bjl_safeAreaLayoutGuide ?: self.headerContainerView).with.offset(BJLViewSpaceL);
        make.top.bottom.equalTo(self.headerContainerView.bjl_safeAreaLayoutGuide ?: self.headerContainerView);
    }];
    
    [self.buttonsStackView setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                           forAxis:UILayoutConstraintAxisHorizontal];
    [self.buttonsStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.titleLabel.mas_right).with.offset(BJLViewSpaceL);
        make.right.top.bottom.equalTo(self.headerContainerView.bjl_safeAreaLayoutGuide ?: self.headerContainerView);
    }];
}

- (void)updateHeaderViewConstraints {
    BOOL shown = self.titleLabel.text.length || self.rightButtons.count;
    self.headerContainerView.hidden = !shown;
    
    /*
    BOOL isHorizontal = BJLIsHorizontalUI(self);
    BOOL hasStatusBar = ![UIApplication sharedApplication].isStatusBarHidden; // */
    
    CGFloat headerHeight = shown ? BJLControlSize : 0.0;
    [self.headerContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (self.view.bjl_safeAreaLayoutGuideTop) {
            make.bottom.greaterThanOrEqualTo(self.view.bjl_safeAreaLayoutGuideTop).offset(headerHeight); // to be update
        }
        else {
            make.height.equalTo(@(headerHeight));
        }
    }];
}

#pragma mark - public

- (void)updateTitle:(nullable NSString *)title {
    self.titleLabel.text = title;
    [self updateHeaderViewConstraints];
}

- (void)updateRightButton:(nullable UIButton *)rightButton {
    [self updateRightButtons:rightButton ? @[rightButton] : nil];
}

- (void)updateRightButtons:(nullable NSArray<UIButton *> *)rightButtons {
    [self.rightButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.rightButtons = rightButtons;
    
    UIButton *last = nil;
    for (UIButton *button in self.rightButtons) {
        [self.buttonsStackView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(last.mas_left ?: self.buttonsStackView).with.offset(- (last ? BJLViewSpaceM : BJLViewSpaceL));
            make.centerY.equalTo(self.buttonsStackView);
            make.top.bottom.equalTo(self.buttonsStackView).priorityHigh();
        }];
        last = button;
    }
    [last mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.buttonsStackView).priorityHigh();
    }];
    
    [self updateHeaderViewConstraints];
}

- (void)updateFooterView:(nullable UIView *)footerView {
    [self.footerView removeFromSuperview];
    
    self.footerView = footerView;
    
    if (footerView) {
        [self.footerContainerView addSubview:footerView];
        [footerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.footerContainerView.bjl_safeAreaLayoutGuide ?: self.footerContainerView);
        }];
    }
    
    BOOL shown = !!footerView;
    self.footerContainerView.hidden = !shown;
}

- (void)hide {
    [bjl_cast(BJLOverlayViewController, self.parentViewController) hide];
}

@end

#pragma mark -

@implementation UIViewController (BJLOverlayContentViewController)

- (nullable BJLOverlayContainerController *)bjl_overlayContainerController {
    return [self.parentViewController bjl_as:[BJLOverlayContainerController class]];
}

@end

NS_ASSUME_NONNULL_END
