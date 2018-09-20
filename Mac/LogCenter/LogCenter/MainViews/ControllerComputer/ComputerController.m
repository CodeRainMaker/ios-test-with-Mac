//
//  ComputerController.m
//  LogCenter
//
//  Created by Assassin on 2018/9/14.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "ComputerController.h"
#import "AnimationBaseView.h"
#import "SystemNotification.h"

@interface ComputerController ()

@property (weak) IBOutlet NSView *showView;

@property(nonatomic,strong)AnimationBaseView *cpuView;
@property(nonatomic,strong)AnimationBaseView *memoryView;
@property(nonatomic,strong)AnimationBaseView *fpsView;
@property(nonatomic,strong)AnimationBaseView *netView;

@property(nonatomic,strong)NSView *mainInfoView;

@property(nonatomic,strong)NSImageView *phoneImageView;
//mainInfo
@property(nonatomic,strong)NSText *cpuText;
@property(nonatomic,strong)NSText *mText;
@property(nonatomic,strong)NSText *nameText;
@property(nonatomic,strong)NSText *systemText;

@end

@implementation ComputerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self viewBaseSetting];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataInfoNotification:) name:KSystemNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    
}

//基本设置图形
- (void)viewBaseSetting {
    _showView.translatesAutoresizingMaskIntoConstraints = NO;
    NSView *mainView = _showView;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainView)]];
    _showView.wantsLayer = YES;
    [_showView.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    
    _cpuView = [[AnimationBaseView alloc] initWithType:BaseViewTypeSquare];
    [_cpuView setTopTitleStr:@"CPU"];
    _cpuView.wantsLayer = YES;
    _memoryView = [[AnimationBaseView alloc] initWithType:BaseViewTypeCircle];
    [_memoryView setTopTitleStr:@"内存"];
    _memoryView.wantsLayer = YES;
    _fpsView = [[AnimationBaseView alloc] initWithType:BaseViewTypeCircleHalf];
    [_fpsView setTopTitleStr:@"FPS"];
    _fpsView.wantsLayer = YES;
    _netView = [[AnimationBaseView alloc] initWithType:BaseViewTypeCircleWifi];
    [_netView setTopTitleStr:@"网络"];
    _netView.wantsLayer = YES;
    
    _mainInfoView = [NSView new];
    _mainInfoView.wantsLayer = YES;
    
    
    [_showView addSubview:_cpuView];
    [_showView addSubview:_memoryView];
    [_showView addSubview:_fpsView];
    [_showView addSubview:_netView];
    [_showView addSubview:_mainInfoView];
    
    _cpuView.shadow = [NSShadow new];
    _cpuView.layer.shadowOffset = CGSizeMake(0.8, 0.8);
    _cpuView.layer.shadowColor = [NSColor lightGrayColor].CGColor;
    _cpuView.layer.shadowRadius = 14;
    _memoryView.shadow = [NSShadow new];
    _memoryView.layer.shadowOffset = CGSizeMake(0.8, 0.8);
    _memoryView.layer.shadowColor = [NSColor lightGrayColor].CGColor;
    _memoryView.layer.shadowRadius = 14;
    _fpsView.shadow = [NSShadow new];
    _fpsView.layer.shadowOffset = CGSizeMake(0.8, 0.8);
    _fpsView.layer.shadowColor = [NSColor lightGrayColor].CGColor;
    _fpsView.layer.shadowRadius = 14;
    _netView.shadow = [NSShadow new];
    _netView.layer.shadowOffset = CGSizeMake(0.8, 0.8);
    _netView.layer.shadowColor = [NSColor lightGrayColor].CGColor;
    _netView.layer.shadowRadius = 14;
    
    _mainInfoView.shadow = [NSShadow new];
    _mainInfoView.layer.shadowOffset = CGSizeMake(0.8, 0.8);
    _mainInfoView.layer.shadowColor = [NSColor lightGrayColor].CGColor;
    _mainInfoView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    _mainInfoView.layer.shadowRadius = 14;
    _mainInfoView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    NSView *cpuVc = _cpuView;
    NSView *memaryVc = _memoryView;
    NSView *fpsVc = _fpsView;
    NSView *netVc = _netView;
    [self.showView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[cpuVc]-280-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cpuVc)]];
    [self.showView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[memaryVc]-280-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(memaryVc)]];
    [self.showView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[fpsVc]-280-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(fpsVc)]];
    [self.showView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[netVc]-280-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(netVc)]];
    [self.showView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[cpuVc]-10-[memaryVc(cpuVc)]-10-[fpsVc(memaryVc)]-10-[netVc(fpsVc)]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cpuVc,memaryVc,fpsVc,netVc)]];
    
    [self.showView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-18-[_mainInfoView]-18-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mainInfoView)]];
    [self.showView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[cpuVc]-10-[_mainInfoView]-18-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cpuVc,_mainInfoView)]];
    
    [self setMainInfoViewSubs];
}

