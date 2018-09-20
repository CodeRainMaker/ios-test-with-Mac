//
//  SimpleToast.h
//  SQliteDemo
//
//  Created by Assassin on 2018/5/15.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ToastView : UILabel
+(ToastView*) sharedToastView;
@end


@interface TSYToastLabel : UILabel
+(TSYToastLabel*) sharedCSYToastLabel;
@end

@interface SimpleToast : NSObject

/***  显示导航栏提醒  ***/
-(void)showNaviString:(NSString*)string;

/*** 导航点击事件 ***/
-(void)addTarget:(id)target action:(SEL)action;

/*** 底部toast 默认时间显示为3s ***/
+(void)showToastString:(NSString *)string;

/*** 底部toast  自定义显示时间***/
+ (void)showToastString:(NSString *)string showTime:(float)showTime;


@end

