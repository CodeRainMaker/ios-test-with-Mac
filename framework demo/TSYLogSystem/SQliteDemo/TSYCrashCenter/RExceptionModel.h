//
//  RExceptionModel.h
//  SQliteDemo
//
//  Created by Assassin on 2018/5/10.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RExceptionModel : NSObject

@property(nonatomic,strong)NSString *name;

@property(nonatomic,strong)NSString *reason;

@property(nonatomic,strong)NSString *AppInfo;

@property(nonatomic,strong)NSString *callSymbols;

@property(nonatomic,strong)NSString *crashTime;

@property(nonatomic,strong)NSString *crashDescript; //错误消息

@end
