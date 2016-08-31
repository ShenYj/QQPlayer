//
//  JSMusciManager.h
//  MusicPlayer
//
//  Created by ShenYj on 16/7/19.
//  Copyright © 2016年 ___ShenYJ___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface JSMusciManager : NSObject

// 总时长
@property (nonatomic,assign) NSTimeInterval duration;
// 当前时间
@property (nonatomic,assign) NSTimeInterval currentTime;
// 音乐播放器
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;

+ (instancetype)sharedMusicManager;

// 播放音乐
- (void)playMusicWithFileName:(NSString *)fileName;
// 暂停音乐
- (void)pauseMusic;



@end
