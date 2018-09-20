//
//  AnimationBaseView.m
//  LogCenter
//
//  Created by Assassin on 2018/9/14.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "AnimationBaseView.h"
#import <QuartzCore/QuartzCore.h>
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

@interface AnimationBaseView()

@property(nonatomic,strong)NSView *subView;//容器

@property(nonatomic,strong)NSText *topTitle;//头部标题

@property(nonatomic,strong)NSText *infoTitle;
@property(nonatomic,strong)NSText *infoTitleAll;

@property(nonatomic,strong)NSView *coverView;

@property(nonatomic,strong)NSView *coverView2;

//square
@property(nonatomic,strong)NSImageView *bottomView;//底部背景
@property(nonatomic,strong)NSLayoutConstraint *widthConstraint;
@property(nonatomic,strong)NSLayoutConstraint *widthConstraint2;

//circle
@property(nonatomic,strong)CAShapeLayer *waterLayer;
@property(nonatomic,strong)CAShapeLayer *sinLayer;
@property(nonatomic,strong)CAShapeLayer *cosLayer;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)CGFloat phase;

//halfCircle
@property(nonatomic,strong)NSText *percentText;

@end

@implementation AnimationBaseView

- (instancetype)initWithType:(BaseViewType)type
{
    self = [super init];
    if (self) {
        [self initBaseViewWithType:type];
        _phase = 0;
    }
    return self;
}

//设置基本图形
- (void)setContentView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    _subView = [NSView new];
    _subView.wantsLayer = YES;
    _subView.translatesAutoresizingMaskIntoConstraints = NO;
    _subView.layer.shadowOffset = CGSizeMake(0.8, 0.5);
    _subView.layer.shadowColor = [NSColor blackColor].CGColor;
    _subView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    _subView.layer.shadowOpacity = 1;
    _topTitle = [NSText new];
    _topTitle.wantsLayer = YES;
    _topTitle.layer.shadowOffset = CGSizeMake(0.8, 0.5);
    _topTitle.layer.shadowColor = [NSColor grayColor].CGColor;
    _topTitle.layer.shadowOpacity = 0.8;
    _topTitle.drawsBackground = NO;
    _topTitle.font = [NSFont boldSystemFontOfSize:20];
    _topTitle.alignment = NSTextAlignmentCenter;
    _topTitle.translatesAutoresizingMaskIntoConstraints = NO;
    _topTitle.editable = NO;
    [self addSubview:_subView];
    [self addSubview:_topTitle];
    NSText *textView = _topTitle;
    NSView *subVc = _subView;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-38-[subVc]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(subVc)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[subVc]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(subVc)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[textView(26)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[textView]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textView)]];
}

//开始显示
- (void)startShow {
    
}

#pragma mark ---set

- (void)setTopTitleStr:(NSString*)str {
    
    _topTitle.string = str;
}


#pragma mark ---BaseViewType

- (void)initBaseViewWithType:(BaseViewType)type {
    [self setContentView];
    switch (type) {
        case BaseViewTypeSquare:
            [self squareViewSetting];
            break;
        case BaseViewTypeCircle:
            [self circleViewSetting];
            break;
        case BaseViewTypeCircleHalf:
            [self halfCircleSetting];
            break;
        case BaseViewTypeCircleWifi:
            [self WifiSetting];
            break;
        default:
            break;
    }
}

- (void)setInfoText {
    _infoTitle = [NSText new];
    _infoTitle.wantsLayer = YES;
    _infoTitle.drawsBackground = NO;
    _infoTitle.textColor = [NSColor lightGrayColor];
    _infoTitle.font = [NSFont systemFontOfSize:14];
    _infoTitle.alignment = NSTextAlignmentCenter;
    _infoTitle.translatesAutoresizingMaskIntoConstraints = NO;
    _infoTitle.editable = NO;
    _infoTitle.string = @"数据";
    
    [_subView addSubview:_infoTitle];
    [_subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_infoTitle(26)]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_infoTitle)]];
    [_subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_infoTitle]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_infoTitle)]];
}

