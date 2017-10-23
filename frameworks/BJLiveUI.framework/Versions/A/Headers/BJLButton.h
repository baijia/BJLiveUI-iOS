//
//  BJLButton.h
//  BJLiveUI
//
//  Created by MingLQ on 2015-10-21.
//  Copyright © 2016年 iOSNewbies. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** set space between image and title, 0.0 by default */
@interface BJLButton : UIButton {
    CGSize _bjl_intrinsicContentSize;
    UIEdgeInsets _bjl_alignmentRectInsets;
}
@property (nonatomic) CGSize intrinsicContentSize; // set CGSizeZero to reset default
@property (nonatomic) UIEdgeInsets alignmentRectInsets; // set UIEdgeInsetsZero to reset default
@property (nonatomic) CGFloat midSpace;
@end

@interface BJLImageRightButton : BJLButton
@end

/** image on the top, title on the bottom */
@interface BJLVerticalButton : BJLButton
@end

/** title only */
@interface BJLTitleButton : BJLButton
@end

/** image only */
@interface BJLImageButton : BJLButton
@end

NS_ASSUME_NONNULL_END
