//
//  AnimationBaseView.h
//  LogCenter
//
//  Created by Assassin on 2018/9/14.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//显示的图标类型
typedef NS_ENUM(NSUInteger, BaseViewType) {
    BaseViewTypeSquare          = 0,
    BaseViewTypeCircle          = 1,
    BaseViewTypeCircleHalf      = 2,
    BaseViewTypeCircleWifi      = 3,
};

//MARK:可以选择画图的类型，全圆还是4/5的圆
typedef NS_ENUM(NSUInteger, CircleType) {
     /// 圆弧类型
    CircularType    = 0,
    /// 圆
    CircleTypeRound = 1,
};


@interface AnimationBaseView : NSView

- (instancetype)initWithType:(BaseViewType)type;

- (void)setTopTitleStr:(NSString*)str;

- (void)setSquartData:(NSString*)data;
- (void)setSquartData2:(NSString*)data;
- (void)setCircleData:(NSArray*)data;
- (void)setCircleDataToOther:(NSNumber*)data;
- (void)setHalfData:(NSString*)data;

@end
