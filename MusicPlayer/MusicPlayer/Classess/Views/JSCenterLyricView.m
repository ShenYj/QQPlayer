//
//  JSCenterLyricView.m
//  MusicPlayer
//
//  Created by ShenYj on 16/7/21.
//  Copyright © 2016年 ___ShenYJ___. All rights reserved.
//

#import "JSCenterLyricView.h"
#import "JSLyricModel.h"
#import "JSColorLabel.h"
#import "Masonry.h"

#define SCREEN_SIZE ([UIScreen mainScreen].bounds.size)
#define VERTICAL_SCROLLVIEW_OFFSET ((self.bounds.size.height-LyricLabelHeight) * 0.5)

// 静态全局变量 存放Label的高度 宏处于预编译阶段,会延长编译时间
static CGFloat const LyricLabelHeight = 40;

@interface JSCenterLyricView () <UIScrollViewDelegate>

// 水平滚动ScrollView
@property (nonatomic,strong) UIScrollView *horizontalScrollView;
// 垂直滚动ScrollView
@property (nonatomic,strong) UIScrollView *verticalScrollView;


@end

@implementation JSCenterLyricView


/*      
     initWithCoder : 从文件创建时调用,相当于初始化
      awakeFromNib也可以,相当于ViewDidLoad,initWithCoder调用顺序先于awakeFromNib
 */
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        [self setupLyricView];
    }
    return self;
}

// 设置歌词视图
- (void)setupLyricView{
    
    // 添加控件
    [self addSubview:self.horizontalScrollView];
    // 设置约束
    [self.horizontalScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        // 占满视图
        make.edges.mas_equalTo(self);
    }];
    // 设置水平滚动ScrollView的ContentSize (垂直方向不希望滚动,所以设置为0)
    self.horizontalScrollView.contentSize = CGSizeMake(SCREEN_SIZE.width * 2, 0);
    
    // 水平滚动ScrollView添加垂直滚动的ScrollView
    [self.horizontalScrollView addSubview:self.verticalScrollView];
    // 设置垂直滚动ScrollView的约束
    [self.verticalScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self.horizontalScrollView).mas_offset(SCREEN_SIZE.width);
        make.size.mas_equalTo(self.horizontalScrollView);
        
    }];
    
    
    // 关闭滚动指示条 (水平滚动开启分页)
    self.horizontalScrollView.pagingEnabled = YES;
    self.horizontalScrollView.bounces = NO;
    self.horizontalScrollView.showsVerticalScrollIndicator = NO;
    self.horizontalScrollView.showsHorizontalScrollIndicator = NO;
    self.verticalScrollView.showsHorizontalScrollIndicator = NO;
    self.verticalScrollView.showsVerticalScrollIndicator = NO;
    
}

#pragma mark -- 重写setter方法
// 歌词模型数组setter方法
- (void)setLyricModelArray:(NSArray *)lyricModelArray{
    
    // 每次切歌先移除子视图  makeObjectsPerformSelector让所有对象都会去执行某一个方法
    [self.verticalScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _lyricModelArray = lyricModelArray;
    
    // 存放歌词的Label
    for (int i = 0; i < lyricModelArray.count; i ++) {
        // 创建歌词模型
        JSLyricModel *model = lyricModelArray[i];
        
        // 创建Label
        JSColorLabel *lyricLabel = [[JSColorLabel alloc]init];
        lyricLabel.textColor = [UIColor whiteColor];
        [self.verticalScrollView addSubview:lyricLabel];
        // 设置约束
        [lyricLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.verticalScrollView);
            make.height.mas_equalTo(LyricLabelHeight);
            // 索引 * 高度
            make.top.mas_equalTo(LyricLabelHeight*i);
            
        }];
        
        // 给Label设置数据
        lyricLabel.text = model.content;
    }
    
    // 设置垂直滚动ScrollView的ContentSize
    self.verticalScrollView.contentSize = CGSizeMake(0, LyricLabelHeight * lyricModelArray.count);
    
    
}

// 歌词索引setter方法
- (void)setCurrentLyricIndex:(NSInteger)currentLyricIndex{
    
    // 切歌索引处理,防止索引越界
    if (currentLyricIndex != 0) { // 索引=0 代表切换歌曲
        
        // 将之前索引对应的歌词字体大小和颜色恢复
        JSColorLabel *previousLyricLabel = self.verticalScrollView.subviews[_currentLyricIndex];
        previousLyricLabel.progress = 0;                        // 恢复上一句歌词的颜色
        previousLyricLabel.font = [UIFont systemFontOfSize:17]; // 恢复上一句歌词的字体默认大小
    }

    /*
        在_currentLyricIndex = currentLyricIndex;
        赋值前  _currentLyricIndex --> 上一句歌词的索引
     */
    _currentLyricIndex = currentLyricIndex;
    
    
    // 设置滚动 (根据索引设置偏移量实现滚动: 偏移量 = 默认偏移量 + 索引 * Label高度 )
    [self.verticalScrollView setContentOffset:CGPointMake(0, -VERTICAL_SCROLLVIEW_OFFSET + currentLyricIndex * LyricLabelHeight) animated:YES];
    
    // 设置当前Label字号放大  (根据索引取出Label)
    JSColorLabel *currentLabel = self.verticalScrollView.subviews[currentLyricIndex];
    // 设置当前Label字体大小
    currentLabel.font = [UIFont systemFontOfSize:21]; // 放大字体
    
}


// 当前歌词进度setter方法
- (void)setCurrentLyricProgress:(CGFloat)currentLyricProgress{
    
    
    _currentLyricProgress = currentLyricProgress;
    
    // 设置当前Label进度
    JSColorLabel *currentLabel = self.verticalScrollView.subviews[self.currentLyricIndex];
    currentLabel.progress = currentLyricProgress;
    
}



- (void)layoutSubviews{
    [super layoutSubviews];
    
    // 设置内边距
    self.verticalScrollView.contentInset = UIEdgeInsetsMake(VERTICAL_SCROLLVIEW_OFFSET, 0, VERTICAL_SCROLLVIEW_OFFSET, 0);
    // 设置默认的偏移量
    self.verticalScrollView.contentOffset = CGPointMake(0, -VERTICAL_SCROLLVIEW_OFFSET);
}

#pragma mark -- 懒加载

- (UIScrollView *)horizontalScrollView{
    
    if (_horizontalScrollView == nil) {
        _horizontalScrollView = [[UIScrollView alloc]init];
        _horizontalScrollView.delegate = self;
    }
    return _horizontalScrollView;
}
- (UIScrollView *)verticalScrollView{
    
    if (_verticalScrollView == nil) {
        _verticalScrollView = [[UIScrollView alloc]init];
    }
    return _verticalScrollView;
}

#pragma mark -- UIScrollViewDelegate

// 滚动水平方向的ScrollView时,根据滚动设置控制器下中心View视图的透明度(实现渐隐效果)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.horizontalScrollView) {

        self.scrollBlock(1-scrollView.contentOffset.x/SCREEN_SIZE.width);
    }
}



@end
