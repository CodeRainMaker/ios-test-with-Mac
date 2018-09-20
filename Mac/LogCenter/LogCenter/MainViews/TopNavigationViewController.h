//
//  TopNavigationViewController.h
//  LogCenter
//
//  Created by Assassin on 2018/9/12.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TopButton.h"

typedef NS_ENUM(NSUInteger, ButtonClickType) {
    ButtonClickTypeLight    = 0,
    ButtonClickTypeCenter   = 1,
    ButtonClickTypeRight    = 2,
};

@protocol TopNavigationViewControllerButtonClickDelegate <NSObject>

-(void)onTopButtonClick:(ButtonClickType)buttonType;

@end

@interface TopNavigationViewController : NSViewController

@property(nonatomic,weak) id<TopNavigationViewControllerButtonClickDelegate> buttonDelegate;

@property (weak) IBOutlet TopButton *buttonLeft;

@property (weak) IBOutlet TopButton *buttonCenter;

@property (weak) IBOutlet TopButton *buttonRight;

- (void)topFirstButtonClickAction;

@end
