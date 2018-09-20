//
//  TSYSystemManager.h
//  SQliteDemo
//
//  Created by Assassin on 2018/5/14.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSYSocketMsgDefine.h"

@interface NetModel : NSObject

@property (nonatomic,assign) u_int32_t wifiSend;
@property (nonatomic,assign) u_int32_t wifiReceived;
@property (nonatomic,assign) u_int32_t wwanSend;
@property (nonatomic,assign) u_int32_t wwanReceived;

@end


@protocol TSYSystemManagerDelegate <NSObject>

- (void)watchSendInfo:(NSString *_Nullable)info withType:(TSYMsgType)type;

@end

@interface TSYSystemManager : NSObject

@property(nonatomic,weak,nullable) id<TSYSystemManagerDelegate>delegate;

+(TSYSystemManager *_Nullable)intanceSystem;

- (NSDictionary*)getAllDeviceInfo;//获取所有硬件信息
- (NSDictionary*)getAllUseInfo;   //获取所有系统使用状态

//FPS
- (void)startWatch;
- (void)stopWatch;

//cpu
- (NSArray<NSString*> *)getCPUInfo;
- (double)getCPUUsage;
- (double)getApplicationUsage;

//memory
- (double)getSystemMemory;
- (double)getAppUseMemory;

//device
- (NSArray *_Nullable)getDeviceInfo;
- (NSString *_Nonnull)getDeviceName;

//netDevice
- (nullable NSString *)getWifiIPAddress;
- (nullable NSString *)getWifiNetmaskAddress;
- (nullable NSString *)getCellIPAddress;
- (nullable NSString *)getCellNetmaskAddress;

- (void)startNetWatch;
- (void)stopNetWatch;

@end
