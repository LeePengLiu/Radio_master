//
//  PlayerManager.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "PlayerManager.h"
#import "MusicModel.h"
#import "RadioDetailModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ArchiveManager.h"
#import "AppDelegate.h"
@implementation PlayerManager
//实现单例
+ (PlayerManager *)sharedPlayerManager {
    static PlayerManager *manager = nil;
    //GCD
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PlayerManager alloc]init];
        manager.avPlayer = [[AVPlayer alloc]init];
//        [manager addObserver:manager forKeyPath:@"item" options:NSKeyValueObservingOptionNew context:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(stopTheMusic:) name:@"TIMERStopRIGHT" object:nil];
    });
    return manager;
}

//实现观察者回调方法，有新的音乐播放时，就调用归档方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"item"]) {
        //将当前播放歌曲归档存到沙盒中，方便其它界面返回播放界面
        //检索服务器好友
//        NSLog(@"开始");
//        NSLog(@"开始1");
//        NSLog(@"开始2");
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//       
//         //[self archiveMusic];
//    });
//        NSLog(@"结束%ld", self.item.status);
   }
}
//实现定时关闭通知中心回调方法，关闭音乐
- (void)stopTheMusic:(NSNotification *)notify {
    [self pause];
    self.currentTime = 0;
}

//重写单例对象的初始化方法（单例对象只会创建一次，所以初始化方法也只走一次）
- (instancetype)init {
    self = [super init];
    if (self) {
        //创建播放器对象
        //默认配置
        self.playType = PlayerTypeList;
        //播放状态
        self.playStatus = PlayerStatusPause;
        //定时关闭默认index
        self.willStopIndex = 5;
    }
    return self;
}




#pragma mark -- 数据源（重写赋值方法）
- (void)setItemArray:(NSMutableArray *)itemArray index:(NSInteger)index{
    //先清空之前的数据
    //[_itemArray removeAllObjects];
    //把最新传进来的数据
    self.itemArray = [itemArray mutableCopy];
    //判断，如果当前播放的是上一次播放的，就直接return
    if (index == self.index && self.currentTime != 0) {
        return;
    }
    self.index = index;
    //根据对应下标来获取对应的url
    self.item = [self.itemArray objectAtIndex:self.index];
    //将item信息给播放器对象，为了保证其唯一性，判断对象是否存在，如果存在，直接使用
    if (_avPlayer) {
        //存在
        [self.avPlayer replaceCurrentItemWithPlayerItem:self.item];//相当于更换了播放数据
    }
}
#pragma mark -- 播放总时长(getter)
- (float)totalTime {
    //通过avPlayer 能获取当前的播放比例
    //安全判断 比例不能为0
    if (self.avPlayer.currentItem.duration.timescale == 0) {
        return 0;
    }
    return _avPlayer.currentItem.duration.value / self.avPlayer.currentItem.duration.timescale;
}
//当前时长
- (float)currentTime {
    if (self.avPlayer.currentTime.timescale == 0) {
        return 0;
    }
    return _avPlayer.currentTime.value / _avPlayer.currentTime.timescale;
}

//停止
- (void)stop {
    [self pause];//暂停
    [self seekTime:0];//进度清0
    
}

//播放
- (void)play {
    [self.avPlayer play];
    //改变状态
    self.playStatus = PlayerStatusPlay;
    //顺便配置后台播放时的信息，比如歌手名、歌曲名、背影图、专辑名等信息（封装）
    [self configLockScreen];
    //添加定时器
    [self setTimer];

   NSLog(@"%ld", self.item.status);
    //提高定时器的权限 防止定时器在拖动界面时停止计时
    //[[NSRunLoop mainRunLoop] addTimer:self.myTimer forMode:NSRunLoopCommonModes];
}
//添加定时器方法
- (void)setTimer {
    if (_myTimer == nil) {
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
  [[NSRunLoop currentRunLoop] addTimer:self.myTimer forMode:NSRunLoopCommonModes];
    }
}
#pragma mark -- 定时器方法

