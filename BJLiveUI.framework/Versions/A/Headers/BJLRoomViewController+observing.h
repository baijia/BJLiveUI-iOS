//
//  BJLRoomViewController+observing.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-01-19.
//  Copyright © 2017 Baijia Cloud. All rights reserved.
//

#import "BJLRoomViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJLRoomViewController (observing)

- (void)makeObservingWhenEnteredInRoom;
- (void)zoomInPreview:(UIView *)preview;

@end

NS_ASSUME_NONNULL_END
