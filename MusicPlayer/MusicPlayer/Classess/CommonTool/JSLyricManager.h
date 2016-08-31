//
//  JSLyricManager.h
//  MusicPlayer
//
//  Created by ShenYj on 16/7/20.
//  Copyright © 2016年 ___ShenYJ___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSLyricModel.h"

@interface JSLyricManager : NSObject

// 返回歌词数组: 存放一首歌曲的全部歌词信息
+ (NSArray <JSLyricModel *> *)parserLyricWithFileName:(NSString *)fileName;

@end
