//
//  BJLTextField.m
//  BJLiveUI
//
//  Created by MingLQ on 2016-08-22.
//  Copyright © 2016年 iOSNewbies. All rights reserved.
//

#import "BJLTextField.h"

NS_ASSUME_NONNULL_BEGIN

@implementation BJLTextField

- (CGRect)borderRectForBounds:(CGRect)bounds {
    CGRect borderRect = [super borderRectForBounds:bounds];
    return UIEdgeInsetsInsetRect(borderRect, self.borderInsets);
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect textRect = [super textRectForBounds:bounds];
    return UIEdgeInsetsInsetRect(textRect, self.textInsets);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect placeholderRect = [super placeholderRectForBounds:bounds];
    return UIEdgeInsetsInsetRect(placeholderRect, self.placeholderInsets);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect editingRect = [super editingRectForBounds:bounds];
    return UIEdgeInsetsInsetRect(editingRect, self.editingInsets);
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect clearButtonRect = [super clearButtonRectForBounds:bounds];
    return UIEdgeInsetsInsetRect(clearButtonRect, self.clearButtonInsets);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect leftViewRect = [super leftViewRectForBounds:bounds];
    return UIEdgeInsetsInsetRect(leftViewRect, self.leftViewInsets);
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect rightViewRect = [super rightViewRectForBounds:bounds];
    return UIEdgeInsetsInsetRect(rightViewRect, self.rightViewInsets);
}

@end

NS_ASSUME_NONNULL_END
