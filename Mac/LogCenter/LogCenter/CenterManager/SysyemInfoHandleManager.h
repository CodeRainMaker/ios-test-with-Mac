//
//  SysyemInfoHandleManager.h
//  LogCenter
//
//  Created by Assassin on 2018/9/19.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Foundation/Foundation.h>
//信息调度中心
@interface SysyemInfoHandleManager : NSObject

+(SysyemInfoHandleManager *)intanceManager;

//处理socker传递过来的信息
- (void)handleInfoToController:(NSDictionary*)infoDic;

@end
