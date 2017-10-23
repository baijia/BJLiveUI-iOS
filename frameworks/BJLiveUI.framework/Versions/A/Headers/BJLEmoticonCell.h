//
//  BJLEmoticonCell.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-04-18.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <BJLiveCore/BJLEmoticon.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJLEmoticonCell : UICollectionViewCell

- (void)updateWithEmoticon:(BJLEmoticon *)emoticon;

@end

NS_ASSUME_NONNULL_END
