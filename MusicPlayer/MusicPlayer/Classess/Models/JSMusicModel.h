//
//  JSMusicModel.h
//  MusicPlayer
//
//  Created by ShenYj on 16/7/19.
//  Copyright © 2016年 ___ShenYJ___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MusicTypeLocal,
    MusicTypeRemote,
} MusicType;

@interface JSMusicModel : NSObject

// 图片
@property (nonatomic,copy) NSString *image;
// 歌词
@property (nonatomic,copy) NSString *lrc;
// 音乐
@property (nonatomic,copy) NSString *mp3;
// 歌曲名称
@property (nonatomic,copy) NSString *name;
// 歌手名字
@property (nonatomic,copy) NSString *singer;
// 专辑名称
@property (nonatomic,copy) NSString *album;
// 类型
@property (nonatomic,assign) MusicType type;

// 对象方法
- (instancetype)initWithDict:(NSDictionary *)dict;
// 类方法
+ (instancetype)musicWithDict:(NSDictionary *)dict;
// 返回存放模型的数组
+ (NSArray *)loadMusicListWithFileName:(NSString *)fileName;

@end
