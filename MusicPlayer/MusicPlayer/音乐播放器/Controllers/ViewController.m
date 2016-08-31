//
//  ViewController.m
//  MusicPlayer
//
//  Created by ShenYj on 16/7/19.
//  Copyright © 2016年 ___ShenYJ___. All rights reserved.
//

#import "ViewController.h"
#import "JSMusicModel.h"
#import "JSLyricModel.h"
#import "JSMusciManager.h"
#import "JSLyricManager.h"
#import "JSColorLabel.h"
#import "JSCenterLyricView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Masonry.h"


static CGFloat const kJSLyricLockedLabelHeight = 40;//锁屏界面歌词Label高度

@interface ViewController ()

#pragma mark -- 公用视图

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView; // 背景图
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;// 当前时间
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;//总时长
@property (weak, nonatomic) IBOutlet UISlider *progessSlider;//进度条
@property (weak, nonatomic) IBOutlet UIButton *playButton;//开始/暂停按钮
@property (weak, nonatomic) IBOutlet UIButton *previousButton;//上一曲按钮
@property (weak, nonatomic) IBOutlet UIButton *nextButton;//下一曲按钮

#pragma mark -- 横屏视图

@property (weak, nonatomic) IBOutlet UIImageView *horizonAlbumImageView;//横屏模式专辑
@property (weak, nonatomic) IBOutlet JSColorLabel *horizonLyricLabel;//横屏模式歌词

#pragma mark -- 竖屏视图

@property (weak, nonatomic) IBOutlet UIView *verticalCenterView; //垂直中心视图
@property (weak, nonatomic) IBOutlet JSCenterLyricView *centerLyricView; // 歌词视图容器
@property (weak, nonatomic) IBOutlet UIImageView *verticalAlbumImageView;//竖屏模式专辑图片
@property (weak, nonatomic) IBOutlet JSColorLabel *verticalLyricLabel;//竖屏模式歌词
@property (weak, nonatomic) IBOutlet UILabel *verticalAlbumLabel;//竖屏模式专辑名
@property (weak, nonatomic) IBOutlet UILabel *verticalSingerLabel;//竖屏模式歌手名

#pragma mark -- 数据容器

@property (nonatomic,strong) NSArray<JSMusicModel *> *musicList; // 歌曲模型容器
@property (nonatomic,assign) NSInteger currentMusicIndex;//当前歌曲索引
@property (nonatomic,strong) NSTimer *timer;//定时器
@property (nonatomic,strong) NSArray <JSLyricModel *>* lyricModelArray;// 歌词模型容器(存放当前歌曲的歌词)
@property (nonatomic,assign) NSInteger currentLyricIndex;// 当前歌词的索引

@end


@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

//    [self setupVerticalAlbumImageView];
    [self setupBackgroundView];
    [self setupData];
    
    
}
#pragma mark -- 设置数据
- (void)setupData{
    
    
    // 获取模型
    JSMusicModel *model = self.musicList[self.currentMusicIndex];
    // 设置背景图
    self.backgroundImageView.image = [UIImage imageNamed:model.image];

    // 设置专辑名
    self.verticalAlbumLabel.text = model.album;
    // 设置专辑图片
//    self.verticalAlbumImageView.image = [UIImage imageNamed:model.image];
    self.horizonAlbumImageView.image = [UIImage imageNamed:model.image];
    
#pragma mark -- 设置圆角图片
    self.verticalAlbumImageView.image = [self setAlbumImageWithOriginalImage:[UIImage imageNamed:model.image]];
    
    // 设置歌手
    self.verticalSingerLabel.text = model.singer;
    self.verticalSingerLabel.text = model.singer;
    // 设置歌词
    self.horizonLyricLabel.text = model.lrc;
    self.verticalLyricLabel.text = model.lrc;
    
    // 默认自动播放
    [self clickPlayButton:self.playButton];

    // 设置总时间
    self.durationLabel.text = [self timeStringWithTimeInterval:[JSMusciManager sharedMusicManager].duration];
    
    // 设置歌词 (获取歌词数据)
    self.lyricModelArray = [JSLyricManager parserLyricWithFileName:model.lrc];
    
    // 给垂滚动视图传递歌词数据
    self.centerLyricView.lyricModelArray = self.lyricModelArray;

#pragma mark -- 中心视图的渐隐效果
    
    // 设置中心视图的渐隐效果
    __weak typeof(self) weakSelf = self;
    [self.centerLyricView setScrollBlock:^(CGFloat percentAlpa) {
        
        weakSelf.verticalCenterView.alpha = percentAlpa;
    }];
    
}


