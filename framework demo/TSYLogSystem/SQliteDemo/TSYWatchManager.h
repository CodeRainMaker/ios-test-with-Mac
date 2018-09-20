//
//  TSYWatchManager.h
//  SQliteDemo
//
//  Created by Assassin on 2018/5/16.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSYWatchManager : NSObject


+(TSYWatchManager *)intanceWatch;

/*
 *@打开系统的监听和sokcet服务（用来向终端发送信息）
 */
- (void)startSystemWatchAndSocketServer;

- (void)stopSystemWatchAndSocketServer;

@end
