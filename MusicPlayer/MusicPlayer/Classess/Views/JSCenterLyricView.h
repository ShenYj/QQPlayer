//
//  JSCenterLyricView.h
//  MusicPlayer
//
//  Created by ShenYj on 16/7/21.
//  Copyright © 2016年 ___ShenYJ___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSCenterLyricView : UIView
// 滚动时偏移量占屏幕的比例
@property (nonatomic,copy) void(^scrollBlock)(CGFloat offSetPercent);
// 当前歌曲的歌词模型数组
@property (nonatomic,strong) NSArray *lyricModelArray;
// 当前歌词索引
@property (nonatomic,assign) NSInteger currentLyricIndex;
// 当前歌词的进度
@property (nonatomic,assign) CGFloat currentLyricProgress;

@end
