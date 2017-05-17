BJLiveUI
========

## 功能简介

- 教室：直播间；
- 老师：主讲人，拥有最高权限；
- 助教：管理员，拥有部分老师的权限；
- 学生：听讲人，权限受限，不支持 设置上下课、发公告、处理他人举手、远程开关他人音视频、开关录课、开关聊天禁言；
- 上课、下课：上课中才能举手、发言、录课；
- 举手：学生申请发言，老师和管理员可以允许或拒绝；
- 发言：发布音频、视频，SDK 层面发言不要求举手状态；
- 录课：云端录制课程；
- 聊天/弹幕：目前只支持群发；
- 白板、课件、画笔：课件第一页是白板，后面是老师上传的课件，白板和每一页课件都支持画笔；

## 集成 SDK

BJLiveUI 会依赖一些第三方库，建议使用 CocoaPods 方式集成；
- Podfile 中设置 source
```ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/baijia/specs.git'
```
- Podfile 中引入 BJLiveUI
```ruby
pod 'BJLiveUI'
```

## 工程设置

- 隐私权限：在 `Info.plist` 中添加麦克风、摄像头、相册访问描述；
```
Privacy - Microphone Usage Description       用于语音上课、发言
Privacy - Camera Usage Description           用于视频上课、发言，拍照上传课件、聊天发图
Privacy - Photo Library Usage Description    用于上传课件、聊天发图
```
- 后台任务：在 `Project > Target > Capabilities` 中打开 `Background Modes` 开关、选中 `Audio, AirPlay, and Picture in Picture`；

## Hello World

参考 demo 中的 `BJLoginViewController`；
- 引入头文件
```objc
#import <BJLiveUI/BJLiveUI.h>
```
- 创建、进入教室
```objc
BJLRoomViewController *roomViewController = [BJLRoomViewController
                                             instanceWithSecret:@"xxxx"
                                             userName:@"xxxx"
                                             userAvatar:nil];
roomViewController.delegate = self;
[self presentViewController:roomViewController animated:YES completion:nil];
```
- 监听教室进入、退出
```objc
#pragma mark - <BJLRoomViewControllerDelegate>

/** 进入教室 - 成功 */
- (void)roomViewControllerEnterRoomSuccess:(BJLRoomViewController *)roomViewController {
    NSLog(@"[%@ %@]", NSStringFromSelector(_cmd), roomViewController);
}

/** 进入教室 - 失败 */
- (void)roomViewController:(BJLRoomViewController *)roomViewController
 enterRoomFailureWithError:(BJLError *)error {
    NSLog(@"[%@ %@, %@]", NSStringFromSelector(_cmd), roomViewController, error);
}

/**
 退出教室 - 正常/异常
 正常退出 `error` 为 `nil`，否则为异常退出
 参考 `BJLErrorCode` */
- (void)roomViewController:(BJLRoomViewController *)roomViewController
         willExitWithError:(nullable BJLError *)error {
    NSLog(@"[%@ %@, %@]", NSStringFromSelector(_cmd), roomViewController, error);
}

/**
 退出教室 - 正常/异常
 正常退出 `error` 为 `nil`，否则为异常退出
 参考 `BJLErrorCode` */
- (void)roomViewController:(BJLRoomViewController *)roomViewController
          didExitWithError:(nullable BJLError *)error {
    NSLog(@"[%@ %@, %@]", NSStringFromSelector(_cmd), roomViewController, error);
}
```