- (void)timeAction {
    float value = self.currentTime / self.totalTime;
    self.myBlock(value);
    if (value == 1) {
        [self nextMusic];
    }
}
//设置定时关闭计时器
- (void)setTheStopTimer {
    if (_stopTimer == nil) {
        self.stopTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeStopAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.stopTimer forMode:NSRunLoopCommonModes];
    }
        self.currentStopTime = 0;
}
//取消定时关闭
- (void)stopSetTheStopTimer {
    if (_stopTimer != nil){
        self.currentStopTime = 0;
        [self.stopTimer invalidate];
        self.stopTimer = nil;
        self.willStopIndex = 5;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"THESTOPTIMERISNIL" object:self];
    }
}
//定时关闭方法
- (void)timeStopAction {
    self.currentStopTime++;
    self.theStopTimerBlock(self.totalStopTime - self.currentStopTime);
    if (self.currentStopTime == self.totalStopTime) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TIMERStopRIGHT" object:self];
        [self stopSetTheStopTimer];
    }
}

#pragma mark -- 配置后台播放的信息
- (void)configLockScreen {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    //这个字典中收进来的都是后台播放界面的配置信息
    //需要引入MPMedial框架
    //专辑名
    RadioDetailModel *model = self.musicArray[self.index];
    //[dic setObject:model.title forKey:MPMediaItemPropertyAlbumTitle];
    //歌曲名
    NSDictionary *tempDic = model.playInfo[@"authorinfo"];
    [dic setObject:model.title forKey:MPMediaItemPropertyTitle];
    //歌手名
    [dic setObject:tempDic[@"uname"] forKey:MPMediaItemPropertyArtist];
    //封面图片（一般图片都是接口链接，所以需要请求数据）
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.coverimg]];
    UIImage *image = [UIImage imageWithData:data];
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc]initWithImage:image];
    [dic setObject:artWork forKey:MPMediaItemPropertyArtwork];
    
    //播放时长
    [dic setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(self.avPlayer.currentItem.duration)] forKey:MPMediaItemPropertyPlaybackDuration];
    //当前播放的信息中心
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = dic;//赋值操作 给后台配置
}
#pragma mark -- 归档
- (void)archiveMusic {
    //归档，记录当前播放
    NSString *string = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject];
    NSString *MusicArrayPath = [string stringByAppendingPathComponent:@"musicArray.plist"];
    //NSString *indexPath = [string stringByAppendingPathComponent:@"index"];
    NSNumber *index = @(self.index);
    [[NSUserDefaults standardUserDefaults] setObject:index forKey:@"index"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //1.归档
    [NSKeyedArchiver archiveRootObject:self.itemArray toFile:MusicArrayPath];
    
    //给解析单例赋值
    ArchiveManager *manager = [ArchiveManager sharedArchiveManager];
    manager.array = [self.itemArray mutableCopy];
    manager.index = self.index;
}

//暂停
- (void)pause {
    [self.avPlayer pause];
    self.playStatus = PlayerStatusPause;
    [self.myTimer invalidate];
    self.myTimer = nil;
}
//上一首
- (void)lastMusic {
    if (self.playType == PlayerTypeRandom) {
        //随机模式
        self.index = arc4random() % self.itemArray.count;
    }else if(self.playType == PlayerTypeSingle) {
        
    }
    else{
        if (self.index == 0) {
            self.index = self.itemArray.count - 1;
        }else {
            self.index--;
        }
        
    }
    [self changeMusicWithIndex:self.index];
}
//指定下标播放
- (void)changeMusicWithIndex:(NSInteger)index {
    //进行传值
    self.index = index;
    //更换item的数据
    self.item = self.itemArray[index];
    [_avPlayer replaceCurrentItemWithPlayerItem:self.item];
    //进行播放
    [self play];
}
//下一首
- (void)nextMusic {
    if (self.playType == PlayerTypeRandom) {
        self.index = arc4random() % self.itemArray.count;
    }else if(self.playType == PlayerTypeSingle) {
        
    }
    else {
        self.index++;
        if (self.index == self.itemArray.count) {
            self.index = 0;
        }
    }
    [self changeMusicWithIndex:self.index];
}
//播放进度
- (void)seekTime:(float)time {
    //获取当前时间
    CMTime newTime = self.avPlayer.currentTime;
    //重新设置时间
    newTime.value = newTime.timescale * time;
    //给播放器跳转到   新的时间
    [self.avPlayer seekToTime:newTime];
}
//播放完成后的操作
- (void)playDidFinish {
    //此首完成 继续下一首
    [self nextMusic];
}
//这里反正也不会走，写着玩- -
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"item"];
}

@end
