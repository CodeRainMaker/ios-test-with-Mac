//
//  TSYCrashWatch.m
//  SQliteDemo
//
//  Created by PeachRain on 2018/5/10.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

//有需要的可以自己添加新的监听
//SIGABRT--程序中止命令中止信号
//SIGALRM--程序超时信号
//SIGFPE--程序浮点异常信号
//SIGILL--程序非法指令信号
//SIGHUP--程序终端中止信号
//SIGINT--程序键盘中断信号
//SIGKILL--程序结束接收中止信号
//SIGTERM--程序kill中止信号
//SIGSTOP--程序键盘中止信号
//SIGSEGV--程序无效内存中止信号
//SIGBUS--程序内存字节未对齐中止信号
//SIGPIPE--程序Socket发送失败中止信号

#import "TSYCrashWatch.h"
#include <libkern/OSAtomic.h>
#import <UIKit/UIKit.h>
#import "RExceptionModel.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <stdatomic.h>
#endif

@interface TSYCrashWatch()
{
    NSUncaughtExceptionHandler *_old_exception;//保存之前的Handlers
    NSHashTable *_delegates;
}

@end
@implementation TSYCrashWatch

+ (TSYCrashWatch *)Instance {
    static  TSYCrashWatch   *manager    = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager     = [[TSYCrashWatch alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

#pragma mark 开始监听crash
- (void)cw_beginWatch {
    
    _old_exception = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(HandleException);
    
    [self signal_Setting];
}

- (NSHashTable *)delegates {
    return _delegates;
}

#pragma mark ###### singal信号处理
- (void)signal_Setting {
    //注册程序由于abort()函数调用发生的程序中止信号
    signal(SIGABRT, HandleSingal);
    
    //注册程序由于非法指令产生的程序中止信号
    signal(SIGILL, HandleSingal);
    
    //注册程序由于无效内存的引用导致的程序中止信号
    signal(SIGSEGV, HandleSingal);
    
    //注册程序由于浮点数异常导致的程序中止信号
    signal(SIGFPE, HandleSingal);
    
    //注册程序由于内存地址未对齐导致的程序中止信号
    signal(SIGBUS, HandleSingal);
    
    //程序通过端口发送消息失败导致的程序中止信号
    signal(SIGPIPE, HandleSingal);
    
    //http://stackoverflow.com/questions/36325140/how-to-catch-a-swift-crash-and-do-some-logging
     signal(SIGTRAP, HandleSingal);
}

void HandleSingal(int singal){
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:singal] forKey:@"signal"];
    
    //创建一个OC异常对象
    NSException *ex = [NSException exceptionWithName:@"SignalExceptionName" reason:[NSString stringWithFormat:@"Signal %d was raised.\n",singal] userInfo:userInfo];
    
    //处理异常消息
    NSLog(@"ex = %@",ex.description);
    
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
}



#pragma mark ###### 异常方法
//当前处理的异常个数
volatile int32_t UncaughtExceptionCount = 0;
//最大能够处理的异常个数
volatile int32_t UncaughtExceptionMaximum = 10;

BOOL isDismissed = YES;
void HandleException(NSException *exception)
{
    //保证其他handle可以处理
     [[TSYCrashWatch Instance] performSelectorOnMainThread:@selector(ex_handle:) withObject:exception waitUntilDone:YES];
    
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
     //线程的调用都会有函数的调用函数的调用就会有栈返回地址的记录，在这里返回的是函 数调用返回的虚拟地址，说白了就是在该线程中函数调用的名字的数组
    NSString *callSymbols = [exception.callStackSymbols componentsJoinedByString:@"\r"];
    NSString *reason = exception.reason ? exception.reason : @"";
    NSString *name = exception.name;
    NSString *appInfo = local_App_Info();
    
    RExceptionModel *model = [RExceptionModel new];
    model.name = name;
    model.AppInfo = appInfo;
    model.reason = reason;
    model.callSymbols = callSymbols;
    
    NSString *crashInfo = [NSString stringWithFormat:@"call = %@,reason = %@,name = %@, appinfo = %@",callSymbols,reason,name,appInfo];
    NSLog(@"%@",crashInfo);
    
    if ([TSYCrashWatch Instance].delegates.count > 0) {
        //这里可以把相关内容发给socket
        [[TSYCrashWatch Instance] performSelectorOnMainThread:@selector(handleInfo:) withObject:crashInfo waitUntilDone:YES];
    }
    
//    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
//    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    //弹窗
//    [[TSYCrashWatch Instance] performSelectorOnMainThread:@selector(actionAlert) withObject:nil waitUntilDone:NO];
    
//    //当接收到异常处理消息时，让程序开始runloop，防止程序死亡
//    while (!isDismissed) {
//        for (NSString *mode in (__bridge NSArray *)allModes)
//        {
//            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
//        }
//    }
//    //当点击弹出视图的Cancel按钮哦,isDimissed ＝ YES,上边的循环跳出
//    CFRelease(allModes);
//    NSSetUncaughtExceptionHandler(NULL);
    
}

- (void)ex_handle:(NSException *)exception{
    
    if (_old_exception != nil) {
        _old_exception(exception);
    }
}

- (void)handleInfo:(NSString *)info {
    for (id<TSYCrashWatchDelegate> crashDelegate in _delegates) {
        if ([crashDelegate respondsToSelector:@selector(watchSendInfo:withType:)]) {
            [crashDelegate watchSendInfo:info withType:TSY_Msg_Type_Crash];
        }
        
    }
}

#pragma mark ###### catagory

//获取app相关信息
NSString* local_App_Info(){
    NSString *bundleName = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *shortVersion = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *deviceModel = [UIDevice currentDevice].model;
    NSString *systemName = [UIDevice currentDevice].systemName;
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    return [NSString stringWithFormat:@"App: %@ %@ \n Device:%@ \n OS Version:%@ %@",bundleName,shortVersion,deviceModel,systemVersion,systemName];
}

#pragma mark delegate

+ (void)addDelegate:(id<TSYCrashWatchDelegate>)delegate {
    if (!delegate) {
        return;
    }
    TSYCrashWatch *watch = [TSYCrashWatch Instance];
    [watch.delegates addObject:delegate];
}

+ (void)removeDelegate:(id<TSYCrashWatchDelegate>)delegate {
    if (!delegate) {
        return;
    }
    TSYCrashWatch *watch = [TSYCrashWatch Instance];
    if ([watch.delegates containsObject:delegate]) {
        [watch.delegates removeObject:delegate];
    }
}

- (void)actionAlert {
    // 初始化 添加 提示内容
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告⚠️" message:@"发生crash" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        isDismissed = YES;
    }];

    [alertController addAction:okAction];
    
    // 出现
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:^{
        NSLog(@"presented");
    }];
    
}

@end
