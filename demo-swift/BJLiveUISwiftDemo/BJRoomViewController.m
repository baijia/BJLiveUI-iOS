//
//  BJRoomViewController.m
//  TestSwiftApp
//
//  Created by MingLQ on 2017-05-25.
//  Copyright © 2017 GSX. All rights reserved.
//

#import "BJRoomViewController.h"

#import <BJLiveCore/BJLiveCore.h>
#import <BJLiveUI/BJLiveUI.h>

@interface BJRoomViewController ()

@end

@implementation BJRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BJLRoom *room = [BJLRoom roomWithSecret:@"" userName:@"" userAvatar:nil];
    [room enter];
    
    BJLRoomViewController *roomVC = [BJLRoomViewController instanceWithSecret:@"" userName:@"" userAvatar:nil];
    [self bjl_addChildViewController:roomVC superview:self.view];
}

@end
