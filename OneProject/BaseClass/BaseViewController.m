//
//  BaseViewController.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController
//使用懒加载创建对象
- (MBProgressHUD *)HUD {
    if (_HUD == nil) {
        self.HUD = [[MBProgressHUD alloc]initWithView:self.view];
        [self.view addSubview:_HUD];
    }return _HUD;
}

#pragma mark -- 显示loading
- (void)showProgressHUD {
    [self showProgressHUDWithString:nil];
    //[self.HUD show:YES];
}
#pragma mark -- 
- (void)showProgressHUDWithString:(NSString *)title {
    if (title.length == 0) {
        self.HUD.labelText = nil;
    }else {
        self.HUD.labelText = title;
    }
    [self.HUD show:YES];
}

//隐藏
- (void)hideProgressHUD {
    if (self.HUD != nil) {
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}
//添加导航栏右button
- (void)setNavigationRightItem {
    //播放界面
    self.baseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.baseButton.frame = CGRectMake(0, 0, 32, 32);
    [self.baseButton setImage:[UIImage imageNamed:@"playing00.png"] forState:UIControlStateNormal];
    [self.baseButton setImage:[UIImage imageNamed:@"playingPress.png"] forState:UIControlStateHighlighted];
    [self.baseButton addTarget:self action:@selector(handleBasePlayerView:) forControlEvents:UIControlEventTouchUpInside];
    self.baseButton.imageView.animationImages = @[[UIImage imageNamed:@"playing00.png"],[UIImage imageNamed:@"playing01.png"],[UIImage imageNamed:@"playing02.png"]];
    self.baseButton.imageView.animationDuration = 0.8;
    self.baseButton.imageView.animationRepeatCount = CGFLOAT_MAX;
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:self.baseButton];
    self.navigationItem.rightBarButtonItems = @[item];
}

- (void)handleBasePlayerView:(UIButton *)sender {
    //从沙盒解档好的单例中取值
    RadioPlayerController *playController = [RadioPlayerController sharedPlayerVC];
    if (!playController.tempModel) {
        playController.tempModel = [[ArchiveManager sharedArchiveManager].array objectAtIndex:[ArchiveManager sharedArchiveManager].index];
        playController.musicArray = [NSMutableArray arrayWithArray:[ArchiveManager sharedArchiveManager].array];
        playController.index = [ArchiveManager sharedArchiveManager].index;
        playController.itemArray = [ArchiveManager sharedArchiveManager].itemArray;
    }
    if (playController.musicArray.count == 0) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"没有播放记录" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:NO completion:nil];
    }
    [self.baseButton.imageView stopAnimating];
    [self.navigationController pushViewController:playController animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //[self setNavigationRightItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doAnimation:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doAnimationOfHeadSet:) name:@"STARTORSTOPANIMATION" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startOrStopPlayMusic:) name:@"TIMERStopRIGHT" object:nil];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([PlayerManager sharedPlayerManager].playStatus == PlayerStatusPause) {
        return;
    }
    [self.baseButton.imageView startAnimating];
}
//HOME后台，再次进入前台时的处理
- (void)doAnimation:(NSNotification *)notify {
    if ([PlayerManager sharedPlayerManager].playStatus == PlayerStatusPause) {
        return;
    }
    if ([PlayerManager sharedPlayerManager].avPlayer.rate == 0 && [PlayerManager sharedPlayerManager].playStatus == PlayerStatusPlay)  {
        return;
    }
    [self.baseButton.imageView startAnimating];
}
//耳机事件播放与暂停的处理
- (void)doAnimationOfHeadSet:(NSNotification *)notify {
    if ([PlayerManager sharedPlayerManager].playStatus == PlayerStatusPause) {
        [self.baseButton.imageView stopAnimating];
    }else {
        [self.baseButton.imageView startAnimating];
    }
}
//定时器通知事件处理
- (void)startOrStopPlayMusic:(NSNotification *)notify {
    [self.baseButton.imageView stopAnimating];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
