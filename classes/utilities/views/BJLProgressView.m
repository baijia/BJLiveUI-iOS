//
//  BJLProgressView.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-01-19.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "BJLProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLProgressView ()

@property (nonatomic) UIView *completionView;

@end

@implementation BJLProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.completionView = ({
            UIView *view = [UIView new];
            [self addSubview:view];
            view;
        });
        self.color = nil;
        self.progress = 0.0;
    }
    return self;
}

- (void)setProgress:(double)progress {
    _progress = MAX(0.0, MIN(progress, 1.0));
    [self.completionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.width.equalTo(self.mas_width).multipliedBy(self.progress);
    }];
    [self setNeedsLayout];
}

- (void)setColor:(nullable UIColor *)color {
    NSString *key = NSStringFromSelector(@selector(color));
    [self willChangeValueForKey:key];
    self->_color = color ?: ({
        CGFloat _7B = 123.0 / 255;
        [UIColor colorWithRed:_7B
                        green:_7B
                         blue:_7B
                        alpha:1.0];
    });
    self.completionView.backgroundColor = self.color;
    [self didChangeValueForKey:key];
}

@end

NS_ASSUME_NONNULL_END
