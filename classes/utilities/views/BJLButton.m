//
//  BJLButton.m
//  BJLiveUI
//
//  Created by MingLQ on 2015-10-21.
//  Copyright © 2016年 iOSNewbies. All rights reserved.
//

#import "BJLButton.h"

NS_ASSUME_NONNULL_BEGIN

@implementation BJLButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect imageRect = [super imageRectForContentRect:contentRect];
    if (self.currentTitle.length && self.currentImage) {
        imageRect.origin.x -= self.midSpace / 2;
    }
    return imageRect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect titleRect = [super titleRectForContentRect:contentRect];
    if (self.currentTitle.length && self.currentImage) {
        titleRect.origin.x += self.midSpace / 2;
    }
    return titleRect;
}

@synthesize intrinsicContentSize = _bjl_intrinsicContentSize;

- (CGSize)superIntrinsicContentSize {
    return [super intrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
    if (!CGSizeEqualToSize(self->_bjl_intrinsicContentSize, CGSizeZero)) {
        return self->_bjl_intrinsicContentSize;
    }
    CGSize contentSize = [self superIntrinsicContentSize];
    contentSize.width += self.midSpace;
    return contentSize;
}

- (void)setIntrinsicContentSize:(CGSize)intrinsicContentSize {
    if (!CGSizeEqualToSize(intrinsicContentSize, self->_bjl_intrinsicContentSize)) {
        self->_bjl_intrinsicContentSize = intrinsicContentSize;
        [self invalidateIntrinsicContentSize];
    }
}

@synthesize alignmentRectInsets = _bjl_alignmentRectInsets;

- (UIEdgeInsets)alignmentRectInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(self->_bjl_alignmentRectInsets, UIEdgeInsetsZero)) {
        return self->_bjl_alignmentRectInsets;
    }
    return [super alignmentRectInsets];
}

- (void)setMidSpace:(CGFloat)midSpace {
    self->_midSpace = midSpace;
    [self invalidateIntrinsicContentSize];
}

@end

#pragma mark -

@implementation BJLImageRightButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect imageRect = [super imageRectForContentRect:contentRect];
    if (self.currentTitle.length) {
        CGRect titleRect = [super titleRectForContentRect:contentRect];
        imageRect.origin.x = CGRectGetMaxX(titleRect) - CGRectGetWidth(imageRect);
    }
    return imageRect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect titleRect = [super titleRectForContentRect:contentRect];
    if (self.currentImage) {
        CGRect imageRect = [super imageRectForContentRect:contentRect];
        titleRect.origin.x = CGRectGetMinX(imageRect);
    }
    return titleRect;
}

@end

#pragma mark -

@implementation BJLVerticalButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect imageRect = [super imageRectForContentRect:contentRect];
    if (self.currentTitle.length) {
        CGRect titleRect = [super titleRectForContentRect:contentRect];
        imageRect.origin.x = (CGRectGetWidth(contentRect) - CGRectGetWidth(imageRect)) / 2;
        imageRect.origin.y = (CGRectGetHeight(contentRect)
                              - CGRectGetHeight(imageRect)
                              - self.midSpace
                              - CGRectGetHeight(titleRect)) / 2;
    }
    return imageRect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect titleRect = [super titleRectForContentRect:contentRect];
    if (self.currentImage) {
        CGRect imageRect = [self imageRectForContentRect:contentRect];
        /* titleRect.size.width = MIN([self.currentTitle sizeWithFont:self.titleLabel.font
                                                 constrainedToSize:CGSizeMake(CGRectGetHeight(titleRect), CGFLOAT_MAX)
                                                     lineBreakMode:NSLineBreakByCharWrapping].width,
                                   CGRectGetWidth(contentRect));
        titleRect.origin.x = (CGRectGetWidth(contentRect) - CGRectGetWidth(titleRect)) / 2; */
        titleRect.size.width = CGRectGetWidth(contentRect);
        titleRect.origin.x = 0.0;
        titleRect.origin.y = CGRectGetMaxY(imageRect) + self.midSpace;
    }
    return titleRect;
}

- (CGSize)intrinsicContentSize {
    if (!CGSizeEqualToSize(self->_bjl_intrinsicContentSize, CGSizeZero)) {
        return self->_bjl_intrinsicContentSize;
    }
    CGSize contentSize = [self superIntrinsicContentSize]; // ???: super in superIntrinsicContentSize
    contentSize.width += self.midSpace;
    return contentSize;
}

@end

#pragma mark -

@implementation BJLTitleButton

- (CGSize)sizeThatFits:(CGSize)size {
    size = [self.titleLabel sizeThatFits:size];
    size.width += (self.titleEdgeInsets.left + self.titleEdgeInsets.right
                   + self.contentEdgeInsets.left + self.contentEdgeInsets.right);
    size.height += (self.titleEdgeInsets.top + self.titleEdgeInsets.bottom
                    + self.contentEdgeInsets.top + self.contentEdgeInsets.bottom);
    return size;
}

- (CGRect)contentRectForBounds:(CGRect)bounds {
    return UIEdgeInsetsInsetRect(bounds, self.contentEdgeInsets);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return UIEdgeInsetsInsetRect(contentRect, self.titleEdgeInsets);
}

@end

#pragma mark -

@implementation BJLImageButton

- (CGSize)sizeThatFits:(CGSize)size {
    size = [self.imageView sizeThatFits:size];
    size.width += (self.imageEdgeInsets.left + self.imageEdgeInsets.right
                   + self.contentEdgeInsets.left + self.contentEdgeInsets.right);
    size.height += (self.imageEdgeInsets.top + self.imageEdgeInsets.bottom
                    + self.contentEdgeInsets.top + self.contentEdgeInsets.bottom);
    return size;
}

- (CGRect)contentRectForBounds:(CGRect)bounds {
    return UIEdgeInsetsInsetRect(bounds, self.contentEdgeInsets);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return UIEdgeInsetsInsetRect(contentRect, self.imageEdgeInsets);
}

@end

NS_ASSUME_NONNULL_END
