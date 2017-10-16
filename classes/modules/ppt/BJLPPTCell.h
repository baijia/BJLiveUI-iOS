//
//  BJLPPTCell.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-18.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BJLPPTUploadingTask.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const BJLPPTCellIdentifier_uploading, * const BJLPPTCellIdentifier_document;

@interface BJLPPTCell : UITableViewCell

- (void)updateWithUploadingTask:(BJLPPTUploadingTask *)uploadingTask;
- (void)updateWithDocument:(BJLDocument *)document;

@end

NS_ASSUME_NONNULL_END
