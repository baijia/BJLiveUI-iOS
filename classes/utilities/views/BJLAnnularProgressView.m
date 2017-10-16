//
//  BJLAnnularProgressView.m
//  ICLProgressView
//
//  Created by MingLQ on 2017-01-14.
//  Copyright © 2017 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "BJLAnnularProgressView.h"

NS_ASSUME_NONNULL_BEGIN

const CGFloat BJLProgressSizeS = 14.0, BJLProgressSizeM = 38.0;

@implementation BJLAnnularProgressView

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, BJLProgressSizeM, BJLProgressSizeM)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.size = BJLProgressSizeM;
        self.color = nil;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

- (void)setProgress:(double)progress {
    self->_progress = progress;
    [self setNeedsDisplay];
}

- (void)setSize:(CGFloat)size {
    self->_size = MAX(10.0, size);
    [self setNeedsDisplay];
}

- (void)setAnnularWidth:(CGFloat)annularWidth {
    self->_annularWidth = MAX(0.0, annularWidth);
    [self setNeedsDisplay];
}

- (void)setColor:(nullable UIColor *)color {
    self->_color = color ?: ({
        CGFloat hex7B = 123.0 / 255;
        [UIColor colorWithRed:hex7B
                        green:hex7B
                         blue:hex7B
                        alpha:1.0];
    });
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextClearRect(context, rect);
    
    if (self.progress > 0.0) {
        UIColor *fillColor = self.color;
        
        CGFloat radius = self.size / 2;
        CGFloat borderWidth = (self.annularWidth >= (1.0 / [UIScreen mainScreen].scale)
                               ? self.annularWidth
                               : ceil(radius / 5));
        
        CGFloat circleRadius = radius - (borderWidth / 2);
        CGPoint circleCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        
        CGFloat startAngle = - M_PI_2;
        CGFloat progress = MIN(MAX(0.0, self.progress), 1.0);
        CGFloat endAngle = startAngle + (progress * 2 * M_PI);
        
        // Draw stroked annular (clockwise from 12 o'clock) to indicate progress
        
        CGContextSetStrokeColorWithColor(context, fillColor.CGColor);
        CGContextSetLineWidth(context, borderWidth);
        CGContextAddArc(context,
                        circleCenter.x,
                        circleCenter.y,
                        circleRadius,
                        startAngle,
                        endAngle,
                        NO);
        CGContextStrokePath(context);
    }
    
    CGContextRestoreGState(context);
}

@end

NS_ASSUME_NONNULL_END
