//
//  RadioPlayerController.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "RadioPlayerController.h"
#import "PlayerManager.h"
#import "ArchiveManager.h"
#import "DownLoadManager.h"
#import "RadioPlayListCell.h"
#import <Accelerate/Accelerate.h>
#import "RadioTimerController.h"
@interface RadioPlayerController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong)PlayerManager *manager;
@property (nonatomic, strong)UILabel *currentLabel;
@property (nonatomic, strong)UILabel *totalLabel;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UIView *MusicListView;
@property (nonatomic, assign)NSInteger isList;
@property (nonatomic, strong)NSTimer *myTimer;
@property (nonatomic, strong)UIView *titleView;
@property (nonatomic, strong)UIButton *playTypeButton;
@property (nonatomic, strong)UIButton *timerButton;
@property (nonatomic, strong)UISlider *slider;
@property (nonatomic, strong)AVPlayerItem *item;
@end
 static NSInteger isRadioPPDown = 0;
 static NSString * const PlayerItemStatusContext = @"PlayerItemStatusContext";
@implementation RadioPlayerController
+ (RadioPlayerController *)sharedPlayerVC {
    static RadioPlayerController *playerVC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerVC = [RadioPlayerController new];
    });
    return playerVC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isList = 0;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //返回上一界面

     UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"left.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(handleBackView:)];
    self.navigationItem.leftBarButtonItems = @[item];
    //导航栏背景透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.title = self.tempModel.title;
    //下载，已注
    //[self setDownLoad];
    //播放列表
    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"listThree.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(handleListView:)];

    self.navigationItem.rightBarButtonItems = @[listButton];
    
    //封装后台播放
    [self RequiredBackground];
    //注册进入后台，和进入前台的通知
    self.manager = [PlayerManager sharedPlayerManager];
    //block回调给进度条赋值
    __weak RadioPlayerController *weakSelf = self;
    self.manager.myBlock = ^void(float value) {
        weakSelf.slider.value = value;
        NSInteger a = (NSInteger)weakSelf.manager.currentTime % 60;
        NSInteger b = (NSInteger)weakSelf.manager.currentTime / 60;
        weakSelf.currentLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", b, a];
        NSInteger c = (NSInteger)weakSelf.manager.totalTime % 60;
        NSInteger d = (NSInteger)weakSelf.manager.totalTime / 60;
        weakSelf.totalLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", d, c];
    };
  
    self.manager.theStopTimerBlock = ^void(float value) {
        NSInteger a = (NSInteger)value % 60;
        NSInteger b = (NSInteger)value / 60;
        [weakSelf.timerButton setTitle:[NSString stringWithFormat:@"%02ld:%02ld", b, a] forState:UIControlStateNormal];
        [weakSelf.timerButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        //        if (value == 0) {
        //            [weakSelf.timerButton setTitle:@"定时关闭" forState:UIControlStateNormal];
        //            [weakSelf.timerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        //        }

    };

    //记录当前播放时长
    
    //判断：如果是回到上一个播放界面，就回到之前的播放时长
    self.manager.musicArray = [self.musicArray mutableCopy];
    [self.manager setItemArray:self.itemArray index:self.index];
    self.item = [self.itemArray objectAtIndex:self.index];
    //[self.manager play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startOrStopPlayMusics:) name:@"TIMERStopRIGHT" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doAnimation:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerButtonIsStop:) name:@"THESTOPTIMERISNIL" object:nil];
    [self setupUI];
//    [self.item addObserver:self forKeyPath:@"status" options:0 context:(__bridge void * _Nullable)(PlayerItemStatusContext)];
//    [self.manager addObserver:self forKeyPath:@"item" options:0 context:nil];
}
//一部分数据加载写在这里，防止push界面加载太慢
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

//下载功能
- (void)setDownLoad {
    
     UIButton *downButton = [UIButton buttonWithType:UIButtonTypeCustom];
     downButton.frame = CGRectMake(0, 0, 32, 32);
     [downButton  setImage:[UIImage imageNamed:@"downLoad.png"] forState:UIControlStateNormal];
     //downButton.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, -30);
     [downButton addTarget:self action:@selector(handleDownView:) forControlEvents:UIControlEventTouchUpInside];
     //UIBarButtonItem *downLoaditem = [[UIBarButtonItem alloc]initWithCustomView:downButton];
     
     //列表
     UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
     listButton.frame = CGRectMake(0, 0, 32, 32);
     [listButton  setImage:[UIImage imageNamed:@"listThree.png"] forState:UIControlStateNormal];
     listButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
     [listButton addTarget:self action:@selector(handleListView:) forControlEvents:UIControlEventTouchUpInside];
     //UIBarButtonItem *listitem = [[UIBarButtonItem alloc]initWithCustomView:listButton];
}

