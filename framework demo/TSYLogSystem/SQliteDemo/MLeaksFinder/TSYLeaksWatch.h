//
//  TSYLeaksWatch.h
//  SQliteDemo
//
//  Created by Assassin on 2018/5/17.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSYSocketMsgDefine.h"

@protocol TSYLeaksWatchDelegate <NSObject>

/*
 *@通过delegatge,利用socket把leaks信息发送出去
 */
- (void)watchSendInfo:(NSString *)info withType:(TSYMsgType)type;

@end

@interface TSYLeaksWatch : NSObject

@property(nonatomic,weak)id<TSYLeaksWatchDelegate>delegate;

+(TSYLeaksWatch *)intanceLeak;

/*
 *@利用socket把leaks信息发送出去
 */
- (void)watchSendLeaksInfo:(NSString *)info;

@end
