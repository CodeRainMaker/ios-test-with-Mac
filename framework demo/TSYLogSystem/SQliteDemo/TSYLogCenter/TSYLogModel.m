//
//  TSYLogModel.m
//  SQliteDemo
//
//  Created by Assassin on 2018/5/11.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "TSYLogModel.h"

@implementation TSYLogModel

+(instancetype)logMessageFromASLMessage:(aslmsg)aslMessage
{
    TSYLogModel *logMessage = [[TSYLogModel alloc] init];
    
    const char *timestamp = asl_get(aslMessage, ASL_KEY_TIME);
    if (timestamp) {
        NSTimeInterval timeInterval = [@(timestamp) integerValue];
        const char *nanoseconds = asl_get(aslMessage, ASL_KEY_TIME_NSEC);
        if (nanoseconds) {
            timeInterval += [@(nanoseconds) doubleValue] / NSEC_PER_SEC;
        }
        logMessage.timeInterval = timeInterval;
        logMessage.date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        
        logMessage.time = [TSYLogModel logTimeStringFromDate:logMessage.date];
    }
    
    const char *sender = asl_get(aslMessage, ASL_KEY_SENDER);
    if (sender) {
        logMessage.sender = @(sender);
    }
    
    const char *messageText = asl_get(aslMessage, ASL_KEY_MSG);
    if (messageText) {
        logMessage.messageText = @(messageText);
    }
    
    const char *messageID = asl_get(aslMessage, ASL_KEY_MSG_ID);
    if (messageID) {
        logMessage.messageID = [@(messageID) longLongValue];
    }
    
    return logMessage;
}

+ (NSString *)logTimeStringFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    });
    
    return [formatter stringFromDate:date];
}

- (NSString *)getStringLog {
    return [NSString stringWithFormat:@"LOG(%lli):[%@] <%@> {%@}",self.messageID,self.time,self.sender,self.messageText];
}


@end
