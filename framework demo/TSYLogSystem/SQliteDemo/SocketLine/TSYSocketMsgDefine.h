//
//  TSYSocketMsgDefine.h
//  SQliteDemo
//
//  Created by Assassin on 2018/5/16.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#ifndef TSYSocketMsgDefine_h
#define TSYSocketMsgDefine_h

//TCP连接状态
typedef NS_ENUM(NSInteger) {
    SocketConnectStatus_UnConnected       = 0<<0,//未连接状态
    SocketConnectStatus_Connected         = 1<<0,//连接状态
    SocketConnectStatus_DisconnectByUser  = 2<<0,//主动断开连接
    SocketConnectStatus_Unknow            = 3<<0 //未知
}SocketConnectStatus;

//消息类型
typedef NS_ENUM(NSInteger){
    TSY_Msg_Type_CPU            = 0<<0,
    TSY_Msg_Type_Memory         = 1<<0,
    TSY_Msg_Type_FPS            = 2<<0,
    TSY_Msg_Type_Crash          = 3<<0,
    TSY_Msg_Type_Log            = 4<<0,
    TSY_Msg_Type_Net            = 5<<0,
    TSY_Msg_Type_System         = 6<<0,
    TSY_Msg_Type_Leaks          = 7<<0,
}TSYMsgType;


#endif /* TSYSocketMsgDefine_h */
