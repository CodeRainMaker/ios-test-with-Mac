//
//  TSYCrashWatch.h
//  SQliteDemo
//
//  Created by Assassin on 2018/5/10.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSYSocketMsgDefine.h"

@protocol TSYCrashWatchDelegate <NSObject>

- (void)watchSendInfo:(NSString *)info withType:(TSYMsgType)type;

@end

@interface TSYCrashWatch : NSObject

+ (TSYCrashWatch *)Instance;
- (void)cw_beginWatch;
- (NSHashTable *)delegates;

+ (void)addDelegate:(id<TSYCrashWatchDelegate>)delegate;
+ (void)removeDelegate:(id<TSYCrashWatchDelegate>)delegate;

@end
