//
//  TSYSocketServer.h
//  SQliteDemo
//
//  Created by Assassin on 2018/5/15.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSYSocketMsgDefine.h"

@interface TSYSocketServer : NSObject

@property(nonatomic,assign)SocketConnectStatus status; //链接状态

+(TSYSocketServer *)intanceSocket;

/*
**@向监控端发送需要的信息
*/
- (void)sendMessageToSocketServer:(NSString *)info withType:(TSYMsgType)type;

- (void)sendMessageToSocketServerByMyself:(NSDictionary *)info;

@end
