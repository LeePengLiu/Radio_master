//
//  RadioDetailVC.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "RadioDetailVC.h"

#import "RadioDetailCell.h"
#import "RadioPlayerController.h"
#import "MusicModel.h"
#import "ArchiveManager.h"
#import "PlayerManager.h"
@interface RadioDetailVC ()<UITableViewDataSource,UITableViewDelegate>
//表视图
@property (nonatomic, strong)UITableView *tableView;
//表视图的头部视图
@property (nonatomic, strong)UIImageView *imageView;
//数据源
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UIButton *button;
@property (nonatomic, strong)NSMutableArray *indexPathArray;
@property (nonatomic, strong)NSMutableArray *itemArray;
@end
NSInteger isRadioDetailDown = 1;
NSInteger isRadioDetailPage = 0;
@implementation RadioDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //返回上一界面
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(handleBackView:)];
    self.navigationItem.leftBarButtonItems = @[item];
    self.navigationItem.title = self.NVTitle;
    //导航栏背景透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //背景图片
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [backImageView setImage:[UIImage imageNamed:@"timg.jpg"]];
    [self.view addSubview:backImageView];
    
    self.dataArray = [NSMutableArray array];
    self.indexPathArray = [NSMutableArray array];
    self.itemArray = [NSMutableArray array];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight - 64) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"RadioDetailCell" bundle:nil] forCellReuseIdentifier:@"radioDetailCell"];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self setHeaderView];
    __weak RadioDetailVC *weakSelf = self;
    MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingBlock:^{
        isRadioDetailDown = 1;
        isRadioDetailPage = 0;
        if (weakSelf.circleModel) {
            [weakSelf requestCircleHttpWithModel:weakSelf.circleModel url:kRadioDetailURL];
        }else {
            [weakSelf requestHttp:kRadioDetailURL];
        }

    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.automaticallyChangeAlpha = YES;
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
    MJChiBaoZiFooter *footer = [MJChiBaoZiFooter footerWithRefreshingBlock:^{
        isRadioDetailDown = 0;
        isRadioDetailPage += 10;
        if (weakSelf.circleModel) {
            [weakSelf requestCircleHttpWithModel:weakSelf.circleModel url:kRadioDetailLoadURL];
        }else {
            [weakSelf requestHttp:kRadioDetailLoadURL];
        }
    } ];
    // 隐藏刷新状态的文字
    footer.stateLabel.hidden = YES;
    footer.refreshingTitleHidden = YES;
    self.tableView.mj_footer = footer;
   
    [self.tableView.mj_header beginRefreshing];
    //播放界面
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(0, 0, 32, 32);
    [self.button setImage:[UIImage imageNamed:@"playing00.png"] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(handlePlayerView:) forControlEvents:UIControlEventTouchUpInside];
    self.button.imageView.animationImages = @[[UIImage imageNamed:@"playing00.png"],[UIImage imageNamed:@"playing01.png"],[UIImage imageNamed:@"playing02.png"]];
    self.button.imageView.animationDuration = 0.8;
    self.button.imageView.animationRepeatCount = CGFLOAT_MAX;
    UIBarButtonItem *playItem = [[UIBarButtonItem alloc]initWithCustomView:self.button];
    self.navigationItem.rightBarButtonItems = @[playItem];
}

//导航栏右button，进入播放界面
- (void)handlePlayerView:(UIButton *)sender {
    //从沙盒解档好的单例中取值
    RadioPlayerController *playController = [RadioPlayerController sharedPlayerVC];
    if (!playController.tempModel) {
    playController.tempModel = [[ArchiveManager sharedArchiveManager].array objectAtIndex:[ArchiveManager sharedArchiveManager].index];
    playController.musicArray = [NSMutableArray arrayWithArray:[ArchiveManager sharedArchiveManager].array];
    playController.itemArray = [ArchiveManager sharedArchiveManager].itemArray;
    playController.index = [ArchiveManager sharedArchiveManager].index;
    }
    if (playController.musicArray.count == 0) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"没有播放记录" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:NO completion:nil];
    }
    [self.button.imageView stopAnimating];
    [self.navigationController pushViewController:playController animated:YES];
}


