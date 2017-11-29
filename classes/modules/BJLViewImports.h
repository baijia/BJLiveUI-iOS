//
//  BJLViewImports.h
//  BJLiveUI
//
//  Created by MingLQ on 2017-02-15.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sys/utsname.h>

#import <Masonry/Masonry.h>

// fix error: definition of * must be imported from module BJLiveCore.BJLiveCore before it is required
#import <BJLiveCore/BJLiveCore.h>

#import <BJLiveBase/BJL_EXTScope.h>
#import <BJLiveBase/BJLHitTestView.h>
#import <BJLiveBase/BJLWebImage.h>
#import <BJLiveBase/Masonry+BJLAdditions.h>
#import <BJLiveBase/NSObject+BJL_M9Dev.h>
#import <BJLiveBase/NSObject+BJLObserving.h>
#import <BJLiveBase/UIControl+BJLManagedState.h>
#import <BJLiveBase/UIKit+BJL_M9Dev.h>
#import <BJLiveBase/UIKit+BJLHandler.h>

#import "BJLAppearance.h"
#import "BJLButton.h"
#import "BJLTextField.h"

NS_ASSUME_NONNULL_BEGIN

static inline BOOL bjl_iPhoneX() {
    static BOOL iPhoneX = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if TARGET_OS_EMBEDDED
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *machine = @(systemInfo.machine);
        iPhoneX = ([machine isEqualToString:@"iPhone10,3"]
                   || [machine isEqualToString:@"iPhone10,6"]);
#else // TARGET_OS_SIMULATOR
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        iPhoneX = ABS(MAX(screenSize.width, screenSize.height) - 812.0) <= CGFLOAT_MIN;
#endif
    });
    return iPhoneX;
}

NS_ASSUME_NONNULL_END
