//
//  TSYSocketServer.m
//  SQliteDemo
//
//  Created by Assassin on 2018/5/15.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "TSYSocketServer.h"
#import "GCDAsyncSocket.h"
#import "SimpleToast.h"
#import "TSYWatchDefine.h"

#define TSY_SOCKET_TAG  19999

@interface TSYSocketServer()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *clientSocket; // 服务器socket(开放端口,监听客户端socket的链接)

@property (nonatomic,strong) dispatch_queue_t socket_send_queue;

@property (nonatomic,strong) dispatch_semaphore_t jobSemaphore;

@property (nonatomic, assign) BOOL connected;

@property (nonatomic, strong) NSTimer *connectTimer; // 计时器

@end

@implementation TSYSocketServer

+(TSYSocketServer *)intanceSocket {
    static  TSYSocketServer   *manager    = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TSYSocketServer alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self baseSetting];
        [self beginSocket];
    }
    return self;
}

- (void)baseSetting {
    _socket_send_queue          = dispatch_queue_create("socket_send_queue", DISPATCH_QUEUE_CONCURRENT);
    NSUInteger cpuCount         = [[NSProcessInfo processInfo] processorCount];       //cpu数量
    NSUInteger physicalMemory   = [[NSProcessInfo processInfo] physicalMemory]; //memory数量
    _jobSemaphore               = dispatch_semaphore_create(cpuCount * 2);
    
    [self showMessageWithStr:[NSString stringWithFormat:@"cpu = %lU,memory = %lu",cpuCount,physicalMemory]];
}

- (void)beginSocket {
    // 准备创建服务器socket的时间
    NSString *time1 = [self getCurrentDate];
    NSLog(@"准备创建服务器socket:%@",time1);
    self.clientSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    // 完成创建
    NSString *time2 = [self getCurrentDate];
    NSLog(@"服务器socket创建完成:%@",time2);

    [self startPort];
}

- (void)startPort {
    if (!self.connected) {
        //准备开启端口
        NSString *time3 = [self getCurrentDate];
        NSLog(@"准备链接客户端:%@",time3);
        NSError *error = nil;
        BOOL result = [self.clientSocket connectToHost:@"10.73.30.35" onPort:8080 error:&error];
        if (result)
        {
            [self showMessageWithStr:@"客户端尝试连接"];
            NSLog(@"客户端尝试连接");
        }
        else
        {
            self.connected = NO;
            [self showMessageWithStr:@"客户端未创建连接"];
        }
    }else{
        [self showMessageWithStr:@"与服务器连接已建立"];
    }
}

//向监控端发送需要的信息
- (void)sendMessageToSocketServer:(NSString *)info withType:(TSYMsgType)type{
    dispatch_semaphore_wait(_jobSemaphore, DISPATCH_TIME_FOREVER);
    dispatch_async(_socket_send_queue, ^{
        NSString *dataInfo = [NSString stringWithFormat:@"%@ab%@",[self getCurrentDate],[self socketDataMakeByType:type WithInfo:info]];
        NSData *createData = [dataInfo dataUsingEncoding:NSUTF8StringEncoding];
        //发送消息
        [self.clientSocket writeData:createData withTimeout:- 1 tag:0];
        dispatch_semaphore_signal(_jobSemaphore);
    });
}

- (void)sendMessageToSocketServerByMyself:(NSDictionary *)info {
    dispatch_semaphore_wait(_jobSemaphore, DISPATCH_TIME_FOREVER);
    dispatch_async(_socket_send_queue, ^{
        NSData *data = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSString *dataInfo = [NSString stringWithFormat:@"ab%@",jsonStr];
        NSData *createData = [dataInfo dataUsingEncoding:NSUTF8StringEncoding];
        //发送消息
        [self.clientSocket writeData:createData withTimeout:- 1 tag:0];
        dispatch_semaphore_signal(_jobSemaphore);
    });
}

