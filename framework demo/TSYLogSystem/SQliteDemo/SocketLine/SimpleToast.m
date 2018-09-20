//
//  SimpleToast.m
//  SQliteDemo
//
//  Created by Assassin on 2018/5/15.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "SimpleToast.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

static ToastView *toastView = nil;
@implementation ToastView
+(ToastView*) sharedToastView{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(toastView == nil)
        {
            toastView = [[self alloc] initWithFrame:CGRectMake(0, -64, SCREEN_WIDTH, 64)];
            toastView.alpha = 0;
            toastView.userInteractionEnabled = YES;
            toastView.backgroundColor = [UIColor blueColor];
            toastView.textColor = [UIColor whiteColor];
            toastView.font = [UIFont systemFontOfSize:14];
            toastView.textAlignment = NSTextAlignmentCenter;
            toastView.numberOfLines = 0;
        }
        
    });
    return toastView;
}

@end

static TSYToastLabel *toastLabel = nil;
@implementation TSYToastLabel
+(TSYToastLabel*) sharedCSYToastLabel{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(toastLabel == nil)
        {
            toastLabel = [[self alloc] init];
            toastLabel.textColor = [UIColor redColor];
            toastLabel.textAlignment = NSTextAlignmentCenter;
            toastLabel.alpha = 0;
            toastLabel.numberOfLines = 0;
            toastLabel.lineBreakMode = NSLineBreakByCharWrapping;
        }
    });
    return toastLabel;
}

@end

@interface SimpleToast()

@property (nonatomic,assign)id  target;
@property (nonatomic,assign)SEL action;
@property (nonatomic,strong)ToastView * toastView;

@end


@implementation SimpleToast

/***  显示导航栏提醒  ***/
-(void)showNaviString:(NSString *)string{
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showNaviString:string];
        });
        return;
    }
    self.toastView = [ToastView sharedToastView];
    [[UIApplication sharedApplication].keyWindow addSubview:self.toastView];
    if (self.toastView.superview != [UIApplication sharedApplication].keyWindow) {
        [self.toastView removeFromSuperview];
        [[UIApplication sharedApplication].keyWindow addSubview:self.toastView];
    }
    self.toastView.text = string;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToastView)];
    [self.self.toastView addGestureRecognizer:tap];
    
    if (!self.toastView.alpha)
    {
        self.toastView.alpha = 1.f;
        CGRect rect = self.toastView.frame;
        rect.origin.y = 0;
        [UIView animateWithDuration:0.5 animations:^{
            self.toastView.frame = rect;
        } completion:^(BOOL finished) {
            [self performSelector:@selector(hiddenView) withObject:self.toastView afterDelay:2];
            
        }];
    }
    
}

-(void)hiddenView{
    CGRect rect = self.toastView.frame;
    rect.origin.y = -64;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.toastView.frame = rect;
    } completion:^(BOOL finished) {
        self.toastView.alpha = 0.f;
    }];
    
}

/*** 导航点击事件 ***/
-(void)addTarget:(id)target action:(SEL)action{
    _target = target;
    _action = action;
}


-(void)clickToastView{
    if (!_target || !_action) {
        return;
    }
    [_target performSelector:_action withObject:self];
    
}
/*** 底部toast 默认时间显示为3s ***/
+(void)showToastString:(NSString *)string{
    [self showToastString:string showTime:3.0f];
}
/*** 底部toast  自定义显示时间***/
+ (void)showToastString:(NSString *)string showTime:(float)showTime
{
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showToastString:string showTime:showTime];
        });
        return;
    }
    UILabel *toastView = [TSYToastLabel sharedCSYToastLabel];
    [[UIApplication sharedApplication].keyWindow addSubview:toastView];
    if (toastView.superview != [UIApplication sharedApplication].keyWindow) {
        [toastView removeFromSuperview];
        [[UIApplication sharedApplication].keyWindow addSubview:toastView];
    }
    
    CGFloat width = [self stringText:string font:17 isHeightFixed:YES fixedValue:30];
    CGFloat height = 30;
    if (width > SCREEN_WIDTH - 30) {
        width = SCREEN_WIDTH - 30;
        height = [self stringText:string font:17 isHeightFixed:NO fixedValue:width];
    }
    
    CGRect frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-width-10)/2,SCREEN_HEIGHT, width+10, height);
    
    toastView.text = string;
    toastView.font = [UIFont systemFontOfSize:17];
    toastView.layer.cornerRadius = height/2;
    toastView.layer.masksToBounds = YES;
    toastView.layer.borderWidth = 1.0f;
    toastView.layer.borderColor = [UIColor redColor].CGColor;
    toastView.frame = frame;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = toastView.frame;
        rect.origin.y = SCREEN_HEIGHT-40-rect.size.height;
        toastView.frame = rect;
        toastView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:showTime animations:^{
            toastView.alpha = 0;
        }];
    }];
    
}


//根据字符串长度获取对应的宽度或者高度
+ (CGFloat)stringText:(NSString *)text font:(CGFloat)font isHeightFixed:(BOOL)isHeightFixed fixedValue:(CGFloat)fixedValue
{
    CGSize size;
    if (isHeightFixed) {
        size = CGSizeMake(MAXFLOAT, fixedValue);
    } else {
        size = CGSizeMake(fixedValue, MAXFLOAT);
    }
    
    CGSize resultSize;
    //返回计算出的size
    resultSize = [text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:font]} context:nil].size;
    
    if (isHeightFixed) {
        return resultSize.width;
    } else {
        return resultSize.height;
    }
}


@end
