//
//  JSColorLabel.m
//  MusicPlayer
//
//  Created by ShenYj on 16/7/21.
//  Copyright © 2016年 ___ShenYJ___. All rights reserved.
//

#import "JSColorLabel.h"

@implementation JSColorLabel

- (void)drawRect:(CGRect)rect {
    // 调用父类方法: 将Label上的文字绘制上
    [super drawRect:rect];
    
    // 设置填充色
    // [[UIColor greenColor] setStroke]; // 描边
    [[UIColor greenColor] setFill]; // 填充
    
    // 设置填充色的区域 (默认文字为白色,填充后为绿色,只需要根据当前歌词显示进度来改变填充的宽度,其他不变)
    rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width *self.progress, rect.size.height);
    
    // 渲染
    // 在某个区域中使用混合模式进行填充
    /*
        kCGBlendModeNormal公式: R = S + D*(1 - Sa) --> 结果 = 源颜色 + 目标颜色 * (1-源颜色各透明组件的透明度)
     在这里;
            源颜色  -->  就是要绘制上去的颜色/填充色  ([[UIColor greenColor] setFill];)
            目标颜色 --> Label当前的颜色(白色和透明),上下文中已经有的颜色
     
     */
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceIn);
    
    /*              对应公式(其余是固定的):
     
        result, source, and destination colors with alpha; 
        Ra, Sa, and Da are the alpha components of these colors.
            R --> result
            S --> source
            D --> destination
     
         kCGBlendModeNormal,                 R = S + D*(1 - Sa)
         kCGBlendModeMultiply,
         kCGBlendModeScreen,
         kCGBlendModeOverlay,
         kCGBlendModeDarken,
         kCGBlendModeLighten,
         kCGBlendModeColorDodge,
         kCGBlendModeColorBurn,
         kCGBlendModeSoftLight,
         kCGBlendModeHardLight,
         kCGBlendModeDifference,
         kCGBlendModeExclusion,
         kCGBlendModeHue,
         kCGBlendModeSaturation,
         kCGBlendModeColor,
         kCGBlendModeLuminosity,
     
     
         kCGBlendModeClear,                   R = 0
         kCGBlendModeCopy,                    R = S
         kCGBlendModeSourceIn,                R = S*Da
         kCGBlendModeSourceOut,               R = S*(1 - Da)
         kCGBlendModeSourceAtop,              R = S*Da + D*(1 - Sa)
         kCGBlendModeDestinationOver,         R = S*(1 - Da) + D
         kCGBlendModeDestinationIn,           R = D*Sa
         kCGBlendModeDestinationOut,          R = D*(1 - Sa)
         kCGBlendModeDestinationAtop,         R = S*(1 - Da) + D*Sa
         kCGBlendModeXOR,                     R = S*(1 - Da) + D*(1 - Sa)
         kCGBlendModePlusDarker,              R = MAX(0, (1 - D) + (1 - S))
         kCGBlendModePlusLighter              R = MIN(1, S + D)
     */
}

// 更新进度的时候执行重绘
- (void)setProgress:(CGFloat)progress {
    
    _progress = progress;
    // 执行重绘
    [self setNeedsDisplay];
}

@end