#pragma mark -- 更新数据,设置当前时间封面图片旋转
- (void)updateData{
    
    // 设置当前时间
    self.currentLabel.text = [self timeStringWithTimeInterval:[JSMusciManager sharedMusicManager].currentTime];
    // 设置进度条
    self.progessSlider.value = [JSMusciManager sharedMusicManager].currentTime / [JSMusciManager sharedMusicManager].duration;
    // 设置图片旋转
    [UIView animateWithDuration:0.1 animations:^{
        
        //    self.verticalAlbumImageView.transform = CGAffineTransformRotate(self.verticalAlbumImageView.transform, M_PI_2 * 0.02);
        self.verticalAlbumImageView.layer.transform = CATransform3DRotate(self.verticalAlbumImageView.layer.transform, M_PI_2 * 0.02, 0, 0, 1);
    }];
    
    // 判断是否切换下一首歌曲
    if ( [self.currentLabel.text isEqualToString:self.durationLabel.text] ) {
        
        // 销毁定时器
        [self.timer invalidate];
        self.timer = nil;
        
        // 切换下一首 播放音乐一般都需要缓冲,手动加一个延迟
        [self clickNextButton:self.nextButton];
        
    }

    // 展示歌词
    [self updateLyric];
    // 更新锁屏UI
    [self updateLockedUI];
    
}



#pragma mark -- 更新锁屏UI
- (void)updateLockedUI{
    
    // 获取当前的歌曲
    JSMusicModel *music = self.musicList[self.currentMusicIndex];
    
    // 设置锁屏界面  设置正在播放中心
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    
    // 设置数据
    
    // 设置封面图片 (自定义方法绘制带歌词的图片)
    MPMediaItemArtwork *artworkImage = [[MPMediaItemArtwork alloc]initWithImage:[self createImage]];
    
    center.nowPlayingInfo = @{
                              MPMediaItemPropertyAlbumTitle:music.album,
                              MPMediaItemPropertyArtist:music.singer,
                              MPMediaItemPropertyArtwork:artworkImage,
                              MPMediaItemPropertyPlaybackDuration:@([JSMusciManager sharedMusicManager].duration),
                              MPMediaItemPropertyTitle:music.name,
                              MPNowPlayingInfoPropertyElapsedPlaybackTime:@([JSMusciManager sharedMusicManager].currentTime)
                              };
    
    
    ;
    
    /*          设置数据时对应的Key
     
     currently supported include 主要的
     
     // MPMediaItemPropertyAlbumTitle       专辑标题
     // MPMediaItemPropertyAlbumTrackCount  专辑歌曲数
     // MPMediaItemPropertyAlbumTrackNumber 专辑歌曲编号
     // MPMediaItemPropertyArtist           艺术家/歌手
     // MPMediaItemPropertyArtwork          封面图片 MPMediaItemArtwork类型
     // MPMediaItemPropertyComposer         作曲
     // MPMediaItemPropertyDiscCount        专辑数
     // MPMediaItemPropertyDiscNumber       专辑编号
     // MPMediaItemPropertyGenre            类型/流派
     // MPMediaItemPropertyPersistentID     唯一标识符
     // MPMediaItemPropertyPlaybackDuration 歌曲时长  NSNumber类型
     // MPMediaItemPropertyTitle            歌曲名称
     
     Additional metadata properties 额外的
     
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyElapsedPlaybackTime  当前时间 NSNumber
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyPlaybackRate
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyDefaultPlaybackRate
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyPlaybackQueueIndex
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyPlaybackQueueCount
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyChapterNumber
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyChapterCount
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyAvailableLanguageOptions   MPNowPlayingInfoLanguageOptionGroup
     MP_EXTERN NSString *const MPNowPlayingInfoPropertyCurrentLanguageOptions
     */
    
    
    
}


