//
//  SystemCenterManager.h
//  LogCenter
//
//  Created by Assassin on 2018/5/15.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface SystemCenterManager : NSObject<GCDAsyncSocketDelegate>

+(SystemCenterManager *)intanceSystem;

- (void)beginLog;

@end
