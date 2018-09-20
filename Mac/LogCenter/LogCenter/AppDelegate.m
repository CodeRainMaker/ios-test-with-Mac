//
//  AppDelegate.m
//  LogCenter
//
//  Created by Assassin on 2018/5/11.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "AppDelegate.h"

#define STATIC_WINDOW_HEIGHT 720
#define STATIC_WINDOW_WIDTH  960

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    //设置最小尺寸
    self.mainWindow.minSize = CGSizeMake(STATIC_WINDOW_WIDTH, STATIC_WINDOW_HEIGHT);
}

- (NSWindow*)mainWindow
{
    NSWindow *window = [NSApp mainWindow];

    return window;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