//高斯模糊
-(UIImage *)boxblurImage:(UIImage *)image withBlurNumber:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
}
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) *
                         CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

//封装界面
- (void)setupUI {
   
    //背景图片
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:backImageView];
    backImageView.tag = 901;
    UIBlurEffect *iii = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:iii];
    
    visualEffectView.frame = backImageView.frame;
    
    //添加毛玻璃效果层
    
    [backImageView addSubview:visualEffectView];
    
    
    RadioDetailModel *tempModel1 = self.musicArray[self.index];
    
    __weak UIImageView *weakImageView = backImageView;
    [backImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tempModel1.coverimg]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakImageView.image = image;
} failure:nil];
        //播放界面
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];

    //歌手名
    UILabel *singerLabel = [[UILabel alloc]initWithFrame:CGRectMake(kDeviceWidth / 2 - 100, 100, 200, 40)];//CGRectMake(kDeviceWidth / 2 - 100, 140, 200, 40)
    singerLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *tempDic = self.tempModel.playInfo[@"authorinfo"];
    singerLabel.text = tempDic[@"uname"];
    singerLabel.tag = 301;
    //[view addSubview:singerLabel];
    
    //背景图
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(kDeviceWidth / 2 - 110, 145, 220, 220)];
    
    RadioDetailModel *tempModel = self.musicArray[self.index];
    [imageView setImageWithURL:[NSURL URLWithString:tempModel.coverimg]];
    imageView.layer.cornerRadius = 110;
    imageView.layer.masksToBounds = YES;
    imageView.tag = 555;
    //开启计时器
    //[self startTimer];
    [view addSubview:imageView];
    
    //进度条
    self.slider = [[UISlider alloc]initWithFrame:CGRectMake(20, 400, kDeviceWidth - 40, 50)];
    [view addSubview:self.slider];
    //[slider addTarget:self action:@selector(handleSliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.slider setThumbImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage imageNamed:@"circle"] forState:UIControlStateHighlighted];
    [self.slider addTarget:self action:@selector(handleSliderActionStopTimerOnVC:) forControlEvents:UIControlEventTouchDown];
    [self.slider addTarget:self action:@selector(handleSliderActionStartTimerOnVC:) forControlEvents:UIControlEventTouchUpInside];

    

    //播放与暂停
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame = CGRectMake(kDeviceWidth / 2 - 30, kDeviceHeight - 80, 64, 64);
    [playButton addTarget:self action:@selector(handlePlay:) forControlEvents:UIControlEventTouchUpInside];
    [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateHighlighted];
    [playButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    playButton.tag  =  666;
    //上一首
    UIButton *lastButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lastButton.frame = CGRectMake(kDeviceWidth / 4 - 64, kDeviceHeight - 80, 64, 64);
    [lastButton setImage:[UIImage imageNamed:@"last.png"] forState:UIControlStateNormal];
    [lastButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    lastButton.tag = 667;
    [lastButton addTarget:self action:@selector(handleLast:) forControlEvents:UIControlEventTouchUpInside];
    //下一首
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(kDeviceWidth / 4 * 3, kDeviceHeight - 80, 64, 64);
    [nextButton setImage:[[UIImage imageNamed:@"next.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    nextButton.tag = 668;
    [nextButton addTarget:self action:@selector(handleNext:) forControlEvents:UIControlEventTouchUpInside];
    
    //当前播放时长
    self.currentLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_slider.frame), 50, 30)];
    self.currentLabel.textColor =  [UIColor colorWithRed:235 / 255.0 green:229 / 255.0 blue:209 / 255.0 alpha:1];
    
    self.currentLabel.text = [NSString stringWithFormat:@"00:00"];
    [view addSubview:self.currentLabel];
    //总播放时长
    self.totalLabel = [[UILabel alloc]initWithFrame:CGRectMake(kDeviceWidth - 20 - 50, CGRectGetMaxY(_slider.frame), 50, 30)];
    self.totalLabel.textColor = [UIColor colorWithRed:235 / 255.0 green:229 / 255.0 blue:209 / 255.0 alpha:1];
    self.totalLabel.text = [NSString stringWithFormat:@"00:00"];
   
    
    [view addSubview:self.totalLabel];
    //加进view
    [view addSubview:playButton];
    [view addSubview:lastButton];
    [view addSubview:nextButton];
    //[self.view addSubview:view];
    [self.view insertSubview:view aboveSubview:backImageView];
    [self setMusicListView];
}

//定时器方法
- (void)handleSliderActionStopTimerOnVC:(UISlider *)sender {
    [[PlayerManager sharedPlayerManager].myTimer invalidate];
    [PlayerManager sharedPlayerManager].myTimer = nil;
}
- (void)handleSliderActionStartTimerOnVC:(UISlider *)sender {
     [[PlayerManager sharedPlayerManager] setTimer];
    [self.manager seekTime:[PlayerManager sharedPlayerManager].totalTime * sender.value];
}

//开始计时器
- (void)startTimer {
    if (self.myTimer == nil) {
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(turnPicture) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.myTimer forMode:NSRunLoopCommonModes];
    }
}
//停止计时器
- (void)stopTimer {
    [self.myTimer invalidate];
    self.myTimer = nil;
}
#pragma mark - 图片旋转
- (void)turnPicture{
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:555];
    imageView.transform = CGAffineTransformRotate(imageView.transform,M_PI_4 * .01);
}

