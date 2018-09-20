//
//  TopButton.h
//  LogCenter
//
//  Created by Assassin on 2018/9/12.
//  Copyright © 2018年 PeachRain. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TopButton : NSButton
{
    NSButtonType _buttonType;
}

@property (nonatomic) NSTextAlignment textAlignment;

@property (nonatomic,strong) NSImage *hoverImage;
@property (nonatomic,strong) NSImage *normalImage;

@property(nonatomic, retain) NSAttributedString *attributedHoverTitle;

- (void)setNormalImage:(NSImage *)img;

@end
