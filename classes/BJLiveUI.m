//
//  BJLiveUI.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-01-19.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLiveUI.h"

NSString * BJLiveUIName(void) {
    return bjl_NSStringFromPreprocessor(PODSPEC_NAME, @"BJLiveUI");
}

NSString * BJLiveUIVersion(void) {
    return bjl_NSStringFromPreprocessor(PODSPEC_VERSION, @"-");
}
