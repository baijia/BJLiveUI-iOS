//
//  BJLPreviewCell.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-06-05.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString
* const BJLPreviewCellID_view, // PPT, recording
* const BJLPreviewCellID_view_label, // video teacher, students
* const BJLPreviewCellID_avatar_label, // audio teacher, students - hasVideo?
* const BJLPreviewCellID_avatar_label_buttons; // request students

@interface BJLPreviewCell : UICollectionViewCell

@property (nonatomic, copy) void (^doubleTapsCallback)(BJLPreviewCell *cell);
@property (nonatomic, copy) void (^actionCallback)(BJLPreviewCell *cell, BOOL allowed);

- (void)updateWithView:(UIView *)view;
- (void)updateWithView:(UIView *)view title:(NSString *)title;
- (void)updateWithImageURLString:(NSString *)imageURLString title:(NSString *)title hasVideo:(BOOL)hasVideo;

+ (CGSize)cellSize;
+ (NSArray<NSString *> *)allCellIdentifiers;

@end

NS_ASSUME_NONNULL_END
