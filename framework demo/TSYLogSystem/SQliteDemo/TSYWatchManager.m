//
//  TSYWatchManager.m
//  SQliteDemo
//
//  Created by Assassin on 2018/5/16.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "TSYWatchManager.h"
#import "TSYSocketServer.h"

#import "TSYCrashWatch.h"
#import "TSYLogWatch.h"
#import "TSYNetWatch.h"
#import "TSYSystemManager.h"
#import "TSYLeaksWatch.h"

#define TSY_Duration   2

@interface TSYWatchManager() <TSYCrashWatchDelegate,TSYLogWatchDelegate,TSYNetWatchDelegate,TSYSystemManagerDelegate,TSYLeaksWatchDelegate>

//监察定时器
@property (nonatomic, strong) dispatch_source_t beatTimer;

@end

@implementation TSYWatchManager

+(TSYWatchManager *)intanceWatch {
    static  TSYWatchManager   *manager    = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TSYWatchManager alloc] init];
    });
    return manager;
}

//打开系统的监听和sokcet服务（用来向终端发送信息）
- (void)startSystemWatchAndSocketServer {
    
    [TSYSocketServer intanceSocket];
    //执行监察任务
    dispatch_resume(self.beatTimer);
    
    //开启各项监控
    
    //system
    [[TSYSystemManager intanceSystem] startWatch];
    [TSYSystemManager intanceSystem].delegate = self;
    
    //crash
    [TSYCrashWatch addDelegate:self];
    [[TSYCrashWatch Instance] cw_beginWatch];
    //net
    [[TSYNetWatch intanceStart] start];
    [TSYNetWatch intanceStart].delegate = self;
    //leak
    [TSYLeaksWatch intanceLeak].delegate = self;
    //Log
//    [TSYLogWatch InstanceLog].delegate = self;
    
    [self sendCPuAndDeviceInfo];
}

- (void)stopSystemWatchAndSocketServer {
    //执行监察任务
    dispatch_suspend(self.beatTimer);
    
    //关闭各项监控
    //crash
    [TSYCrashWatch removeDelegate:self];
    //net
    [[TSYNetWatch intanceStart] stop];
    [TSYNetWatch intanceStart].delegate = nil;
    //leak
    [TSYLeaksWatch intanceLeak].delegate = nil;
    //Log
    [TSYLogWatch InstanceLog].delegate = nil;
    [[TSYLogWatch InstanceLog] stopLog];
    
    [TSYSystemManager intanceSystem].delegate = nil;
}

// 开始定时器来
- (dispatch_source_t)beatTimer
{
    if (!_beatTimer) {
        _beatTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(_beatTimer, DISPATCH_TIME_NOW, TSY_Duration * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        __weak TSYWatchManager *mself = self;
        dispatch_source_set_event_handler(_beatTimer, ^{
            [mself watchHandle];
        });
    }
    return _beatTimer;
}

//执行获取检测任务得的信息
- (void)watchHandle {
    //Log
    [[TSYLogWatch InstanceLog] getLog];
    [self sendDic:[[TSYSystemManager intanceSystem] getAllUseInfo]];
}

#pragma mark ###### delegate

- (void)watchSendInfo:(NSString *)info withType:(TSYMsgType)type {
    [[TSYSocketServer intanceSocket] sendMessageToSocketServer:info withType:type];
}

//以下是只发送一次的信息
- (void)sendCPuAndDeviceInfo {
    [self sendDic:[[TSYSystemManager intanceSystem] getAllDeviceInfo]];
}

- (void)sendDic:(NSDictionary*)dic {
    [[TSYSocketServer intanceSocket] sendMessageToSocketServerByMyself:dic];
}

@end
