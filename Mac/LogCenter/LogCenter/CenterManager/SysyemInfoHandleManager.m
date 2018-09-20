//
//  SysyemInfoHandleManager.m
//  LogCenter
//
//  Created by Assassin on 2018/9/19.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "SysyemInfoHandleManager.h"
#import "SystemNotification.h"

@implementation SysyemInfoHandleManager

+(SysyemInfoHandleManager *)intanceManager {
    static  SysyemInfoHandleManager   *manager    = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SysyemInfoHandleManager alloc] init];
    });
    return manager;
}

//处理socker传递过来的信息

- (void)handleInfoToController:(NSDictionary*)infoDic {
    if (infoDic.allValues.count < 1) {
        return;
    }
    //这里可以处理字符串
    [self postNotificationWithDic:infoDic];
    NSLog(@"收到的内容为:%@",infoDic);
}

- (void)postNotificationWithDic:(NSDictionary *)dic {
    [[NSNotificationCenter defaultCenter] postNotificationName:KSystemNotification object:nil userInfo:dic];
}


@end
