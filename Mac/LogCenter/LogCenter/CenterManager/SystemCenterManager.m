//
//  SystemCenterManager.m
//  LogCenter
//
//  Created by Assassin on 2018/5/15.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "SystemCenterManager.h"
#import <AppKit/AppKit.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <sys/sysctl.h>

#import <stdio.h>
#import <string.h>
#import <sys/socket.h>
#import <netdb.h>
#import <sys/ioctl.h>

#import "SysyemInfoHandleManager.h"

#define TSY_SOCKET_TAG  19999

@interface SystemCenterManager()

// 客户端socket
@property (strong, nonatomic) GCDAsyncSocket *serverSocket;

@property (nonatomic, copy) NSMutableArray *clientSockets; // 保存客户端socket

@property (nonatomic, strong) NSTimer *connectTimer; // 计时器

@end

@implementation SystemCenterManager

+(SystemCenterManager *)intanceSystem {
    static  SystemCenterManager   *manager    = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SystemCenterManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self beginLog];
    }
    return self;
}

- (void)beginLog {
    self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    // 开始连接服务器
    NSError *error = nil;
    NSString* myhost = [self deviceIPAdress];
    NSLog(@"本机的ip地址为:%@",myhost);
    NSLog(@"准备创建服务器:%@",[self getCurrentDate]);
    BOOL connected = [self.serverSocket acceptOnPort:8080 error:&error];
    if(connected && error == nil)
    {
        NSString *time4 = [self getCurrentDate];
        NSLog(@"已经开启端口:%@",time4);
        // 已经开启端口
        NSLog(@"开启端口成功");
        [self showMessageWithStr:@"开启成功"];
    }
    else
    {
        [self showMessageWithStr:@"已经开启"];
    }
}

// 信息展示
- (void)showMessageWithStr:(NSString *)str
{
    
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

// 处理前缀为Link的字符串
- (void)dealMessageArr:(NSString *)getMessage
{
    //对信息进行转发
    [[SysyemInfoHandleManager intanceManager] handleInfoToController:[self jsonStrTodic:getMessage]];
}

- (NSDictionary *)jsonStrTodic:(NSString*)json {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (json.length <=0 ) {
        return dic;
    }
    @try {
        NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        id info = [NSJSONSerialization JSONObjectWithData:jsonData
                                                  options:NSJSONReadingMutableContainers
                                                    error:nil];
        if ([info isKindOfClass:[NSDictionary class]]) {
            dic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)info];
        }
    }@catch(NSException *exception) {
        
    }@finally {
        
    }
    
    return dic;
}

#pragma mark ####### delegate

//开启服务端口

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(nonnull GCDAsyncSocket *)newSocket
{
    //    NSLog(@"连接上新的客户端的时间:%@",[self getCurrentSecond]);
    // 保存客户端的socket
    [self.clientSockets addObject: newSocket];
    
    //    [self addTimer];
    
    [self showMessageWithStr:@"连接成功"];
    //    [self showMessageWithStr:[NSString stringWithFormat:@"客户端的地址: %@ -------端口: %d", newSocket.connectedHost, newSocket.connectedPort]];
    
    //为了再一次的接收
    [newSocket readDataWithTimeout:- 1 tag:TSY_SOCKET_TAG];
    
}

// 收到消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //    NSString *time7 = [self getCurrentSecond];
    //    NSLog(@"服务器收到数据:%@",time7);
    NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    // 处理前缀为ab的字符串
    NSArray *messageArr = [text componentsSeparatedByString:@"ab"];
    for (int i = 1; i < messageArr.count; i++)
    {
        //        NSLog(@"处理的数据%@",messageArr[i]);
        [self dealMessageArr:messageArr[i]];
        [self showMessageWithStr:messageArr[i]];
    }
    
    [sock readDataWithTimeout:- 1 tag:TSY_SOCKET_TAG];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"write");
}


// 客户端socket
//- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
//{
//    NSLog(@"客户端断开的时间%@",[self getCurrentDate]);
//    [self showMessageWithStr:@"断开连接"];
//    if (err) {
//        NSLog(@"错误信息:%@", err.userInfo);
//    }
//    self.serverSocket.delegate = nil;
//    //    [self.clientSocket disconnect];
//    self.serverSocket = nil;
//    [self.connectTimer invalidate];
//}


#pragma mark ###### category
- (void)addTimer
{
    //    NSLog(@"定时器开启时间%@",[self getCurrentSecond]);
    // 长连接定时器
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
    // 把定时器添加到当前运行循环,并且调为通用模式
    [[NSRunLoop currentRunLoop] addTimer:self.connectTimer forMode:NSRunLoopCommonModes];
}

// 心跳连接
- (void)longConnectToSocket
{
    NSLog(@"心跳发送%s",__func__);
    NSString *strName = NSDeviceColorSpaceName;
    NSString *longConnect = [NSString stringWithFormat:@"ab%@",strName];
    
    NSData  *data = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.serverSocket writeData:data withTimeout:- 1 tag:0];
}

- (NSString *)deviceIPAdress {
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return [outstring uppercaseString];
}


#pragma mark ###### lazy
- (NSMutableArray *)clientSockets
{
    if (_clientSockets == nil) {
        _clientSockets = [NSMutableArray array];
    }
    return _clientSockets;
}


@end