//返回上一界面
- (void)handleBackView:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


//封装头部视图
- (void)setHeaderView {
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, 200)];
    self.imageView.userInteractionEnabled = YES;
    self.tableView.tableHeaderView = self.imageView;
}


//请求数据
- (void)requestHttp:(NSString *)url {
    NSString *page = [NSString stringWithFormat:@"%ld", isRadioDetailPage];
    [NetworkingManager requestPOSTWithUrlString:url parDic:@{@"radioid":self.model.radioid, @"start": page} finish:^(id responseObject) {
        [self handleData:responseObject];
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}
//头部视图请求数据
- (void)requestCircleHttpWithModel:(RadioCircleModel *)model url:(NSString *)url {
    NSString *page = [NSString stringWithFormat:@"%ld", isRadioDetailPage];
    [NetworkingManager requestPOSTWithUrlString:url parDic:@{@"radioid":self.radioid, @"start": page} finish:^(id responseObject) {
        
        [self handleData:responseObject];
        
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}



//解析数据
- (void)handleData:(id)responseObject {
    if (isRadioDetailDown == 1) {
        [self.dataArray removeAllObjects];
        [self.indexPathArray removeAllObjects];
        [self.itemArray removeAllObjects];
        //头部大图
        NSString *coverimg = [[[responseObject objectForKey:@"data"] objectForKey:@"radioInfo"] objectForKey:@"coverimg"];
        [self.imageView setImageWithURL:[NSURL URLWithString:coverimg]];
    }else {
}
    
    //表CELL
    NSArray *tempArray = [[responseObject objectForKey:@"data"] objectForKey:@"list"];
    for (NSDictionary *dic in tempArray) {
        RadioDetailModel *model = [[RadioDetailModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataArray addObject:model];
        AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:model.musicUrl]];
        [self.itemArray addObject:item];
    }
   //回到主线程
    
            [self.tableView reloadData];

    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RadioDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"radioDetailCell" forIndexPath:indexPath];
    RadioDetailModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:252 / 255.0 green:229 / 255.0 blue:212 / 255.0 alpha:1];
    }else {
        cell.backgroundColor = [UIColor whiteColor];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RadioDetailModel *model = self.dataArray[indexPath.row];
    RadioPlayerController *playController = [RadioPlayerController sharedPlayerVC];
    playController.tempModel = model;
    playController.musicArray = [self.dataArray mutableCopy];
    playController.index = indexPath.row;
    playController.itemArray = self.itemArray;
     playController.playNew = YES;
    [self.navigationController pushViewController:playController animated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                    NSForegroundColorAttributeName:[UIColor whiteColor]};
    if ([PlayerManager sharedPlayerManager].playStatus == PlayerStatusPause) {
        return;
    }
    [self.button.imageView startAnimating];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}
//重写父类播放状态按钮动画
- (void)doAnimation:(NSNotification *)notify {
    if ([PlayerManager sharedPlayerManager].playStatus == PlayerStatusPause) {
        return;
    }
    [self.button.imageView startAnimating];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //设置Cell的动画效果为3D效果
    //设置x和y的初始值为0.1；
    if (![_indexPathArray containsObject:indexPath]) {
        cell.layer.transform = CATransform3DMakeScale(1, 0.1, 1);
        //x和y的最终值为1
        [UIView animateWithDuration:1 animations:^{
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1);
        }];
        [_indexPathArray addObject:indexPath];
    }
}
- (void)doAnimationOfHeadSet:(NSNotification *)notify {
    if ([PlayerManager sharedPlayerManager].playStatus == PlayerStatusPause) {
        [self.button.imageView stopAnimating];
    }else {
        [self.button.imageView startAnimating];
    }
}
- (void)startOrStopPlayMusic:(NSNotification *)notify {
    [self.button.imageView stopAnimating];
}
- (void)dealloc {
    NSLog(@"详情界面");
}


@end
