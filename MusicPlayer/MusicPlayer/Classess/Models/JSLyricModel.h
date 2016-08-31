//
//  JSLyricModel.h
//  MusicPlayer
//
//  Created by ShenYj on 16/7/20.
//  Copyright © 2016年 ___ShenYJ___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSLyricModel : NSObject

// 该句歌词的初始时间
@property (nonatomic,assign) NSTimeInterval initialTime;
// 该句歌词
@property (nonatomic,copy) NSString *content;


@end
