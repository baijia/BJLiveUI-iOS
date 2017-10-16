//
//  BJLContentView.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-22.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLContentView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLContentView ()

@property (nonatomic, readwrite, nullable) UIView *content;
@property (nonatomic) UIButton *pageControlButton, *clearDrawingButton;

@property (nonatomic, readwrite) BJLContentMode contentMode;
@property (nonatomic, readwrite) CGFloat aspectRatio;

@end

@implementation BJLContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // self.backgroundColor = [UIColor bjl_grayImagePlaceholderColor];
        
        [self makeSubviews];
        
        bjl_weakify(self);
        [self addGestureRecognizer:[UITapGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer * _Nullable gesture) {
            bjl_strongify(self);
            if (self.toggleTopBarCallback) self.toggleTopBarCallback(nil);
        }]];
        [self addGestureRecognizer:[UILongPressGestureRecognizer bjl_gestureWithHandler:^(__kindof UIGestureRecognizer * _Nullable gesture) {
            bjl_strongify(self);
            if (self.showMenuCallback) self.showMenuCallback(nil);
        }]];
    }
    return self;
}

- (void)makeSubviews {
    bjl_weakify(self);
    
    self.clearDrawingButton = ({
        BJLButton *button = [BJLButton new];
        [button setImage:[UIImage imageNamed:@"bjl_ic_clearall"] forState:UIControlStateNormal];
        [button setTitle:@"清除" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15.0];
        button.backgroundColor = [UIColor bjl_dimColor];
        button.layer.cornerRadius = BJLButtonSizeM / 2;
        button.layer.masksToBounds = YES;
        button.midSpace = BJLViewSpaceS;
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(BJLViewSpaceM);
            make.width.equalTo(@(BJLButtonSizeM * 2 + BJLViewSpaceM));
            make.bottom.equalTo(self).with.offset(- BJLViewSpaceM);
            make.height.equalTo(@(BJLButtonSizeM));
        }];
        button;
    });
    [self bjl_kvo:BJLMakeProperty(self, showsClearDrawingButton)
         observer:^BOOL(id _Nullable old, id _Nullable now) {
             bjl_strongify(self);
             self.clearDrawingButton.hidden = !self.showsClearDrawingButton;
             return YES;
         }];
    [self.clearDrawingButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.clearDrawingCallback) self.clearDrawingCallback(self);
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.pageControlButton = ({
        const CGFloat buttonWidth = 60.0, buttonHeight = BJLButtonSizeS;
        UIButton *button = [UIButton new];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        button.backgroundColor = [UIColor bjl_lightMostDimColor];
        button.layer.cornerRadius = buttonHeight / 2;
        button.layer.masksToBounds = YES;
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self.clearDrawingButton);
            make.size.mas_equalTo(CGSizeMake(buttonWidth, buttonHeight));
        }];
        button;
    });
    [self bjl_kvo:BJLMakeProperty(self, showsPageControlButton)
         observer:^BOOL(id _Nullable old, id _Nullable now) {
             bjl_strongify(self);
             self.pageControlButton.hidden = !self.showsPageControlButton;
             return YES;
         }];
    [self bjl_kvoMerge:@[ BJLMakeProperty(self, pageCount),
                          BJLMakeProperty(self, pageIndex) ]
              observer:^(id _Nullable old, id _Nullable now) {
                  bjl_strongify(self);
                  if (self.pageIndex == 0) {
                      [self.pageControlButton setTitle:@"白板" forState:UIControlStateNormal];
                  }
                  else {
                      NSString *title = [NSString stringWithFormat:@"%td/%td", self.pageIndex, self.pageCount - 1];
                      [self.pageControlButton setTitle:title forState:UIControlStateNormal];
                  }
              }];
    [self.pageControlButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        if (self.pageControlCallback) self.pageControlCallback(self);
    } forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -

- (void)setContent:(nullable UIView *)content {
    if (content == self.content) {
        return;
    }
    
    NSString *key = NSStringFromSelector(@selector(content));
    [self willChangeValueForKey:key];
    
    if (self.content.superview == self) {
        [self.content removeFromSuperview];
    }
    
    self->_content = content;
    if (content) {
        [self insertSubview:content atIndex:0];
    }
    
    [self didChangeValueForKey:key];
}

- (void (^)(void))animateUpdateContent:(UIView *)content
                           contentMode:(BJLContentMode)contentMode
                           aspectRatio:(CGFloat)aspectRatio {
    [self layoutContent:content contentMode:contentMode aspectRatio:aspectRatio];
    return ^{
        [self updateContent:content contentMode:contentMode aspectRatio:aspectRatio];
    };
}

- (void)updateContent:(UIView *)content
          contentMode:(BJLContentMode)contentMode
          aspectRatio:(CGFloat)aspectRatio {
    if (content == self.content
        && contentMode == self.contentMode
        && aspectRatio == self.aspectRatio) {
        return;
    }
    self.content = content;
    self.contentMode = contentMode;
    self.aspectRatio = aspectRatio;
    
    [self layoutContent:self.content contentMode:contentMode aspectRatio:aspectRatio];
}

- (void)updateWithContentMode:(BJLContentMode)contentMode
                  aspectRatio:(CGFloat)aspectRatio {
    if (contentMode == self.contentMode
        && aspectRatio == self.aspectRatio) {
        return;
    }
    self.contentMode = contentMode;
    self.aspectRatio = aspectRatio;
    
    [self layoutContent:self.content contentMode:contentMode aspectRatio:aspectRatio];
}

- (void)removeContent {
    self.content = nil;
}

- (void)layoutContent:(UIView *)content
          contentMode:(BJLContentMode)contentMode
          aspectRatio:(CGFloat)aspectRatio {
    [content mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (contentMode == BJLContentMode_scaleToFill) {
            make.edges.equalTo(self);
        }
        else {
            make.center.equalTo(self);
            make.edges.equalTo(self).priorityHigh();
            make.width.equalTo(content.mas_height).multipliedBy(aspectRatio);
            if (contentMode == BJLContentMode_scaleAspectFit) {
                make.width.height.lessThanOrEqualTo(self);
            }
            else { // contentMode == BJLContentMode_scaleAspectFill
                make.width.height.greaterThanOrEqualTo(self);
            }
        }
    }];
}

@end

NS_ASSUME_NONNULL_END
