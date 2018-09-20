//
//  ViewController.m
//  LogCenter
//
//  Created by Assassin on 2018/5/11.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "ViewController.h"
#import "SystemCenterManager.h"
#import "LogVIewBaseController.h"

#import "TopNavigationViewController.h"
#import "ComputerController.h"

@interface ViewController()<TopNavigationViewControllerButtonClickDelegate>

@property (weak) IBOutlet NSView *mainShowView;

@property(nonatomic,strong)NSView *nowShowVIew;

//controllers
@property(nonatomic,strong)TopNavigationViewController *topCtr;

//4
@property(nonatomic,strong)ComputerController *computerController;

@end

//主窗口
@implementation ViewController

#pragma mark -init dealloc

- (void)dealloc {
    
}

#pragma mark -viewdidload

- (void)viewDidLoad {
    [super viewDidLoad];

    //开启数据监听交互
    [[SystemCenterManager intanceSystem] beginLog];
    
    //设置背景颜色
    [self.mainShowView.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    
    [self addControllers];
    [self showFirstView];
}

- (void)awakeFromNib {
    //加载各个主要显示的controller view
    [self controllerSetting];
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)showFirstView {
    if (_topCtr) {
        [_topCtr topFirstButtonClickAction];
    }
}

#pragma mark -controller setting

- (void)controllerSetting {
    if (!_topCtr) {
        _topCtr = [[TopNavigationViewController alloc]initWithNibName:@"TopNavigationViewController" bundle:nil];
        NSView *topNavView = _topCtr.view;
        topNavView.translatesAutoresizingMaskIntoConstraints = NO;
        [_topView addSubview:topNavView];
        _topCtr.buttonDelegate = self;
        [_topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topNavView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topNavView)]];
        [_topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topNavView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topNavView)]];
        
        NSView *visualEffectView = nil;
        visualEffectView = [[NSClassFromString(@"NSVisualEffectView") alloc] initWithFrame:_topView.frame];
        if (visualEffectView)
        {
            [visualEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [_topView addSubview:visualEffectView positioned:NSWindowBelow relativeTo:_topView];
            [_topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[visualEffectView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(visualEffectView)]];
            [_topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[visualEffectView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(visualEffectView)]];
        }
    }
}

//添加controllers
- (void)addControllers {
    [self addChildViewController:self.computerController];
}

#pragma mark ---Controllers


- (ComputerController*)computerController {
    if (!_computerController) {
        _computerController = [[ComputerController alloc] initWithNibName:@"ComputerController" bundle:nil];
    }
    return _computerController;
}

#pragma mark --- showController

- (void)showComputerController {
    if (_nowShowVIew) {
        [_nowShowVIew removeFromSuperview];
    }
    self.mainShowView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainShowView addSubview:_computerController.view];
    _nowShowVIew = _computerController.view;
    [self.mainShowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nowShowVIew]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nowShowVIew)]];
    [self.mainShowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nowShowVIew]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_nowShowVIew)]];
}


#pragma mark -button delegate
- (void)onTopButtonClick:(ButtonClickType)buttonType {
    switch (buttonType) {
        case ButtonClickTypeLight:
            [self showComputerController];
            break;
        case ButtonClickTypeCenter:
            break;
        case ButtonClickTypeRight:
            break;
        default:
            break;
    }
}


#pragma mark -获取尺寸
-(CGSize)getViewSize {
    return self.view.frame.size;
}

@end
