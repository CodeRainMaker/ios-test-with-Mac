//
//  TSYMethodSwizzled.h
//  SQliteDemo
//
//  Created by Assassin on 2018/5/14.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSYMethodSwizzled : NSObject

+ (BOOL)methodSwizzled:(SEL)orginalSel withNew:(SEL)newSel withClass:(Class)cls;

@end
