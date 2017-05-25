//
//  BJLEmoticonKeyboardView.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-04-17.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLEmoticon.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLEmoticonKeyboardView : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, copy, nullable) NSArray<BJLEmoticon *> *emoticons;

@property (nonatomic, copy, nullable) void (^selectEmoticonCallback)(BJLEmoticon *emoticon);

- (instancetype)initForIdiomPad:(BOOL)iPad;

- (void)updateLayoutForTraitCollection:(UITraitCollection *)newCollection animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
