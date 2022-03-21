//
//  JSLyricManager.m
//  MusicPlayer
//
//  Created by ShenYj on 16/7/20.
//  Copyright © 2016年 ___ShenYJ___. All rights reserved.
//

#import "JSLyricManager.h"
#import "NSDateFormatter+Shared.h"
#import "JSLyricModel.h"

@implementation JSLyricManager

+ (NSArray<JSLyricModel *> *)parserLyricWithFileName:(NSString *)fileName {
    
    // 取出歌词字符串
    NSString *filePath = [[NSBundle mainBundle]pathForResource:fileName ofType:nil];
    NSString *lyricStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    // 分隔字符串
    NSArray *lyricArr = [lyricStr componentsSeparatedByString:@"\n"];
    
    /*      正则表达式过滤字符串:
     [00:19.00]曲：河合奈保子 词：向雪怀
     [02:19.00][00:23.00]仍然倚在失眠夜望天边星宿
     */
    NSString *regularExpressionString = @"\\[[0-9]{2}:[0-9]{2}.[0-9]{2}\\]";
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regularExpressionString options:0 error:nil];
    
    // 存放歌词对象的临时可变数组
    NSMutableArray *tempMarr = [NSMutableArray array];
    
    //遍历歌词数组,取出每一句歌词
    for (NSString *element in lyricArr) {
        
        // 正则表达式遍历
        NSArray<NSTextCheckingResult *> *textCheckingResult = [regularExpression matchesInString:element options:0 range:NSMakeRange(0, element.length)];
        
        // 2.截取歌词内容
        NSTextCheckingResult *lastTimeString = textCheckingResult.lastObject;// 取出得到数组中的最后一个时间元素,用来获取range
        
        // 截取歌词 (一句歌词可能会有多个时间戳,取到最后一个时间戳,用自己的local + length才是全部时间部分的长度,也就得到了后面歌词的索引)
        NSString *lyricContent = [element substringFromIndex:lastTimeString.range.length + lastTimeString.range.location];
        
        // 同一句歌词可能多处显示,所以返回值是一个数组,遍历取出每一个起始时间字符串
        for (NSTextCheckingResult *result in textCheckingResult) {

            // 1. 截取时间字符串
            NSString *lyricSubString = [element substringWithRange:NSMakeRange(result.range.location, result.range.length)];
            
            // 截取玩后设置每一句歌词的起始时间
            NSTimeInterval currentLyricInitialTime = [self timeIntervalWithTimeString:lyricSubString];
            
            // 创建歌词模型
            JSLyricModel *model = [[JSLyricModel alloc]init];
            // 模型赋值
            model.initialTime = currentLyricInitialTime;// 给歌词模型的歌词初试时间赋值
            model.content = lyricContent;               // 给歌词模型的歌词内容赋值
            
            // 添加到临时可变数组
            [tempMarr addObject:model];
        }
    }
    
    // 歌词起始时间排序
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"initialTime" ascending:YES];
    NSArray *lyricModelArr = [tempMarr sortedArrayUsingDescriptors:@[descriptor]];
    
    // 进行解析
    return lyricModelArr;
}

// 将时间字符串转换为NSTimerInterval类型,方便外面直接判断
+ (NSTimeInterval)timeIntervalWithTimeString:(NSString *)timeString {
    
    // 时间字符串 --> 日期对象 NSDate  --> 计算对应的时间间隔
    NSDateFormatter *dateFormatter = [NSDateFormatter sharedManager];
    // 设置格式
    dateFormatter.dateFormat = @"[mm:ss.SS]";
    // 创建初始时间对象 用来计算时间间隔
    NSDate *initialDate = [dateFormatter dateFromString:@"[00:00.00]"];
    // 将字符串转换为NSDate
    NSDate *targetDate = [dateFormatter dateFromString:timeString];
    
    // 计算时间间隔
    return [targetDate timeIntervalSinceDate:initialDate];
}


@end