#pragma mark -- 当接收到远程控制事件时调用(锁屏按钮,耳机线控等)
- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    
    /*
     UIEventSubtypeNone                              = 0,
     
     // for UIEventTypeMotion, available in iPhone OS 3.0
     UIEventSubtypeMotionShake                       = 1,   摇晃事件（从iOS3.0开始支持此事件）
     
     // for UIEventTypeRemoteControl, available in iOS 4.0  从iOS4.0开始支持远程控制事件
     UIEventSubtypeRemoteControlPlay                 = 100, 播放事件【操作：停止状态下，按耳机线控中间按钮一下】
     UIEventSubtypeRemoteControlPause                = 101, 暂停事件
     UIEventSubtypeRemoteControlStop                 = 102, 停止事件
     UIEventSubtypeRemoteControlTogglePlayPause      = 103,  --> 播放或者暂停
     UIEventSubtypeRemoteControlNextTrack            = 104,  --> 下一曲
     UIEventSubtypeRemoteControlPreviousTrack        = 105,  --> 上一曲
     UIEventSubtypeRemoteControlBeginSeekingBackward = 106, 快退开始【操作：按耳机线控中间按钮三下不要松开】
     UIEventSubtypeRemoteControlEndSeekingBackward   = 107, 快退停止【操作：按耳机线控中间按钮三下到了快退的位置松开】
     UIEventSubtypeRemoteControlBeginSeekingForward  = 108, 快进开始【操作：按耳机线控中间按钮两下不要松开】
     UIEventSubtypeRemoteControlEndSeekingForward    = 109, 快进停止【操作：按耳机线控中间按钮两下到了快进的位置松开】
     */
    
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:               // 播放
            [[JSMusciManager sharedMusicManager].audioPlayer play];
            break;
        case UIEventSubtypeRemoteControlPause:              // 暂停
//            [[JSMusciManager sharedMusicManager].audioPlayer pause];
            [self clickPlayButton:self.playButton];
            break;
        case UIEventSubtypeRemoteControlNextTrack:          // 下一曲
            [self clickNextButton:self.nextButton];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:      // 上一曲
            [self clickPreviousButton:self.previousButton];
            break;
        default:
            break;
    }
    
    
}


#pragma mark -- 更新歌词
- (void)updateLyric{
    
    // 当前歌词
    JSLyricModel *currentLyric = self.lyricModelArray[self.currentLyricIndex];
    
    // 下一句歌词  ( 2.判断越界问题)
    JSLyricModel *nextLyric = nil;
    if (self.currentLyricIndex == self.lyricModelArray.count - 1) {
        
        // 创建一个最大的下一句歌词
        nextLyric = [[JSLyricModel alloc]init];
        // 给自定义出来的最后一条歌词设置数据  (设置成最后一条歌词的数据)
        nextLyric.content = currentLyric.content;
        // 因为当前索引已经是最后一条歌词,所以上面的歌词赋值就相当于nextLyric.content = [self.lyricModelArray lastObject].content;
        // 直接设置成歌曲的总时长
        nextLyric.initialTime = [JSMusciManager sharedMusicManager].duration;
        
    }else{
        
        nextLyric = self.lyricModelArray[self.currentLyricIndex + 1];
    }
    
    // 正向调整进度(判断越界问题): 判断时间,改变当前的歌词的索引  : 当前播放时间 > 下一句歌词的起始时间 歌词索引 +1
    if ([JSMusciManager sharedMusicManager].currentTime > nextLyric.initialTime && self.currentLyricIndex < self.lyricModelArray.count - 1) {
        
        self.currentLyricIndex++;
        
        //  拖拽进度条时,只需要显示最近当前歌词,防止拖动歌词逐条跳动
        [self updateLyric];
        // 1. 当累加到正确的当前歌词索引时,下面才给歌词赋值,否则递归调用返回
        return;
        // 如果不进行递归调用直接return: 这里更新数据的定时器间隔时间为0.1s,假如将进度条拖拽到歌词索引60的位置,那么等到定时器自动调用到到歌词索引为60的歌词数据时,需要6s的时间才可以
        
    }
    
    // 反向调整进度(判断越界问题): 当前时间 < 当前句歌词的初始时间 歌词索引-1
    if ([JSMusciManager sharedMusicManager].currentTime < currentLyric.initialTime && self.currentLyricIndex > 0) {
        
        self.currentLyricIndex--;
        [self updateLyric];
        return;
    }
    
    // 设置歌词
    self.verticalLyricLabel.text = self.lyricModelArray[self.currentLyricIndex].content;
    self.horizonLyricLabel.text = self.lyricModelArray[self.currentLyricIndex].content;
    

    
#pragma mark -- 设置歌词变色
    
    /*          设置歌词变色进度
     
         平均速度进行计算 : (当前播放时间 - 当前句起始时间) / 当前句总时间
            当前句总时间 :   下一句的起始时间 - 当前句的起始时间)
     
     */
    
    CGFloat averageProgress = ([JSMusciManager sharedMusicManager].currentTime - currentLyric.initialTime) / (nextLyric.initialTime - currentLyric.initialTime);
    
    self.horizonLyricLabel.progress = averageProgress;
    self.verticalLyricLabel.progress = averageProgress;
    
#pragma mark -- 设置垂直滚动歌词视图的滚动,传递当前歌词索引
    self.centerLyricView.currentLyricIndex = self.currentLyricIndex;
    self.centerLyricView.currentLyricProgress = averageProgress;

    
}

