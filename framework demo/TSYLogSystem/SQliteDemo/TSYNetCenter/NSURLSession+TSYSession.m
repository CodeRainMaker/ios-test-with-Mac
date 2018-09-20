//
//  NSURLSession+TSYSession.m
//  SQliteDemo
//
//  Created by Assassin on 2018/5/14.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "NSURLSession+TSYSession.h"
#import "TSYNetWatch.h"
#import <objc/runtime.h>
#import "TSYMethodSwizzled.h"

static BOOL isChanged;

static char *TSY_CHANGE_KEY = "TSY_CHANGE_KEY";

@implementation NSURLSession (TSYSession)

+ (void)tsy_initWithConfiguration:(NSURLSessionConfiguration *)config delegate:(id<NSURLSessionDelegate>)delegate delegateQueue:(NSOperationQueue *)queue{
    if (config.protocolClasses != nil ){
        NSMutableArray<Class> *cls = [NSMutableArray arrayWithObjects:config.protocolClasses,nil];
        [cls insertObject:[TSYNetWatch classForCoder] atIndex:0];
        config.protocolClasses = [cls copy];
    }else {
        config.protocolClasses = @[[TSYNetWatch classForCoder]];
    }
    [self tsy_initWithConfiguration:config delegate:delegate delegateQueue:queue];
}

+ (void)startWatch {
    if (isChanged == NO && [[NSURLSession new] changeMethod] == YES){
        isChanged = YES;
    }else {
        NSLog(@"TSYNetWatch already started watch failure");
    }
}

+ (void)stopWatch {
    if (isChanged == YES && [[NSURLSession new] changeMethod] == YES){
        isChanged = NO;
    }else {
        NSLog(@"TSYNetWatch already stop watch failure");
    }
}

-(void)setIsChanged:(BOOL)isChanged {
    objc_setAssociatedObject(self, TSY_CHANGE_KEY, [NSNumber numberWithBool:isChanged], OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)isChanged {
    id value = objc_getAssociatedObject(self, TSY_CHANGE_KEY);
    if (value == nil) {
        return NO;
    }
    BOOL isValue = [value boolValue];
    return isValue;
    
}

- (BOOL)changeMethod {
    Class cl = [self class];
    SEL sel = NSSelectorFromString(@"sessionWithConfiguration:delegate:delegateQueue:");
    SEL sel2 = @selector(tsy_initWithConfiguration:delegate:delegateQueue:);
    
    return [TSYMethodSwizzled methodSwizzled:sel withNew:sel2 withClass:cl];
}


@end
