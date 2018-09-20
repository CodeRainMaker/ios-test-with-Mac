//
//  TopNavigationViewController.m
//  LogCenter
//
//  Created by Assassin on 2018/9/12.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "TopNavigationViewController.h"

@interface TopNavigationViewController ()

@property(nonatomic,strong)TopButton *selectedBtn;

@end

@implementation TopNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)topFirstButtonClickAction {
    [self buttonClick:_buttonLeft];
}

#pragma mark -button click

- (IBAction)buttonClick:(TopButton *)sender {
    
    if (_selectedBtn && _selectedBtn.tag == sender.tag) {
        return;
    }
    
    if (!_buttonDelegate || ![_buttonDelegate respondsToSelector:@selector(onTopButtonClick:)]) {
        return;
    }
    
    NSInteger tag = sender.tag;
    ButtonClickType type = ButtonClickTypeLight;
    if (tag == 2){
        type = ButtonClickTypeCenter;
    }else if (tag == 3){
        type = ButtonClickTypeRight;
    }
    _selectedBtn = sender;
    [_buttonDelegate onTopButtonClick:type];
    [self updateSelectedButtonStatus:tag];
    [self buttonStatueChange:type];
}

- (void)buttonStatueChange:(ButtonClickType)type {
    switch (type) {
        case ButtonClickTypeLight:
            break;
        case ButtonClickTypeCenter:
            break;
        case ButtonClickTypeRight:
            break;
        default:
            break;
    }
}

//改变状体
- (void)updateSelectedButtonStatus:(NSInteger)tag{
    //改变图片
    _buttonLeft.tag != tag ? [_buttonLeft setNormalImage:[NSImage imageNamed:@"icon_computer"]] : [_buttonLeft setNormalImage:[NSImage imageNamed:@"icon_computer_selected"]];
    _buttonCenter.tag != tag ? [_buttonCenter setNormalImage:[NSImage imageNamed:@"icon_task"]] : [_buttonCenter setNormalImage:[NSImage imageNamed:@"icon_task_selected"]];
    _buttonRight.tag != tag ? [_buttonRight setNormalImage:[NSImage imageNamed:@"icon_warning"]] : [_buttonRight setNormalImage:[NSImage imageNamed:@"icon_warning_selected"]];
}


@end
