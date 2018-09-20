//
//  SimpleToast.m
//  SQliteDemo
//
//  Created by Assassin on 2018/5/15.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "SimpleToast.h"

#define SCREEN_WIDTH ([NSScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([NSScreen mainScreen].bounds.size.height)

@interface SimpleToast()

@end


@implementation SimpleToast

/***  显示导航栏提醒  ***/
-(void)showNaviString:(NSString *)string{
    
}

-(void)hiddenView{
  
    
}

/*** 导航点击事件 ***/
-(void)addTarget:(id)target action:(SEL)action{
    
}


-(void)clickToastView{
   
    
}
/*** 底部toast 默认时间显示为3s ***/
+(void)showToastString:(NSString *)string{
    
}
/*** 底部toast  自定义显示时间***/
+ (void)showToastString:(NSString *)string showTime:(float)showTime
{
    
}


//根据字符串长度获取对应的宽度或者高度
+ (CGFloat)stringText:(NSString *)text font:(CGFloat)font isHeightFixed:(BOOL)isHeightFixed fixedValue:(CGFloat)fixedValue
{
    return 0;
}


@end
