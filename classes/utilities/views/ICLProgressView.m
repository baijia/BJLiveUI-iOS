//
//  ICLProgressView.m
//  ICLProgressView
//
//  Created by MingLQ on 2017-01-14.
//  Copyright © 2017 MingLQ <minglq.9@gmail.com>. All rights reserved.
//

#import "ICLProgressView.h"

NS_ASSUME_NONNULL_BEGIN

const CGFloat ICLProgressSizeS = 14.0, ICLProgressSizeM = 38.0;

@implementation ICLProgressView

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, ICLProgressSizeM, ICLProgressSizeM)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.size = ICLProgressSizeM;
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
    UIColor *fillColor = self.color;
    
    CGFloat radius = self.size / 2;
    CGFloat borderWidth = ceil(radius / 5);
    
    CGFloat circleRadius = radius - (borderWidth / 2);
    CGPoint circleCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGRect circleRect = CGRectMake(circleCenter.x - circleRadius,
                                   circleCenter.y - circleRadius,
                                   2 * circleRadius,
                                   2 * circleRadius);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextClearRect(context, rect);
    
    // Draw stroked circle to delineate circle shape.
    
    CGContextSetStrokeColorWithColor(context, fillColor.CGColor);
    CGContextSetLineWidth(context, borderWidth);
    CGContextAddEllipseInRect(context, circleRect);
    CGContextStrokePath(context);
    
    // Draw filled wedge (clockwise from 12 o'clock) to indicate progress
    
    CGFloat startAngle = - M_PI_2;
    CGFloat progress = MIN(MAX(0.0, self.progress), 1.0);
    CGFloat endAngle = startAngle + (progress * 2 * M_PI);
    
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextMoveToPoint(context, circleCenter.x, circleCenter.y);
    CGContextAddLineToPoint(context, CGRectGetMidX(circleRect), CGRectGetMinY(circleRect));
    CGContextAddArc(context,
                    circleCenter.x,
                    circleCenter.y,
                    circleRadius,
                    startAngle,
                    endAngle,
                    NO);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
}

@end

NS_ASSUME_NONNULL_END
