//
//  TSYLogModel.h
//  SQliteDemo
//
//  Created by Assassin on 2018/5/11.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <asl.h>

@interface TSYLogModel : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, copy) NSString *sender;
@property (nonatomic, copy) NSString *messageText;
@property (nonatomic, assign) long long messageID;

+ (instancetype)logMessageFromASLMessage:(aslmsg)aslMessage;

+ (NSString *)logTimeStringFromDate:(NSDate *)date;

- (NSString *)getStringLog;

@end