#pragma mark -- 绘制带有歌词的专辑图片
- (UIImage *)createImage{
    
    // 获取当前歌曲的封面图片
    JSMusicModel *currentMusicModel = self.musicList[self.currentMusicIndex];
    UIImage *currentMusicImage = [UIImage imageNamed:currentMusicModel.image];
    // 获取当前歌曲正在播放的那句歌词
    JSLyricModel *currentLyricModel = self.lyricModelArray[self.currentLyricIndex];
    
    // 设置尺寸  (需要考虑横竖屏,取宽、高中的最小值,设置一个正方形)
    CGFloat imgageWidthAndHeight = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    // 开启一个bitmap类型图形上下文  (参数1:大小  参数2:是否不透明 参数3:缩放比  0.0代表当前设备缩放比)
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imgageWidthAndHeight, imgageWidthAndHeight), NO, 0.0);
    
    // 将封面图片绘制到图形上下文
    [currentMusicImage drawInRect:CGRectMake(0, 0, imgageWidthAndHeight, imgageWidthAndHeight)];
    
    // 设置歌词填充色
    [[UIColor whiteColor] setFill];
    
    // 将歌词绘制到图形上下文
    [currentLyricModel.content drawInRect:CGRectMake(0, imgageWidthAndHeight - kJSLyricLockedLabelHeight, imgageWidthAndHeight, kJSLyricLockedLabelHeight) withFont:[UIFont systemFontOfSize:17] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    
    // 从图形上下文获取图片
    UIImage *ImageWithLyric = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭图形上下文
    UIGraphicsEndImageContext();
    
    // 返回带有歌词的图片
    return ImageWithLyric;
}

#pragma mark -- 将时间转为字符串
- (NSString *)timeStringWithTimeInterval:(NSTimeInterval)timeInterval{
    
    int minute = timeInterval / 60;
    int second = (int)timeInterval % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d",minute,second];
}

#pragma mark -- 设置封面视图
- (void)setupVerticalAlbumImageView{
     // 使用图形上下文绘图获取圆角图片
//    self.verticalAlbumImageView.layer.cornerRadius = 100;
//    self.verticalAlbumImageView.clipsToBounds = YES;
}

#pragma mark -- 设置垂直封面圆角图片
- (UIImage *)setAlbumImageWithOriginalImage:(UIImage *)originalImage{
    
    // 图片真实尺寸
    CGSize imageSize = originalImage.size;
    
    // 开启一个bitmap类型的图形上下文: 参数1:图形上下文尺寸 参数2: 是否不透明 参数3: 缩放比(0.0代表当前屏幕缩放比)
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    // CGContextRef ctx = UIGraphicsGetCurrentContext(); // 获取图形上下文 CGContextRef方式实现
    
    // 添加路径 UIBezierPath方式实现
    CGPoint center = CGPointMake(imageSize.width*0.5, imageSize.height*0.5);
    CGFloat radius = MIN(imageSize.width * 0.5, imageSize.height * 0.5);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    // 按照bezierPath路径切割
    [bezierPath addClip];
    // CGContextAddPath(ctx, bezierPath.CGPath);
    // CGContextClip(ctx);
    
    // 将图片绘制至图形上下文
    [originalImage drawAtPoint:CGPointZero];
    
    // 绘制圆环
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center radius:radius-2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    circlePath.lineWidth = 4;
    [[UIColor purpleColor] set];
    [circlePath stroke];
    
    UIImage *imageWithCircle = UIGraphicsGetImageFromCurrentImageContext();

    // 关闭图形上下文
    UIGraphicsEndPDFContext();
    
    
    // 保存到相册
    // UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    // 返回图片
    return imageWithCircle;
}