#pragma mark ---BaseViewType---Square
- (void)squareViewSetting {
    
    [self setInfoText];
    
    //bottom
    NSImage *image = [NSImage imageNamed:@"yongjin_Graph"];
    _bottomView = [[NSImageView alloc] init];
    _bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    _bottomView.imageScaling = NSImageScaleAxesIndependently;
    [_bottomView setImage:image];
    [_subView addSubview:_bottomView];
    [_subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_bottomView]-10-[_infoTitle]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bottomView,_infoTitle)]];
    [_subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_bottomView]-40-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bottomView)]];
    
    //cover
    _coverView2 = [NSView new];
    _coverView2.wantsLayer = YES;
    _coverView2.translatesAutoresizingMaskIntoConstraints = NO;
    _coverView2.layer.shadowOffset = CGSizeMake(0.8, 0.5);
    _coverView2.layer.shadowColor = [NSColor grayColor].CGColor;
    _coverView2.layer.backgroundColor = [NSColor yellowColor].CGColor;
    _coverView2.layer.shadowOpacity = 1;
    _coverView2.alphaValue = 0.6;
    [_bottomView addSubview:_coverView2];
    [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_coverView2]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_coverView2)]];
    [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_coverView2]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_coverView2)]];
    _widthConstraint2 = [NSLayoutConstraint constraintWithItem:_coverView2 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeBottom multiplier:1 constant:-180];
    [_bottomView addConstraint:_widthConstraint2];
    
    
    _coverView = [NSView new];
    _coverView.wantsLayer = YES;
    _coverView.translatesAutoresizingMaskIntoConstraints = NO;
    _coverView.layer.shadowOffset = CGSizeMake(0.8, 0.5);
    _coverView.layer.shadowColor = [NSColor grayColor].CGColor;
    _coverView.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    _coverView.layer.shadowOpacity = 1;
//    _coverView.alphaValue = 0.6;
    [_bottomView addSubview:_coverView];
    [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_coverView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_coverView)]];
    [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_coverView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_coverView)]];
    _widthConstraint = [NSLayoutConstraint constraintWithItem:_coverView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bottomView attribute:NSLayoutAttributeBottom multiplier:1 constant:-180];
    [_bottomView addConstraint:_widthConstraint];
    
    
    
    _infoTitleAll = [NSText new];
    _infoTitleAll.wantsLayer = YES;
    _infoTitleAll.drawsBackground = NO;
    _infoTitleAll.textColor = [NSColor lightGrayColor];
    _infoTitleAll.font = [NSFont systemFontOfSize:14];
    _infoTitleAll.alignment = NSTextAlignmentCenter;
    _infoTitleAll.translatesAutoresizingMaskIntoConstraints = NO;
    _infoTitleAll.editable = NO;
    _infoTitleAll.string = @"All";
    
    [_bottomView addSubview:_infoTitleAll];
    [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_infoTitleAll(16)]-2-[_coverView2]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_infoTitleAll,_coverView2)]];
    [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_infoTitleAll]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_infoTitleAll)]];
    
}

- (void)setSquartData:(NSString*)data {
    CGFloat h = _bottomView.bounds.size.height;
    CGFloat preH = [data floatValue]/100;
    CGFloat newH = preH * h;
    CGFloat orginH = _coverView.frame.origin.y;
    
    CGFloat show = orginH - newH;
    _widthConstraint.constant = show;
    
    _infoTitle.string = [NSString stringWithFormat:@"%%%@",data];
}

- (void)setSquartData2:(NSString*)data {
    CGFloat h = _bottomView.bounds.size.height;
    CGFloat preH = [data floatValue];
    CGFloat newH = preH * h;
    CGFloat orginH = _coverView.frame.origin.y;
    
    CGFloat show = orginH - newH;
    _widthConstraint2.constant = show;
}

