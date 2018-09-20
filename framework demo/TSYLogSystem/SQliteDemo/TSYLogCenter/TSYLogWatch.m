//
//  TSYLogWatch.m
//  SQliteDemo
//
//  Created by Assassin on 2018/5/11.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "TSYLogWatch.h"
#import "TSYSocketMsgDefine.h"
#import <asl.h>
#import <os/log.h>

@interface TSYLogWatch()

@property(nonatomic,assign)UInt32 msgID;

@property(nonatomic,strong)NSTimer *timer;

@property (nonatomic,strong)dispatch_queue_t log_queue;

@end

@implementation TSYLogWatch

+ (TSYLogWatch *)InstanceLog {
    static  TSYLogWatch   *manager    = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager     = [[TSYLogWatch alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _log_queue = dispatch_queue_create("log_queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)startLog {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getLog) userInfo:nil repeats:YES];
}

- (void)stopLog {
    [self.timer invalidate];
    self.timer = nil;
}

//获取日志
- (void)getLog {
    NSArray *array = [self allLogAfterTime:0];
    NSMutableArray *infoArray = [NSMutableArray array];
    for (TSYLogModel *model in array) {
        [infoArray addObject:[model getStringLog]];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(watchSendInfo:withType:)]) {
        [_delegate watchSendInfo:[infoArray componentsJoinedByString:@"\n"] withType:TSY_Msg_Type_Log];
    }
}

- (NSMutableArray<TSYLogModel *> *)allLogMessagesForCurrentProcess
{
    asl_object_t query = asl_new(ASL_TYPE_QUERY);
    
    NSString *pidString = [NSString stringWithFormat:@"%d", (UInt32)[NSBundle mainBundle].bundleIdentifier];
    asl_set_query(query, ASL_KEY_FACILITY, [pidString UTF8String], ASL_QUERY_OP_EQUAL);
    asl_set_query(query, ASL_KEY_PID, [[NSString stringWithFormat:@"%d",getpid()] UTF8String], ASL_QUERY_OP_NUMERIC);
    if(self.msgID != 0){
        NSString *m = [NSString stringWithFormat:@"%d",self.msgID];
        asl_set_query(query, ASL_KEY_MSG_ID, [m UTF8String], ASL_QUERY_OP_GREATER | ASL_QUERY_OP_NUMERIC);
    }
    
    //开始查询获取日志
    aslresponse response = asl_search(NULL, query);
    aslmsg aslMessage = NULL;
    
    NSMutableArray *logMessages = [NSMutableArray array];
    while ((aslMessage = asl_next(response))) {
        //信息to信息对象
        TSYLogModel *model = [TSYLogModel logMessageFromASLMessage:aslMessage];
        if (model.messageID != 0) {
            self.msgID = model.messageID;
        }
        [logMessages addObject:model];
    }
    asl_release(response);
    asl_free(query);
    
    return logMessages;
}

- (NSArray<TSYLogModel *> *)allLogAfterTime:(double) time {
    NSMutableArray<TSYLogModel *>  *allMsg = [self allLogMessagesForCurrentProcess];
//    NSArray *filteredLogMessages = [allMsg filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TSYLogModel *logMessage, NSDictionary *bindings) {
//        if (logMessage.timeInterval > time) {
//            return  YES;
//        }
//        return NO;
//    }]];
    
    return allMsg;
}

@end
