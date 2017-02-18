//
//  PlayerManager.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <Foundation/Foundation.h>
//
typedef void(^Block)(float);
typedef void(^TheStopTimerBlock)(float);
typedef void(^timeBlock)();
//将播放模式设置 随机、单曲、列表
typedef NS_ENUM(NSInteger, PlayType) {
    PlayerTypeRandom,//随机
    PlayerTypeSingle,//单曲
    PlayerTypeList//列表
};
//播放状态 播放以及暂停
typedef NS_ENUM(NSInteger, PlayStatus) {
    PlayerStatusPlay,//播放
    PlayerStatusPause//暂停
};

@interface PlayerManager : NSObject
//声明一些辅助属性
//block传值
@property (nonatomic, copy)Block myBlock;
//计时器让播放界面碟片转动
@property (nonatomic, copy)timeBlock timeBlock;
//定时关闭button的title赋值回调
@property (nonatomic, copy)TheStopTimerBlock theStopTimerBlock;
//歌曲的下标
@property (nonatomic, assign)NSInteger index;
//歌曲的数据源
@property (nonatomic, strong)NSMutableArray *itemArray;
@property (nonatomic, strong)NSMutableArray *musicArray;
//播放模式
@property (nonatomic, assign)PlayType playType;
//播放器状态
@property (nonatomic, assign)PlayStatus playStatus;
//播放器总时长
@property (nonatomic, assign)float totalTime;
//当前时长
@property (nonatomic, assign)float currentTime;
//播放器
@property (nonatomic, strong)AVPlayer *avPlayer;
@property (nonatomic, strong)AVPlayerItem *item;
//定时器
@property (nonatomic, strong)NSTimer *myTimer;
@property (nonatomic, strong)NSTimer *stopTimer;
@property (nonatomic, assign)NSInteger willStopIndex;
@property (nonatomic, assign)CGFloat currentStopTime;
@property (nonatomic, assign)CGFloat totalStopTime;

//开始声明方法
//单例方法
+ (PlayerManager *)sharedPlayerManager;
//停止
- (void)stop;//用于手动点击下一曲时，将正在播放的歌曲信息清除
//播放
- (void)play;
//暂停
- (void)pause;
//上一首
- (void)lastMusic;
//下一首
- (void)nextMusic;
//指定下标的位置进行播放（选取数组中某个对象进行播放）
- (void)changeMusicWithIndex:(NSInteger)index;
//指定位置进行播放（进度条更改后进行播放）
- (void)seekTime:(float)time;
//播放完成后的操作
- (void)playDidFinish;
- (void)setItemArray:(NSMutableArray *)itemArray index:(NSInteger)index;
//设置计时器
- (void)setTimer;
//设置定时关闭音乐计时器
- (void)setTheStopTimer;
- (void)stopSetTheStopTimer;
@end
