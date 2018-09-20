//
//  TSYLogWatch.h
//  SQliteDemo
//
//  Created by Assassin on 2018/5/11.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSYSocketMsgDefine.h"
#import "TSYLogModel.h"

@protocol TSYLogWatchDelegate <NSObject>

- (void)watchSendInfo:(NSString *)info withType:(TSYMsgType)type;

@end

@interface TSYLogWatch : NSObject

@property(nonatomic,weak)id<TSYLogWatchDelegate>delegate;

+ (TSYLogWatch *)InstanceLog;

/*
 *@手动开启log观察
 */
- (void)startLog;
/*
 *@手动关闭log观察
 */
- (void)stopLog;

/*
 *@直接获取日志
 */
- (void)getLog;

@end
