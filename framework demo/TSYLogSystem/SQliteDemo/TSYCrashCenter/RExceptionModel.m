//
//  RExceptionModel.m
//  SQliteDemo
//
//  Created by Assassin on 2018/5/10.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "RExceptionModel.h"

@implementation RExceptionModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self crashTimeInit];
    }
    return self;
}

- (void)crashTimeInit{
    static dispatch_once_t onceToken;
    static NSDateFormatter *timeFormatter = nil;
    dispatch_once(&onceToken, ^{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        timeFormatter = formatter;
    });
    if (timeFormatter) {
        self.crashTime = [timeFormatter stringFromDate:[NSDate date]];
    }
}

- (NSString*)crashDescript {
    NSString *info = @"没有信息";
    
    return info;
}

@end