- (void)handlePlay:(UIButton *)sender {
    if (self.manager.playStatus == PlayerStatusPause) {
        [self.manager play];
        [sender setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateHighlighted];
        [self startTimer];
    }else{
        [self.manager pause];
        [sender setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateHighlighted];
        
        [self stopTimer];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STARTORSTOPANIMATION" object:nil];
}
- (void)handleLast:(UIButton *)sender {
    [self.manager lastMusic];
    [self setbackground];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STARTORSTOPANIMATION" object:nil];
}
- (void)handleNext:(UIButton *)sender {
    [self.manager nextMusic];
    [self setbackground];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STARTORSTOPANIMATION" object:nil];
}
#pragma mark -- 封装改动背景图、title、singer方法
- (void)setbackground {
    UIButton *playButton = (UIButton *)[self.view viewWithTag:666];
    [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:555];
    RadioDetailModel *tempModel = self.musicArray[self.manager.index];
    self.navigationItem.title = tempModel.title;
    UILabel *singerLabel = (UILabel *)[self.view viewWithTag:301];
    NSDictionary *tempDic = tempModel.playInfo[@"authorinfo"];
    singerLabel.text = tempDic[@"uname"];
    //[imageView setImageWithURL:[NSURL URLWithString:tempModel.coverimg]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:tempModel.coverimg]];
    __weak typeof(imageView)weakImageView = imageView;
    UIImageView *backgroudImage = (UIImageView *)[self.view viewWithTag:901];
    
    [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        //回到主线程加载视图
        dispatch_async(dispatch_get_main_queue(), ^{
            weakImageView.image = image;
            //高斯模糊效果
            //backgroudImage.image = [self boxblurImage:image withBlurNumber:1];
            backgroudImage.image = image;
            [self stopTimer];
            [self startTimer];
            weakImageView.transform = CGAffineTransformIdentity;
        });
        
    } failure:nil];
}



