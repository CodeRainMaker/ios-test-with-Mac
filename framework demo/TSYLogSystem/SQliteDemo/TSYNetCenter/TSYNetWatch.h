//
//  TSYNetWatch.h
//  SQliteDemo
//
//  Created by Assassin on 2018/5/11.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSYSocketMsgDefine.h"

@protocol TSYNetWatchDelegate <NSObject>

- (void)watchSendInfo:(NSString *)info withType:(TSYMsgType)type;

@end

//#网络监听类
@interface TSYNetWatch : NSURLProtocol<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property(nonatomic,weak)id<TSYNetWatchDelegate>delegate;

+(TSYNetWatch *)intanceStart;

/**
 *@开始监听
 **/
- (void)start;

/**
 *@结束监听
 **/
- (void)stop;

@end