- (NSString*)socketDataMakeByType:(TSYMsgType)type WithInfo:(NSString *)info {
    switch (type) {
        case TSY_Msg_Type_Crash:
            return [self getJsonFromDic:@"fps" withInfo:info];
        case TSY_Msg_Type_Log:
            return [self getJsonFromDic:@"fps" withInfo:info];
        case TSY_Msg_Type_Net:
            return [self getJsonFromDic:@"fps" withInfo:info];
        case TSY_Msg_Type_FPS:
            return [self getJsonFromDic:@"fps" withInfo:info];
        case TSY_Msg_Type_CPU:
            return [self getJsonFromDic:@"fps" withInfo:info];
        case TSY_Msg_Type_Leaks:
            return [self getJsonFromDic:@"fps" withInfo:info];
        case TSY_Msg_Type_Memory:
            return [self getJsonFromDic:@"fps" withInfo:info];
        case TSY_Msg_Type_System:
            return [self getJsonFromDic:@"fps" withInfo:info];
        default:
            NSLog(@"未知的错误代码");
            return nil;
    }
}

- (NSString *)getJsonFromDic:(NSString*)key withInfo:(NSString*)info {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:info,key,[self getCurrentDate],@"time", nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - ###### socketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"准备连接:%@",[self getCurrentDate]);
    // 连接上服务器
    [self showMessageWithStr:@"连接成功"];
    NSLog(@"连接成功");
    // 发送给服务器 time1
    NSString *createStr = [NSString stringWithFormat:@"mac客户端:%@-链接",[self getCurrentDate]];
    NSData *createData = [createStr dataUsingEncoding:NSUTF8StringEncoding];
    [self.clientSocket writeData:createData withTimeout:- 1 tag:0];
    
    [self addTimer];
    [self.clientSocket readDataWithTimeout:- 1 tag:0];
}

// 收到消息(sock指客户端的Socket)
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"客户端接收到数据的时间%@",[self getCurrentDate]);
    
    NSString *getMessage = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSArray *messageArr = [getMessage componentsSeparatedByString:@"ab"];
    
    for (int i = 1; i < messageArr.count; i++)
    {
        //测试
        NSString *allMes = [NSString stringWithFormat:@"abtime-设备:%@-客户端收到数据:",[self getCurrentDate]];
        NSData *dataTime = [allMes dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"打印内容");
        [self.clientSocket writeData:dataTime withTimeout:- 1 tag:0];
    }
    // 读取到服务器数据值后也能再读取
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}

// 客户端socket
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"客户端断开的时间%@",[self getCurrentDate]);
    [self showMessageWithStr:@"断开连接"];
    if (err) {
        NSLog(@"错误信息:%@", err.userInfo);
    }
    self.clientSocket.delegate = nil;
    //    [self.clientSocket disconnect];
    self.clientSocket = nil;
    [self.connectTimer invalidate];
}


#pragma mark ###### category

- (void)addTimer
{
    NSLog(@"定时器开启时间%@",[self getCurrentDate]);
    // 长连接定时器
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
    // 把定时器添加到当前运行循环,并且调为通用模式
    [[NSRunLoop currentRunLoop] addTimer:self.connectTimer forMode:NSRunLoopCommonModes];
}

// 心跳连接
- (void)longConnectToSocket
{
//    NSLog(@"心跳发送%s",__func__);
    NSString *strName = @"哈哈哈哈";
    NSString *longConnect = [NSString stringWithFormat:@"ab%@",strName];
    
    NSData  *data = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.clientSocket writeData:data withTimeout:- 1 tag:0];
}

- (NSString *)getCurrentDate
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        //    df.dateFormat = @"yyyy/MM/dd HH:mm:ss.SSS";
        df.dateFormat = @"yyyy/MM/dd HH:mm:ss";
        dateFormatter = df;
    });
    NSString *str = [dateFormatter stringFromDate:[NSDate date]];
    return str;
}

// 信息展示
- (void)showMessageWithStr:(NSString *)str
{
    if (isAlertShowMessage) {
        [SimpleToast showToastString:str showTime:3];
    }
}

@end
