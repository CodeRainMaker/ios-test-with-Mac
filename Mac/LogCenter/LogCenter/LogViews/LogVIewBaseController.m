//
//  LogVIewBaseController.m
//  LogCenter
//
//  Created by Assassin on 2018/8/24.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "LogVIewBaseController.h"

//基础试图

@interface LogVIewBaseController ()

@property(nonatomic,strong)CALayer *subLayout;

@property(nonatomic,strong)NSView *subView;//容器

@property(nonatomic,strong)NSText *topTitle;

@property(nonatomic,strong)NSText *infoTitle;

@property(nonatomic,strong)NSButton *topButton;

@end

@implementation LogVIewBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self addViewSetting];
    [self.view.layer setBackgroundColor:[[NSColor redColor] CGColor]];
}

//添加视图
- (void)addViewSetting {
    [self.view addSubview: self.subView];
    [self.subView.layer addSublayer:self.subLayout];
    [self.view addSubview: self.topTitle];
    [self.view addSubview: self.infoTitle];
//    [self.view addSubview: self.topButton];
}

- (void)viewDidLayout {
    [super viewDidLayout];
    
     //button frame
    CGFloat w = self.size.width;
    CGFloat x = w - 40;
    self.topButton.frame = CGRectMake(x, 10, 30, 40);
    self.topTitle.string = @"显示的标题";

    self.topTitle.frame = CGRectMake(x, 10, 30, 40);
}
//基础设置
- (NSView*)subView {
    if (!_subView) {
        _subView = [NSView new];
    }
    return _subView;
}

- (CALayer*)subLayout {
    if (!_subLayout) {
        _subLayout = [[CALayer alloc] init];
    }
    return _subLayout;
}

- (NSText*)topTitle {
    if (!_topTitle) {
        _topTitle = [[NSText alloc] init];
    }
    return _topTitle;
}

- (NSText*)infoTitle {
    if (!_infoTitle) {
        _infoTitle = [[NSText alloc] init];
    }
    return _infoTitle;
}

//- (NSButton*)topButton {
//    if (!_topButton) {
//        _topButton = [NSButton buttonWithImage:[NSImage imageNamed:@""] target:self action:@selector(butttonEvent)];
//    }
//    return _topButton;
//}

#pragma mark -buttonEvent

-(void)butttonEvent {
    
}

#pragma mark -util
-(CGSize)size {
    return self.view.frame.size;
}


@end
