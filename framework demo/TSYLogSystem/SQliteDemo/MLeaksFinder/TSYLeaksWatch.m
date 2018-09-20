//
//  TSYLeaksWatch.m
//  SQliteDemo
//
//  Created by Assassin on 2018/5/17.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "TSYLeaksWatch.h"

@implementation TSYLeaksWatch

+(TSYLeaksWatch *)intanceLeak {
    static  TSYLeaksWatch   *manager    = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TSYLeaksWatch alloc] init];
    });
    return manager;
}

//向客户端发送socket信息
- (void)watchSendLeaksInfo:(NSString *)info {
    if (_delegate && [_delegate respondsToSelector:@selector(watchSendInfo:withType:)]) {
        [_delegate watchSendInfo:info withType:TSY_Msg_Type_Leaks];
    }
}

@end