#pragma mark ---BaseViewType---circle
- (void)circleViewSetting {
    [self setupSubViews];
    [self setupLayers];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updataDisplay) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)setupSubViews {
    [self setInfoText];
    
    [_subView addSubview:self.coverView];
    self.coverView.wantsLayer = YES;
    self.coverView.layer.cornerRadius = 90;
    self.coverView.layer.borderColor = [NSColor lightGrayColor].CGColor;
    self.coverView.layer.borderWidth = 5;
    self.coverView.layer.masksToBounds = YES;
    
    NSView *cover = self.coverView;
    [_subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[cover(180)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cover)]];
    [_subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cover(180)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cover)]];
    [_subView addConstraint:[NSLayoutConstraint constraintWithItem:cover attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_subView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
}

- (void)setupLayers {
    _sinLayer = [CAShapeLayer layer];
    _sinLayer.backgroundColor = [NSColor clearColor].CGColor;
    _sinLayer.fillColor = [NSColor greenColor].CGColor;
    _sinLayer.frame = self.coverView.bounds;
    _sinLayer.position = CGPointMake(0, -100);
     self.sinLayer.opacity = 0.6;
    [self.coverView.layer addSublayer:_sinLayer];
    
    _cosLayer = [CAShapeLayer layer];
    _cosLayer.backgroundColor = [NSColor clearColor].CGColor;
    _cosLayer.fillColor = [NSColor greenColor].CGColor;
    _cosLayer.frame = self.coverView.bounds;
    _cosLayer.position = CGPointMake(0, -80);
     self.cosLayer.opacity = 0.2;
    [self.coverView.layer addSublayer:_cosLayer];
}

- (void)updataDisplay {
    self.phase += 1;
    CGPathRef path = [self quartzPath:[self createWavePathWithType]];
    self.sinLayer.path = path;

    self.cosLayer.path = path;
    
}

- (NSBezierPath *)createWavePathWithType {
    NSBezierPath *path = [NSBezierPath new];
    CGFloat startOffY = 5.0 * sinf(self.phase * M_PI * 2.0 / self.coverView.bounds.size.width);
    CGFloat orignOffY = 0;
    
    CGFloat w = self.bounds.size.width;
    CGFloat x = 0;
    [path moveToPoint:CGPointMake(0, self.bounds.size.height - startOffY)];
    while (x <= w+1) {
        orignOffY = 5.0 * sinf(2 * M_PI/ self.bounds.size.width * x + self.phase * M_PI * 2 / self.bounds.size.width) + self.bounds.size.height * 0.5;
        [path lineToPoint:CGPointMake(x, self.bounds.size.height - orignOffY)];
        x+=1;
    }
    
    [path lineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height - orignOffY)];
    [path lineToPoint:CGPointMake(self.bounds.size.width, 0)];
    [path lineToPoint:CGPointMake(0, 0)];
    [path lineToPoint:CGPointMake(0, self.bounds.size.height - startOffY)];
    [path closePath];
    
    return path;
}

- (NSBezierPath *)createWavePathWithTypeCos {
    NSBezierPath *path = [NSBezierPath new];
    CGFloat startOffY = 5.0 * sinf(self.phase * M_PI * 2.0 / self.coverView.bounds.size.width);
    CGFloat orignOffY = 0;
    
    CGFloat w = self.bounds.size.width;
    CGFloat x = 0;
    [path moveToPoint:CGPointMake(0, self.bounds.size.height - startOffY)];
    while (x <= w+1) {
        orignOffY = 5.0 * cosf(2 * M_PI/ self.bounds.size.width * x + self.phase * M_PI * 2 / self.bounds.size.width) + self.bounds.size.height * 0.5;
        [path lineToPoint:CGPointMake(x, self.bounds.size.height - orignOffY)];
        x+=1;
    }
    
    [path lineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height - orignOffY)];
    [path lineToPoint:CGPointMake(self.bounds.size.width, 0)];
    [path lineToPoint:CGPointMake(0, 0)];
    [path lineToPoint:CGPointMake(0, self.bounds.size.height - startOffY)];
    [path closePath];
    
    return path;
}

- (CGPathRef)quartzPath:(NSBezierPath*)bpath
{
    int i, numElements;
    
    // Need to begin a path here.
    CGPathRef           immutablePath = NULL;
    
    // Then draw the path elements.
    numElements = [bpath elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
        BOOL                didClosePath = YES;
        
        for (i = 0; i < numElements; i++)
        {
            switch ([bpath elementAtIndex:i associatedPoints:points])
            {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
                    
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;
                    
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                          points[1].x, points[1].y,
                                          points[2].x, points[2].y);
                    didClosePath = NO;
                    break;
                    
                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }
        if (!didClosePath)
            CGPathCloseSubpath(path);
        
        immutablePath = CGPathCreateCopy(path);
        CGPathRelease(path);
    }
    
    return immutablePath;
}

- (void)setCircleData:(NSArray*)data {
    if (data.count < 2) {
        return;
    }
    double infoPre = [data.firstObject doubleValue];
    infoPre = (1 - infoPre) * 180;
    double infoM   = [data.lastObject doubleValue];
    NSString *infoMStr = [NSString stringWithFormat:@"%.1lf(M)",infoM];
    if (infoM/1000 > 1) {
        infoMStr = [NSString stringWithFormat:@"%.1lf(G)",infoM/1000];
    }
    _infoTitle.string = infoMStr;
    
    int pre = _sinLayer.position.y - infoPre;
    if (abs(pre) > 10) {
        _sinLayer.position = CGPointMake(0, -infoPre);
    }
}

- (void)setCircleDataToOther:(NSNumber*)data {
    double sysNum = [data doubleValue];
    double infoPre = (1 - sysNum) * 180;
    _cosLayer.position = CGPointMake(0, -infoPre);
}

- (void)stop {
    [_timer invalidate];
    _timer = nil;
}



#pragma mark ---BaseViewType---half circle

//MARK:******* 圆弧角度 *******
CGFloat hCircularStartAngle = -M_PI - M_PI_4;
CGFloat hCircularEndAngle = M_PI_4;
//MARK:******* 圆角度 *******
CGFloat hCircleStartAngle = -M_PI - M_PI_2;
CGFloat hCircleEndAngle = M_PI_2;


