//
//  ViewController.m
//  SQliteDemo
//
//  Created by Assassin on 2018/4/2.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
#include <mutex>
#include <__config>
#include <__mutex_base>
#include <chrono>
#include <ratio>

#include <cstdint>
#include <list>

#include <atomic>

#include <system_error>
#include <__threading_support>

#include <cstdint>
#include <type_traits>
#include <string>

#import <asl.h>      //获取错误日志

#import <SpriteKit/SpriteKit.h>

#include <functional>

#import <sys/signal.h>

#import "TSYCrashWatch.h"
#import <os/log.h>

#import "TSYDefine.h"

#import <objc/runtime.h>
#import "TSYSocketServer.h"
#import "TSYSystemManager.h"
#import "TSYWatchManager.h"
#import <fcntl.h>


@interface ViewController ()

@property(nonatomic,assign)NSInteger count;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _count = 0;
    
    [[TSYWatchManager intanceWatch] startSystemWatchAndSocketServer];

    [self socket];
    
    NSLog(@"花哈哈");
    
    
//    UIButton *btn = [[UIButton alloc]init];
//    btn.frame = CGRectMake(0, 0, 100, 100);
//    btn.backgroundColor = [UIColor redColor];
//    btn.center = self.view.center;
//    [self.view addSubview:btn];
//    [btn addTarget:self action:@selector(loglog) forControlEvents:UIControlEventTouchUpInside];
    
//    dispatch_queue_t queue = dispatch_queue_create("===", DISPATCH_QUEUE_CONCURRENT);
    
//    dispatch_async(queue, ^{
//        NSMutableArray *arr = [NSMutableArray array];
//        for (NSInteger i = 1; i < 10000000000000; i++) {
//            [arr addObject:[NSNumber numberWithInteger:i]];
//        }
//    });
    
}
- (void)loglog {
    _count++;
    NSLog(@"hahahah = %li",_count);
}

-(void)test {
    NSString *str = @"我自阿女地方保护第四部分1234123213213大手笔服fjdsbkgjdbsjigbdsi53bhjdknfbksdgfjbjk";
    NSScanner *scanner = [NSScanner scannerWithString:str];
    NSCharacterSet *characterSetting = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
//    [scanner initWithString:@"大手"];
    NSString *value = nil;
    while (!scanner.isAtEnd) {
        BOOL isfind = [scanner scanUpToCharactersFromSet:characterSetting intoString:NULL];
        if (isfind) {
            NSLog(@"value = %@",value);
            [scanner scanCharactersFromSet:characterSetting intoString:&value];
        }
        NSLog(@"local = %li",scanner.scanLocation);
    }
    
}

- (void)socket {
   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
