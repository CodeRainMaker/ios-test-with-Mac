//
//  TSYMethodSwizzled.m
//  SQliteDemo
//
//  Created by Assassin on 2018/5/14.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "TSYMethodSwizzled.h"
#import <objc/runtime.h>

@implementation TSYMethodSwizzled

+ (BOOL)methodSwizzled:(SEL)orginalSel withNew:(SEL)newSel withClass:(Class)cls{
    Class className = cls;
    // 通过class_getInstanceMethod()函数从当前对象中的method list获取method结构体，如果是类方法就使用class_getClassMethod()函数获取。
    Method fromMethod = class_getInstanceMethod(className, orginalSel);
    Method toMethod = class_getInstanceMethod(className, newSel);
 
    if (class_addMethod([self class], orginalSel, method_getImplementation(fromMethod), method_getTypeEncoding(fromMethod))) {
        return NO;
    }
    if (class_addMethod([self class], newSel, method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
        return NO;
    }
    
    method_exchangeImplementations(fromMethod, toMethod);
    
    return YES;
}

@end