//返回上一界面
- (void)handleBackView:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    }
#pragma mark -- 下载
- (void)handleDownView:(UIButton *)sender {
    
    RadioDetailModel *tempModel = self.musicArray[self.manager.index];
   
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(kDeviceWidth / 2 - 40, kDeviceHeight / 2 - 20, 80, 40)];
    label.layer.cornerRadius = 5;
    label.layer.masksToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"开始下载";
    for (RadioDetailModel *model in [DownLoadManager sharedDownLoadManager].dataArray) {
        //遍历，查看传进来的model是否已经在下载的任务中
        if ([model.tingid isEqualToString:tempModel.tingid]) {
            label.text = @"已经下载";
        }
    }
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    [UIView animateWithDuration:0.8 animations:^{
        label.alpha = 0;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
     [[DownLoadManager sharedDownLoadManager] downLoadWithModel:tempModel];
}




//列表
- (void)handleListView:(UIButton *)sender {
    if (self.isList == 0) {
        [UIView animateWithDuration:0.2 animations:^{
//       self.MusicListView.frame = CGRectMake(2, kDeviceHeight - 256, kDeviceWidth - 4, 256);
            self.MusicListView.transform = CGAffineTransformMakeTranslation(0, -280);
            self.MusicListView.alpha = 0.97;
        }];
        self.isList = 1;
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            self.MusicListView.transform = CGAffineTransformMakeTranslation(0, 0);
            self.MusicListView.alpha = 0;
        }];
       self.isList = 0;
    }
}
//封装列表视图
- (void)setMusicListView {
    self.MusicListView = [[UIView alloc]initWithFrame:CGRectMake(2, kDeviceHeight, kDeviceWidth - 4, 280)];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, kDeviceWidth - 4, 200) style:UITableViewStylePlain];
    [self.MusicListView addSubview:self.tableView];
    //列表标题
    self.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth - 4, 40)];
    self.titleView.backgroundColor = [UIColor whiteColor];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCancel:)];
    //[titleView addGestureRecognizer:tap];
    [self.MusicListView addSubview:self.titleView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((kDeviceWidth - 4) /2 - 50, 0, 100, 40)];
    titleLabel.text = @"播 放 列 表";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleView addSubview:titleLabel];
    //播放模式按钮
    self.playTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playTypeButton.frame = CGRectMake(0, 0, 100, 40);
    [self.playTypeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.playTypeButton setTitle:@"列表播放" forState:UIControlStateNormal];
    self.playTypeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.playTypeButton addTarget:self action:@selector(handlePlayTypeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:self.playTypeButton];
    //定时关闭音乐
    self.timerButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    self.timerButton.frame = CGRectMake(kDeviceWidth - 4 - 100, 0, 100, 40);
    [self.timerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.timerButton setTitleColor:[UIColor cyanColor] forState:UIControlStateHighlighted];
    [self.timerButton setTitle:@"定时关闭" forState:UIControlStateNormal];
    self.timerButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.timerButton addTarget:self action:@selector(handleTimerAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:self.timerButton];
    //关闭列表按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 240, kDeviceWidth - 4, 40);
    button.backgroundColor = [UIColor whiteColor];
    [button setTitle:@"关  闭" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor cyanColor] forState:UIControlStateHighlighted];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button addTarget:self action:@selector(handleCloseAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.MusicListView addSubview:button];
    self.MusicListView.alpha = 0;
    self.MusicListView.layer.cornerRadius = 3;
    self.MusicListView.layer.masksToBounds = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 40;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"RadioPlayListCell" bundle:nil] forCellReuseIdentifier:@"radioPlayListCell"];
    [self.view addSubview:self.MusicListView];
}
- (void)handlePlayTypeAction:(UIButton *)sender {
    
    if ( [PlayerManager sharedPlayerManager].playType == PlayerTypeRandom) {
        [PlayerManager sharedPlayerManager].playType = PlayerTypeList;
        [self.playTypeButton setTitle:@"列表播放" forState:UIControlStateNormal];
        [self.playTypeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }else {
        [PlayerManager sharedPlayerManager].playType = PlayerTypeRandom;
        [self.playTypeButton setTitle:@"随机播放" forState:UIControlStateNormal];
        [self.playTypeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
}
- (void)handleTimerAction:(UIButton *)sender {
    [self handleCloseAction:nil];
    RadioTimerController *timerVC = [[RadioTimerController alloc]init];
    [self.navigationController pushViewController:timerVC animated:YES];
}
#pragma mark -- 列表视图tableView设置
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.musicArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RadioPlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"radioPlayListCell" forIndexPath:indexPath];
    RadioDetailModel *tempModel = self.musicArray[indexPath.row];
    cell.titleLabel.text = tempModel.title;
    NSDictionary *tempDic = tempModel.playInfo[@"authorinfo"];
    cell.singerLabel.text = tempDic[@"uname"];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    cell.model = tempModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.index = indexPath.row;
    [self.manager setItemArray:self.itemArray index:self.index];
    [self.manager play];
    [self setbackground];
}
- (void)handleTapAction:(UITapGestureRecognizer *)sender {
    
}
//点击视图收回musicListView
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (touch.view == self.titleView) {
            return;
        }
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.MusicListView.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
    self.isList = 0;
}

- (void)handleCloseAction:(UIButton *)sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.MusicListView.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
    self.isList = 0;
}

