//
//  TSYSystemManager.m
//  SQliteDemo
//
//  Created by Assassin on 2018/5/14.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "TSYSystemManager.h"
#import <UIKit/UIKit.h>
#import "YYWeakProxy.h"
#import <QuartzCore/QuartzCore.h>
#import <mach/mach.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>
#import <sys/socket.h>
#import <sys/types.h>
#import <sys/mman.h>
#import <sys/ioctl.h>
#import <ifaddrs.h>
#import <net/if.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@implementation NetModel

@end


@interface TSYSystemManager()

@property(nonatomic,strong)CADisplayLink *caLink;

@property(nonatomic,assign)NSInteger count;

@property(nonatomic,assign)CFTimeInterval lastTime;

@property(nonatomic,assign)CFTimeInterval updateInterval;

@property(nonatomic,assign)mach_port_t machHost;

@property(nonatomic,assign)unsigned long long systemMemoryTotal;

@property(nonatomic,strong)NSThread *netThread;

@property(nonatomic,strong)NetModel *netModel;

@property(nonatomic,assign)host_cpu_load_info_data_t preCPUInfo;

@property(nonatomic,assign)double nowFps;

@end
  //获取当前系统信息指针

@implementation TSYSystemManager

+(TSYSystemManager *)intanceSystem {
    static  TSYSystemManager   *manager    = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TSYSystemManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.count = 0;
        self.updateInterval = 0.0;
        _machHost = mach_host_self();
        _systemMemoryTotal = NSProcessInfo.processInfo.physicalMemory;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startWatch {
    
    [self.caLink setPaused:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)stopWatch {
    
    [self.caLink setPaused:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startNetWatch {
    [self stopNetWatch];
    self.netThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadHandler) object:nil];;
    [self.netThread start];
}

- (void)stopNetWatch {
    if (self.netThread) {
        [self.netThread cancel];
        self.netThread = nil;
    }
   
}

#pragma mark --get INfo
- (NSDictionary*)getAllUseInfo {
    double cpuUse = [self getCPUUsage];
    double appUse = [self getApplicationUsage2];
    double sysUseM = [self getSystemMemory];
    double appUseM = [self getAppUseMemory];
    double appUseMAll = [self getAppUseMemory]*self.systemMemoryTotal/1024/1024;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:[NSNumber numberWithDouble:cpuUse] forKey:@"cpuUse"];
    [dic setValue:[NSNumber numberWithDouble:appUse] forKey:@"appUse"];
    [dic setValue:[NSNumber numberWithDouble:sysUseM] forKey:@"sysUseM"];
    [dic setValue:[NSNumber numberWithDouble:appUseM] forKey:@"appUseM"];
    [dic setValue:[NSNumber numberWithDouble:appUseMAll] forKey:@"appUseMAll"];
    
    return dic;
}

- (NSDictionary*)getAllDeviceInfo {
    NSArray *arrayCpuNums = [self getCPUInfo];
    NSArray *deviceInfo = [self getDeviceInfo];
    NSString *name = [self getDeviceName];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (arrayCpuNums.count >=2 ) {
        [dic setValue:arrayCpuNums[0] forKey:@"cpuNums"];
        [dic setValue:arrayCpuNums[1] forKey:@"cpuNumsV"];
    }
    if (deviceInfo.count == 4) {
        [dic setValue:deviceInfo.lastObject forKey:@"systemVersion"];
    }
    
    [dic setValue:name forKey:@"phoneName"];
    [dic setValue:[NSString stringWithFormat:@"%lli",_systemMemoryTotal/1024/1024/1024] forKey:@"memoryTotal"];
    
    return dic;
}

#pragma mark ###### FPS

-(CADisplayLink *)caLink {
    if (!_caLink) {
        _caLink = [CADisplayLink displayLinkWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(displayLinkHandler)];
        [_caLink setPaused:YES];
        [_caLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _caLink;
}

-(void)displayLinkHandler{
    @synchronized(self){
        self.count ++;
        
        if (self.lastTime <= self.updateInterval) {
            self.lastTime = self.caLink.timestamp;
            return;
        }
        
        CFTimeInterval interval = self.caLink.timestamp - self.lastTime;
        if (interval < 1.f) {
            return;
        }
        double fps = self.count / interval;
        self.count = 0;
        self.lastTime = self.caLink.timestamp;
        if (ceil(_nowFps) == ceil(fps)) {
            return;
        }else {
            _nowFps = fps;
        }
        //这里向外面输出数据 fps的数据
        if (_delegate && [_delegate respondsToSelector:@selector(watchSendInfo:withType:)]) {
            [_delegate watchSendInfo:[NSString stringWithFormat:@"%.1lf",fps] withType:TSY_Msg_Type_FPS];
        }
    }
    
}

- (void)applicationWillResignActiveNotification{
    [self.caLink setPaused:YES];
}

- (void)applicationDidBecomeActiveNotification {
    [self.caLink setPaused:NO];
}

#pragma mark ##### CPU

- (NSArray<NSString*> *)getCPUInfo {
    NSMutableArray *infoArray = [NSMutableArray array];
    mach_msg_type_number_t size = HOST_BASIC_INFO_COUNT;
    host_basic_info_data_t cpuInfo;
    
    kern_return_t kernReturn = host_info(_machHost, HOST_BASIC_INFO, (host_info_t)&cpuInfo, &size);
    
    if (kernReturn != KERN_SUCCESS) {
        return nil;
    }
    
    [infoArray addObject:[NSString stringWithFormat:@"%i",cpuInfo.physical_cpu]];
    [infoArray addObject:[NSString stringWithFormat:@"%i",cpuInfo.logical_cpu]];
    
    return [infoArray copy];
}

//user:用户态使用
//system:系统使用
//idle:空闲
//nice:nice加权的进程分配的用户态
- (double)getCPUUsage {
    mach_msg_type_number_t size = HOST_CPU_LOAD_INFO_COUNT;
    host_cpu_load_info_data_t cpuInfo;
    
    kern_return_t kernReturn = host_statistics(_machHost, HOST_CPU_LOAD_INFO, (host_info_t)&cpuInfo, &size);
    
    if (kernReturn != KERN_SUCCESS) {
        return 0;
    }
    
    double userCPU = cpuInfo.cpu_ticks[0] - _preCPUInfo.cpu_ticks[0];
    double sysCPU  = cpuInfo.cpu_ticks[1] - _preCPUInfo.cpu_ticks[1];
    double idleCPU = cpuInfo.cpu_ticks[2] - _preCPUInfo.cpu_ticks[2];
    double niceCPU = cpuInfo.cpu_ticks[3] - _preCPUInfo.cpu_ticks[3];
    
    double cpuTotal = userCPU + sysCPU + idleCPU + niceCPU;
    
    double user = userCPU / cpuTotal;
    double sys  = sysCPU / cpuTotal;
//    double idle = idleCPU / cpuTotal;
    double nice = niceCPU / cpuTotal;
    
    _preCPUInfo = cpuInfo;
    double ss = user + sys + nice;
    return ss;
}

- (double)getApplicationUsage2{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

- (double)getApplicationUsage {
    //获取运行的所有线程
    
    thread_act_array_t threads_array;
    mach_msg_type_number_t count;
    kern_return_t kernReturn;
    thread_info_data_t thinfo;
    
    kernReturn = task_threads(mach_task_self(), &threads_array, &count);
    
    if ((kernReturn != KERN_SUCCESS) || !threads_array) {
        return 0;
    }
    
    kernReturn = vm_deallocate(mach_task_self(), (vm_offset_t)threads_array, count * (UInt32)sizeof(thread_t));
    if (kernReturn != KERN_SUCCESS) {
        return 0;
    }
    
    long tot_sec = 0;
    long tot_usec = 0;
    double tot_cpu = 0;
    thread_basic_info_t basic_info_th;
    for (int i = 0; i <count; i++) {
        mach_msg_type_number_t thread_info_count = THREAD_INFO_MAX;
        kernReturn = thread_info(threads_array[i], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count);
        if (kernReturn != KERN_SUCCESS) {
            continue;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
    }
    
    return tot_cpu;
}


#pragma mark ##### 内存

- (double)getSystemMemory {

    mach_msg_type_number_t size = HOST_VM_INFO_COUNT;
    vm_statistics64_data_t vmStats;
    kern_return_t kernReturn = host_statistics(_machHost, HOST_VM_INFO, (host_info_t)&vmStats, &size);
    
    if (kernReturn != KERN_SUCCESS) {
        return 0;
    }
    
    double pageSize = vm_kernel_page_size; //字节数
    double free = vmStats.free_count * pageSize;
    double active = vmStats.active_count * pageSize; //页面数*字节数
    double inactive = vmStats.inactive_count * pageSize;
    double wired = vmStats.wire_count * pageSize;
    double compressed = vmStats.compressor_page_count * pageSize;
    
    double totalUse = active + inactive + wired +compressed;
    
    return (self.systemMemoryTotal - free - inactive) / self.systemMemoryTotal;
}

- (double)getAppUseMemory {
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t size = TASK_BASIC_INFO_COUNT;
    
    kern_return_t kernReturn = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&taskInfo, &size);
    
    if (kernReturn != KERN_SUCCESS) {
        return 0;
    }
    
    double resident = taskInfo.resident_size;
//    double virtual = taskInfo.virtual_size;
    
    return resident / self.systemMemoryTotal;
}

#pragma mark ###### 硬件 HardDevice

- (NSArray *)getDeviceInfo {
    NSMutableArray *infoArray = [NSMutableArray array];
    UIDevice *device = [UIDevice currentDevice];
    [infoArray addObject:device.model];
    [infoArray addObject:device.name];
    [infoArray addObject:device.systemName];
    [infoArray addObject:device.systemVersion];
    
    return [infoArray copy];
}

- (NSString *)getDeviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone7";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"iPhone7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone7Plus";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"iPhone7Plus";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}

#pragma mark ###### 网络硬件

- (void)threadHandler {
    while (true) {
        if ([NSThread currentThread].isCancelled) {
            [NSThread exit];
        }
        
        NetModel *model = [self flow];
        if (_netModel == nil) {
            _netModel = model;
        }else {
            model.wifiSend -= _netModel.wifiSend;
            model.wifiReceived -= _netModel.wifiReceived;
            model.wwanSend -= _netModel.wwanSend;
            model.wwanReceived -= _netModel.wwanReceived;
        }
        [NSThread sleepForTimeInterval:1];
    }
}

//流量监控
- (nonnull NetModel *)flow {
    NetModel *result = [[NetModel alloc] init];
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    if (getifaddrs(&addrs) == 0) {
        
        cursor = addrs;
        while (cursor != NULL)
        {
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if (strcmp(cursor->ifa_name, "en0") == 0) {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    result.wifiSend += networkStatisc->ifi_obytes;
                    result.wifiReceived += networkStatisc->ifi_ibytes;
                }
                
                if (strcmp(cursor->ifa_name, "pdp_ip0") == 0) {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    result.wwanSend += networkStatisc->ifi_obytes;
                    result.wwanReceived += networkStatisc->ifi_ibytes;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    
    return result;
}

- (nullable NSString *)getWifiIPAddress {
    // Set a string for the address
    NSString *result;
    // Set up structs to hold the interfaces and the temporary address
    struct ifaddrs *interfaces;
    struct ifaddrs *temp;
    // Set up int for success or fail
    int status = 0;
    
    // Get all the network interfaces
    status = getifaddrs(&interfaces);
    
    // If it's 0, then it's good
    if (status == 0) {
        // Loop through the list of interfaces
        temp = interfaces;
        // Run through it while it's still available
        while(temp != NULL) {
            // If the temp interface is a valid interface
            if(temp->ifa_addr->sa_family == AF_INET){
                // Check if the interface is WiFi
                if([[NSString stringWithUTF8String:temp->ifa_name] isEqualToString:@"en0"]){
                    // Get the WiFi IP Address
                    result = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp->ifa_addr)->sin_addr)];
                }
            }
            
            // Set the temp value to the next interface
            temp = temp->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return result;
}

// Get WiFi Netmask Address
- (nullable NSString *)getWifiNetmaskAddress {
    // Set up the variable
    struct ifreq afr;
    // Copy the string
    strncpy(afr.ifr_name, [@"en0" UTF8String], IFNAMSIZ-1);
    // Open a socket
    int afd = socket(AF_INET, SOCK_DGRAM, 0);
    
    // Check the socket
    if (afd == -1) {
        // Error, socket failed to open
        return nil;
    }
    
    // Check the netmask output
    if (ioctl(afd, SIOCGIFNETMASK, &afr) == -1) {
        // Error, netmask wasn't found
        close(afd);
        return nil;
    }
    
    // Close the socket
    close(afd);
    
    // Create a char for the netmask
    char *netstring = inet_ntoa(((struct sockaddr_in *)&afr.ifr_addr)->sin_addr);
    
    // Create a string for the netmask
    NSString *netmask = [NSString stringWithUTF8String:netstring];
    
    // Return successful
    return netmask;
}


// Get Cell IP Address
- (nullable NSString *)getCellIPAddress {
    // Set a string for the address
    NSString *IPAddress;
    // Set up structs to hold the interfaces and the temporary address
    struct ifaddrs *Interfaces;
    struct ifaddrs *temp;
    struct sockaddr_in *s4;
    char buf[64];
    
    // If it's 0, then it's good
    if (!getifaddrs(&Interfaces)) {
        // Loop through the list of interfaces
        temp = Interfaces;
        
        // Run through it while it's still available
        while(temp != NULL) {
            // If the temp interface is a valid interface
            if(temp->ifa_addr->sa_family == AF_INET) {
                // Check if the interface is Cell
                if([[NSString stringWithUTF8String:temp->ifa_name] isEqualToString:@"pdp_ip0"]) {
                    s4 = (struct sockaddr_in *)temp->ifa_addr;
                    
                    if (inet_ntop(temp->ifa_addr->sa_family, (void *)&(s4->sin_addr), buf, sizeof(buf)) == NULL) {
                        // Failed to find it
                        IPAddress = nil;
                    } else {
                        // Got the Cell IP Address
                        IPAddress = [NSString stringWithUTF8String:buf];
                    }
                }
            }
            
            // Set the temp value to the next interface
            temp = temp->ifa_next;
        }
    }
    
    // Free the memory of the interfaces
    freeifaddrs(Interfaces);
    
    // Check to make sure it's not empty
    if (IPAddress == nil || IPAddress.length <= 0) {
        // Empty, return not found
        return nil;
    }
    
    // Return the IP Address of the WiFi
    return IPAddress;
}

- (nullable NSString *)getCellNetmaskAddress {
    // Set up the variable
    struct ifreq afr;
    // Copy the string
    strncpy(afr.ifr_name, [@"pdp_ip0" UTF8String], IFNAMSIZ-1);
    // Open a socket
    int afd = socket(AF_INET, SOCK_DGRAM, 0);
    
    // Check the socket
    if (afd == -1) {
        // Error, socket failed to open
        return nil;
    }
    
    // Check the netmask output
    if (ioctl(afd, SIOCGIFNETMASK, &afr) == -1) {
        // Error, netmask wasn't found
        // Close the socket
        close(afd);
        // Return error
        return nil;
    }
    
    // Close the socket
    close(afd);
    
    // Create a char for the netmask
    char *netstring = inet_ntoa(((struct sockaddr_in *)&afr.ifr_addr)->sin_addr);
    
    // Create a string for the netmask
    NSString *Netmask = [NSString stringWithUTF8String:netstring];
    
    // Return successful
    return Netmask;
}

@end