- (void)halfCircleSetting {
    [self setupSubViewsHalf];
    [self setupLayersHalf];
    
//    [self drawCircleWithPercent];
}

- (void)setupSubViewsHalf {
    [self setInfoText];
    
    [_subView addSubview:self.coverView];
    self.coverView.wantsLayer = YES;
//    self.coverView.layer.borderColor = [NSColor lightGrayColor].CGColor;
//    self.coverView.layer.borderWidth = 5;
    self.coverView.layer.masksToBounds = YES;
    self.coverView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSView *cover = self.coverView;
    [_subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[cover(180)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cover)]];
    [_subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cover(180)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cover)]];
    [_subView addConstraint:[NSLayoutConstraint constraintWithItem:cover attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_subView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    _percentText = [NSText new];
    _percentText.wantsLayer = YES;
    _percentText.drawsBackground = NO;
    _percentText.textColor = [NSColor grayColor];
    _percentText.font = [NSFont systemFontOfSize:48];
    _percentText.alignment = NSTextAlignmentCenter;
    _percentText.translatesAutoresizingMaskIntoConstraints = NO;
    _percentText.editable = NO;
    _percentText.string = @"0";
    
    [_coverView addSubview:_percentText];
    [_coverView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-67-[_percentText(46)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_percentText)]];
    [_coverView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_percentText]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_percentText)]];
}

- (void)setupLayersHalf {
    _sinLayer = [CAShapeLayer layer];
    _sinLayer.backgroundColor = [NSColor clearColor].CGColor;
    _sinLayer.fillColor = [NSColor greenColor].CGColor;
    [self.coverView.layer addSublayer:_sinLayer];
    
    _cosLayer = [CAShapeLayer layer];
    _cosLayer.backgroundColor = [NSColor clearColor].CGColor;
    _cosLayer.fillColor = [NSColor greenColor].CGColor;
    _cosLayer.frame = self.coverView.bounds;
    [self.coverView.layer addSublayer:_cosLayer];
}

- (void)drawCircleWithPercent {
    [self setupBackgroundLayerWithStrokeColor];
}

- (void)setupBackgroundLayerWithStrokeColor {
    NSBezierPath *path = [NSBezierPath new];
    CGFloat r = (180 - 10)/2;
    NSPoint point = NSMakePoint(r, r);
    [path appendBezierPathWithArcWithCenter:point radius:r startAngle:hCircularStartAngle endAngle:hCircularEndAngle clockwise:YES];
    _sinLayer.path = [self quartzPath:path];
    self.sinLayer.fillColor          = [NSColor clearColor].CGColor;
    self.sinLayer.strokeColor        = [NSColor blueColor].CGColor;
    self.sinLayer.shouldRasterize    = true;
    self.sinLayer.rasterizationScale = 2;
    self.sinLayer.lineCap            = @"round";
    self.sinLayer.position           = NSMakePoint(80,90);
    self.sinLayer.lineWidth          = 12;
}

- (void)setHalfData:(NSString*)data{
//    double preH = [data doubleValue]*100;
    _percentText.string = data;
}

#pragma mark ---BaseViewType---wifi

- (void)WifiSetting {
    [self setupSubViewsWifi];
    [self setupLayersHalf];
}

- (void)setupSubViewsWifi {
    [self setInfoText];
    
    [_subView addSubview:self.coverView];
    self.coverView.wantsLayer = YES;
    self.coverView.layer.masksToBounds = YES;
    self.coverView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSView *cover = self.coverView;
    [_subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[cover(180)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cover)]];
    [_subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cover(180)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cover)]];
    [_subView addConstraint:[NSLayoutConstraint constraintWithItem:cover attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_subView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    _percentText = [NSText new];
    _percentText.wantsLayer = YES;
    _percentText.drawsBackground = NO;
    _percentText.textColor = [NSColor grayColor];
    _percentText.font = [NSFont systemFontOfSize:48];
    _percentText.alignment = NSTextAlignmentCenter;
    _percentText.translatesAutoresizingMaskIntoConstraints = NO;
    _percentText.editable = NO;
    _percentText.string = @"60";
    
    [_coverView addSubview:_percentText];
    [_coverView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-67-[_percentText(46)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_percentText)]];
    [_coverView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_percentText]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_percentText)]];
}


#pragma mark ---lazy Class

- (NSView *)coverView {
    if (!_coverView) {
        _coverView = [NSView new];
        _coverView.wantsLayer = YES;
        _coverView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return  _coverView;
}


@end