#pragma mark -- 后台播放
- (void)RequiredBackground {
    AppDelegate *myApp = [UIApplication sharedApplication].delegate;
    UIButton *playButton = (UIButton *)[self.view viewWithTag:666];
    UIButton *lastButton = (UIButton *)[self.view viewWithTag:667];
    UIButton *nextButton = (UIButton *)[self.view viewWithTag:668];
    [myApp setBlock:^(UIEvent *event) {
        //如果接收到远程事件，判断后，对应调用方法
        if (event.type == UIEventTypeRemoteControl) {
            //判断事件的类型
            switch (event.subtype) {
                case UIEventSubtypeRemoteControlNextTrack:
                    //下一首
                    [self handleNext:nextButton];
                    break;
                case UIEventSubtypeRemoteControlPreviousTrack:
                    //上一首
                    [self handleLast:lastButton];
                    break;
                case UIEventSubtypeRemoteControlPause:
                    //暂停或者开始
                    [self handlePlay:playButton];
                    break;
                case UIEventSubtypeRemoteControlPlay:
                    //暂停或者开始
                    [self handlePlay:playButton];
                    break;
                    //耳机暂停或者开始
                case UIEventSubtypeRemoteControlTogglePlayPause:
                    [self handlePlay:playButton];
                default:
                    break;
                    
            }
        }
    }];
    [myApp setHeadphoneBlock:^(NSInteger isPlay) {
        //UIImageView *imageView = (UIImageView *)[self.view viewWithTag:555];
        UIButton *playButton = (UIButton *)[self.view viewWithTag:666];
        if (isPlay == 0) {
            [self.manager play];
            [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
             [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateHighlighted];
            [self stopTimer];
            [self startTimer];
        }else{
            [self.manager pause];
            [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
             [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateHighlighted];
            [self stopTimer];
        }
    }];
    [myApp setArchiveBlock:^{
        //归档，记录当前播放
        NSString *string = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject];
        NSString *MusicArrayPath = [string stringByAppendingPathComponent:@"musicArray.plist"];
        //NSString *indexPath = [string stringByAppendingPathComponent:@"index"];
        NSNumber *index = @(self.manager.index);
        [[NSUserDefaults standardUserDefaults] setObject:index forKey:@"index"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //1.归档
        [NSKeyedArchiver archiveRootObject:self.musicArray toFile:MusicArrayPath];
    }];
}
//接收后台事件，可以直接写入这里
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    
}

- (void)dealloc {
    //可以写一个分类，让计时器对控制器变成弱引用，防止退出界面后VC不能被正常走dealloc方法，这里就不用写
    //移除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.myTimer invalidate];
    self.myTimer = nil;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                    NSForegroundColorAttributeName:[UIColor whiteColor]};
    if (self.playNew) {
        self.manager.musicArray = [self.musicArray mutableCopy];
        [self.manager setItemArray:self.itemArray index:self.index];
        [self setbackground];
        [self.manager play];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.playNew = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
   }
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
//当进入后台，打开别的音频时，后台播放自动停止 ，但是控件还保持之前状态，所以回到活跃状态时，进行一次观察，修改控件的状态
//而且在这里进行开始/停止动画转动
- (void)doAnimation:(NSNotification *)notify {
    //如果播放状态是正在播放，但是音乐停止播放了，证明是被后台停止，这时停止动画与修改播放按钮图片
    NSLog(@"走了%lf", [PlayerManager sharedPlayerManager].avPlayer.rate);
    if ([PlayerManager sharedPlayerManager].avPlayer.rate == 0 && [PlayerManager sharedPlayerManager].playStatus == PlayerStatusPlay) {
        //暂停或者开始
        UIButton *playButton = (UIButton *)[self.view viewWithTag:666];
        //修改播放图片
        [self handlePlay:playButton];
    }else if([PlayerManager sharedPlayerManager].avPlayer.rate == 1){
        //不是的话，重新启动计时器动画
        [self startTimer];
    }
}
//进入后台后，停止计时器动画
- (void)stopAnimation:(NSNotification *)notify {
    [self stopTimer];
}
//定时关闭执行方法
- (void)startOrStopPlayMusics:(NSNotification *)notify {
    [self stopTimer];
    [[PlayerManager sharedPlayerManager] pause];
    UIButton *playButton = (UIButton *)[self.view viewWithTag:666];
    [playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateHighlighted];
}

- (void)timerButtonIsStop:(NSNotification *)notify {
    [self.timerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.timerButton setTitle:@"定时关闭" forState:UIControlStateNormal];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (context ==  (__bridge void * _Nullable)(PlayerItemStatusContext)) {
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerItem * item = (AVPlayerItem *)object;
            if (item.status == AVPlayerItemStatusReadyToPlay) { //准备好播放
                NSInteger c = (NSInteger)self.manager.totalTime % 60;
                NSInteger d = (NSInteger)self.manager.totalTime / 60;
                self.totalLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", d, c];
                if (self.playNew) {
                    UIButton *playButton = (UIButton *)[self.view viewWithTag:666];
                    [self handlePlay:playButton];
                }
            }else if (item.status == AVPlayerItemStatusFailed){ //失败
                NSLog(@"failed");
            }
        }
    }
    if ([keyPath isEqualToString:@"item"]) {
        [self.item removeObserver:self forKeyPath:@"status" context:(__bridge void * _Nullable)(PlayerItemStatusContext)];
    }
}

@end