//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
//    
//}


#pragma mark -- 设置背景图  毛玻璃效果
- (void)setupBackgroundView{
    
    /**  设置毛玻璃效果 设置视觉特效:iOS7开始出现但是没有开放 iOS8开放API
     
         UIBlurEffect:毛玻璃效果
         UIVibrancyEffect:内容鲜活(内容可以根据背景色进行变化)
     */
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    
    // 需要将视效视图添加到目标视图中(效果将会影响后面的内容分层视图或内容添加到视图的contentview视觉效果)
    [self.backgroundImageView addSubview:blurEffectView];
    // 设置约束
    [blurEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    // 设置内容鲜活效果 依赖于毛玻璃效果
//    UIVibrancyEffect *vibbrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
//    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc]initWithEffect:vibbrancyEffect];
//    [self.backgroundImageView addSubview:vibrancyEffectView];
//    [vibrancyEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
//    }];
//    
//    // 添加内容: 会让内容随着背景色进行变化,需要添加内容(里面的子视图)
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 120, [UIScreen mainScreen].bounds.size.width, 100)];
//    label.text = @"会让内容随着背景色进行变化,需要添加内容(里面的子视图)";
//    [vibrancyEffectView.contentView addSubview:label];
    
}

#pragma mark -- 响应事件

// 开始/暂停按钮
- (IBAction)clickPlayButton:(UIButton *)sender {

    JSMusicModel *model = self.musicList[self.currentMusicIndex];
    
    if (sender.selected) {  // 暂停
        
        [[JSMusciManager sharedMusicManager] pauseMusic];
        sender.selected = NO;
        // 销毁定时器
        [self.timer invalidate];
        self.timer = nil;
        
    }else {
        
        // 设置当前时间
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateData) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
        
        [[JSMusciManager sharedMusicManager] playMusicWithFileName:model.mp3];
        
        sender.selected = YES;
    }
    
}
//上一曲
- (IBAction)clickPreviousButton:(id)sender {
    
    if (self.currentMusicIndex == 0) {
        
        self.currentMusicIndex = self.musicList.count - 1;
    }else {
        
        self.currentMusicIndex--;
    }
    
    // 销毁定时器
    [self.timer invalidate];
    self.timer = nil;
    // 每次点击(上一曲/下一曲)后让按钮状态变为未选中,再调用setupData时就会自动播放
    self.playButton.selected = NO;
    
    
    // 切歌索引清零
    self.currentLyricIndex = 0;
    
    
    [self setupData];
    
    
}
//下一曲
- (IBAction)clickNextButton:(id)sender {
    
    if (self.currentMusicIndex == self.musicList.count - 1) {
        
        self.currentMusicIndex = 0;
    }else {
        
        self.currentMusicIndex++;
    }
    
    // 销毁定时器
    [self.timer invalidate];
    self.timer = nil;
    
    // 每次点击(上一曲/下一曲)后让按钮状态变为未选中,再调用setupData时就会自动播放
    self.playButton.selected = NO;
    // 切歌索引清零
    self.currentLyricIndex = 0;
    
    [self setupData];
    
    
}
#pragma mark --  调整进度
- (IBAction)clickProgressSlider:(UISlider *)sender {
    // 设置当前时间
    [JSMusciManager sharedMusicManager].currentTime = sender.value * [JSMusciManager sharedMusicManager].duration;
}

#pragma mark -- 懒加载

- (NSArray<JSMusicModel *> *)musicList{
    
    if (_musicList == nil) {
        _musicList = [JSMusicModel loadMusicListWithFileName:@"mlist"];
    }
    
    return _musicList;
}

@end