- (void)setMainInfoViewSubs {
    _phoneImageView = [NSImageView new];
    NSImage *image = [NSImage imageNamed:@"icon_phone"];
    _phoneImageView.image = image;
    _phoneImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _cpuText = [self getDefultText];
    _cpuText.string = @"主核: ";
    _mText = [self getDefultText];
    _mText.string = @"内存: ";
    _systemText = [self getDefultText];
    _systemText.string = @"系统: ";
    _nameText = [self getDefultText];
    _nameText.string = @"手机: ";
    
    [_mainInfoView addSubview:_phoneImageView];
    [_mainInfoView addSubview:_cpuText];
    [_mainInfoView addSubview:_mText];
    [_mainInfoView addSubview:_systemText];
    [_mainInfoView addSubview:_nameText];
    
    [_mainInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_phoneImageView(100)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_phoneImageView)]];
    [_mainInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_phoneImageView(100)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_phoneImageView)]];
    
    [_mainInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_phoneImageView]-10-[_cpuText(180)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_phoneImageView,_cpuText)]];
    [_mainInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[_cpuText(50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cpuText)]];
    
    [_mainInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_phoneImageView]-10-[_mText(180)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_phoneImageView,_mText)]];
    [_mainInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_cpuText]-8-[_mText(50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cpuText,_mText)]];
    
    [_mainInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_phoneImageView]-10-[_systemText(180)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_phoneImageView,_systemText)]];
    [_mainInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_mText]-8-[_systemText(50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_mText,_systemText)]];
    
    [_mainInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_phoneImageView]-10-[_nameText(180)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_phoneImageView,_nameText)]];
    [_mainInfoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_systemText]-8-[_nameText(50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_systemText,_nameText)]];
    
   
}


#pragma mark --dataInfo notfification
- (void)dataInfoNotification:(NSNotification*)nofi {
    NSDictionary *dic =nofi.userInfo;
    NSString *fpsinfo = [dic valueForKey:FPS_KEY];
    if (fpsinfo) {
        [_fpsView setHalfData:fpsinfo];
    }else if ([dic valueForKey:@"cpuNums"]){
        NSString *cpuNums = [dic valueForKey:@"cpuNums"];
//        NSString *cpuNumsV = [dic valueForKey:@"cpuNumsV"];//多线程数
        NSString *phoneName = [dic valueForKey:@"phoneName"];
        NSString *systemVersion = [dic valueForKey:@"systemVersion"];
        NSString *memoryTotal = [dic valueForKey:@"memoryTotal"];
        if (cpuNums.length > 0) {
            _cpuText.string = [NSString stringWithFormat:@"主核:%@",cpuNums];
        }
        if (systemVersion.length > 0) {
            _systemText.string = [NSString stringWithFormat:@"系统:%@",systemVersion];
        }
        if (phoneName.length > 0) {
            _nameText.string = [NSString stringWithFormat:@"手机:%@",phoneName];
        }
        if (memoryTotal.length > 0) {
            _mText.string = [NSString stringWithFormat:@"内存:%@G",memoryTotal];
        }
        
        
    }else if ([dic valueForKey:@"appUse"]) {
        NSNumber *appUse = [dic valueForKey:@"appUse"];
        NSNumber *cpuUse = [dic valueForKey:@"cpuUse"];
        NSNumber *appUseM = [dic valueForKey:@"appUseM"];
        NSNumber *sysUseM = [dic valueForKey:@"sysUseM"];
        NSNumber *appUseMAll = [dic valueForKey:@"appUseMAll"];
        if (appUse) {
            [_cpuView setSquartData:[NSString stringWithFormat:@"%.1lf",[appUse doubleValue]]];
        }
        if (cpuUse) {
            [_cpuView setSquartData2:[NSString stringWithFormat:@"%.1lf",[cpuUse doubleValue]]];
        }
        if (appUseM && appUseMAll) {
            NSArray *array = [NSArray arrayWithObjects:appUseM,appUseMAll, nil];
            [_memoryView setCircleData:array];
        }
        if (sysUseM) {
            [_memoryView setCircleDataToOther:sysUseM];
        }
    }
}

#pragma mark --lazy class
- (NSText*)getDefultText {
    NSText *text = [NSText new];
    text.editable = NO;
    text.translatesAutoresizingMaskIntoConstraints = NO;
    text.wantsLayer = YES;
    text.drawsBackground = YES;
    text.shadow = [NSShadow new];
    text.layer.shadowOffset = CGSizeMake(0.8, 0.8);
    text.font = [NSFont systemFontOfSize:21];
    text.textColor = [NSColor lightGrayColor];
    text.layer.shadowColor = [NSColor lightGrayColor].CGColor;
    text.layer.shadowRadius = 14;
    
    return text;
}


@end
