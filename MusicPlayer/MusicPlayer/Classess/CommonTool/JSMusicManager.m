//
//  JSMusicManager.m
//  MusicPlayer
//
//  Created by ShenYj on 16/7/19.
//  Copyright © 2016年 ___ShenYJ___. All rights reserved.
//

#import "JSMusicManager.h"
#import <UIKit/UIKit.h>

static JSMusicManager *_instanceType = nil;
NSString * const kAudioPlayerStatusChangedByAudioSessionInterruption = @"kAudioPlayerStatusChangedByAudioSessionInterruption";

@interface JSMusicManager ()

@property (nonatomic,copy) NSString *currentMusicName;

@end

@implementation JSMusicManager

+ (instancetype)sharedMusicManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instanceType = [[JSMusicManager alloc] init];
    });
    return _instanceType;
}

// 设置音频会话只需要设置一次就可以了,因为上面创建单例时调用了alloc]init]方法,所以设置类型这里写在了init初始方法里
- (instancetype)init {
    
    self = [super init];
    if (self) {
        // 后台运行音乐 需要设置音频会话的类型
        AVAudioSession *session = [AVAudioSession sharedInstance];
        /*
         enum {
         kAudioSessionCategory_AmbientSound              = 'ambi',
         kAudioSessionCategory_SoloAmbientSound          = 'solo',
         kAudioSessionCategory_MediaPlayback             = 'medi',  --> 后台播放
         kAudioSessionCategory_RecordAudio               = 'reca',
         kAudioSessionCategory_PlayAndRecord             = 'plar',
         kAudioSessionCategory_AudioProcessing           = 'proc'
         };
         */
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        // 开启远程控制器后,才会后台自动切歌播放(开启线控,还能支持耳机上的线控操作)
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        
#pragma mark -- 监听中断通知
        // 监听事件中断通知
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(audioSessionInterruptionNotification:)
                                                     name: AVAudioSessionInterruptionNotification
                                                   object: nil];
        
        // 其他App占用/解除占用AVAudioSession通知
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(audioSessionSilenceSecondaryAudioHintNotification:)
                                                     name: AVAudioSessionSilenceSecondaryAudioHintNotification
                                                   object: nil];
        
        // 路线改变通知(如,扬声器切换为耳机.也就是耳机插入设备)
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(audioSessionRouteChangeNotification:)
                                                     name: AVAudioSessionRouteChangeNotification
                                                   object: nil];
    }
    return self;
}

// 路线改变通知(如,扬声器切换为耳机.也就是耳机插入设备)
- (void)audioSessionRouteChangeNotification:(NSNotification *)notification {
    NSLog(@" %s -- %@", __func__, notification.userInfo);
}

// 其他App占用/解除占用AVAudioSession通知
- (void)audioSessionSilenceSecondaryAudioHintNotification:(NSNotification *)notification {
    NSLog(@" %s -- %@", __func__, notification.userInfo);
}

// 监听中断通知调用的方法
- (void)audioSessionInterruptionNotification:(NSNotification *)notification {
    
    /*
         监听到的中断事件通知, AVAudioSessionInterruptionType
     
         typedef NS_ENUM(NSUInteger, AVAudioSessionInterruptionType)
         {
             AVAudioSessionInterruptionTypeBegan = 1,  中断开始
             AVAudioSessionInterruptionTypeEnded = 0,  中断结束
         }
     */
    
    NSLog(@"[%s] -- %@", __func__, notification.userInfo);
    int interruptionTypeKey = [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    switch (interruptionTypeKey) {
        case AVAudioSessionInterruptionTypeBegan:   // 中断开始
            NSLog(@"中断开始 --> 暂停播放");
            [self.audioPlayer pause];               // 暂停播放
            break;
        case AVAudioSessionInterruptionTypeEnded:   // 中断结束
        {
            int interruptionOptionType = [notification.userInfo[AVAudioSessionInterruptionOptionKey] intValue];
            if (interruptionOptionType == AVAudioSessionInterruptionOptionShouldResume) {
                NSLog(@"中断结束 --> 继续播放");
                [self.audioPlayer play];            // 继续播放
            }
            else {
                NSLog(@"另一个音频会话的中断已结束，但应用程序此时不满足恢复其音频会话");
            }
        }
            break;
        default:
            break;
    }
    
    // 通知
    [[NSNotificationCenter defaultCenter] postNotificationName: kAudioPlayerStatusChangedByAudioSessionInterruption
                                                        object: nil
                                                      userInfo: notification.userInfo];
}

// 播放音乐
- (void)playMusicWithFileName:(NSString *)fileName {
    
    // 判断当前歌曲是否名称相同 (地址比较,效率要比字符串比较高)
    if (self.currentMusicName != fileName ) { // 播放
        
        // 获取路径
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        // 创建播放器
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
        // 准备播放
        [self.audioPlayer prepareToPlay];
        // 记录当前播放歌曲名称
        self.currentMusicName = fileName;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 播放音乐(名称一致:继续播放)
        [self.audioPlayer play];
    });
}

// 暂停音乐
- (void)pauseMusic {
    [self.audioPlayer pause];
}

#pragma mark -- setter&getter

// 获取歌曲时长
- (NSTimeInterval)duration {
    return self.audioPlayer.duration;
}
// 获取当前时间
- (NSTimeInterval)currentTime {
    return self.audioPlayer.currentTime;
}
// 设置当前进度
- (void)setCurrentTime:(NSTimeInterval)currentTime {
    self.audioPlayer.currentTime = currentTime;
}

@end
