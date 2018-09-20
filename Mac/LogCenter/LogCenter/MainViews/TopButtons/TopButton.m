//
//  TopButton.m
//  LogCenter
//
//  Created by Assassin on 2018/9/12.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import "TopButton.h"

@implementation TopButton

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        _textAlignment = NSTextAlignmentCenter;
        [self updateButtonSetting];
        
    }
    return self;
}

- (void)awakeFromNib
{
    _textAlignment = NSTextAlignmentCenter;
    [self updateButtonSetting];
}

//button base setting
- (void)updateButtonSetting {
     [self.layer setBackgroundColor:[NSColor clearColor].CGColor];
    [self setNormalState];
}


-(void)setButtonType:(NSButtonType)aType
{
    _buttonType = aType;
    [super setButtonType:aType];
}

- (BOOL)isOpaque
{
    return NO;
}

- (void)setNormalImage:(NSImage *)img {
    if(_normalImage != img)
    {
        _normalImage = img;
        [self setImage:_normalImage];
    }
}

- (void)setHoverImage:(NSImage *)img {
    if(_hoverImage != img)
    {
        _hoverImage = img;
    }
}

#pragma mark -mouse
- (void)mouseExited:(NSEvent *)event
{
    [self setNormalState];
    [[self layer] setBorderWidth:0];
}

- (void)mouseEntered:(NSEvent *)event
{
    [self setHoverState];
}

- (void)setNormalState
{
    if (_normalImage)
    {
        [self setImage:_normalImage];
    }
    
    if ([[self layer] borderColor] && [[self layer] borderWidth]) {
        [[self layer] setBorderWidth:0];
    }
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@""];
    [self setAttributedTitle:str];
}

- (void)setHoverState
{
    if (!self.isEnabled)
    {
        return;
    }
    
    if(!_normalImage)
    {
        _normalImage = [self image];
    }
    
    if (_hoverImage)
    {
        [self setImage:_hoverImage];
    }

    [[self layer] setBorderColor:[NSColor grayColor].CGColor];
    [[self layer] setBorderWidth:0.5];
    
    if(_attributedHoverTitle)
    {
        [self setAttributedTitle:_attributedHoverTitle];
    }
}



@end
