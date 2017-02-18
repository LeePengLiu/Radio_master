//
//  RadioViewController.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "RadioViewController.h"
#import "RadioListModel.h"
#import "RadioCircleModel.h"
#import "RadioListCell.h"
#import "RadioDetailVC.h"
#import "RadioPlayerController.h"
#import "ArchiveManager.h"
#import "PlayerManager.h"
@interface RadioViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)NSMutableArray *imageArray;

@property (nonatomic, strong)UIButton *button;
@property (nonatomic, strong)NSMutableArray *indexPathArray;
@end
static NSInteger isRadioDown = 1;
static NSInteger isRadioPage = 9;

@implementation RadioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [backImageView setImage:[UIImage imageNamed:@"timg.jpg"]];
    [self.view addSubview:backImageView];
    self.navigationItem.title = @"片 刻 电 台";
    //播放界面
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(0, 0, 32, 32);
    [self.button setImage:[UIImage imageNamed:@"playing00.png"] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(handlePlayerView:) forControlEvents:UIControlEventTouchUpInside];
    self.button.imageView.animationImages = @[[UIImage imageNamed:@"playing00.png"],[UIImage imageNamed:@"playing01.png"],[UIImage imageNamed:@"playing02.png"]];
    self.button.imageView.animationDuration = 0.8;
    self.button.imageView.animationRepeatCount = CGFLOAT_MAX;
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:self.button];
    self.navigationItem.rightBarButtonItems = @[item];
    //导航栏背景透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    

    self.indexPathArray = [NSMutableArray array];
    self.view.backgroundColor = [UIColor grayColor];
    //[self setupView];
    //[self setupHttp];
    __weak RadioViewController *weakSelf = self;
    MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingBlock:^{
        isRadioDown = 1;
        isRadioPage = 9;
        [weakSelf setupHttp];
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.automaticallyChangeAlpha = YES;
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
    MJChiBaoZiFooter *footer = [MJChiBaoZiFooter footerWithRefreshingBlock:^{
        isRadioDown = 0;
        isRadioPage += 10;
        [weakSelf setupHttp];
    } ];
    // 隐藏刷新状态的文字
    footer.stateLabel.hidden = YES;
    footer.refreshingTitleHidden = YES;
    self.tableView.mj_footer = footer;
    //[self.tableView.mj_header beginRefreshing];
    
}
//懒加载

- (NSMutableArray *)imageArray {
    if (_imageArray == nil) {
        self.imageArray = [NSMutableArray array];
    }
    return _imageArray;
}
- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        self.dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
#pragma mark -- 视图将要出现
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16],
                                                                    NSForegroundColorAttributeName:[UIColor whiteColor]};
    if ([PlayerManager sharedPlayerManager].playStatus == PlayerStatusPause) {
        return;
    }
    [self.button.imageView startAnimating];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isFirst = 0;
    [self.cricleView initWithTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.cricleView removeTimer];
}
- (void)doAnimation:(NSNotification *)notify {
    if ([PlayerManager sharedPlayerManager].playStatus == PlayerStatusPause) {
        return;
    }
    [self.button.imageView startAnimating];
}
- (void)doAnimationOfHeadSet:(NSNotification *)notify {
    if ([PlayerManager sharedPlayerManager].playStatus == PlayerStatusPause) {
        [self.button.imageView stopAnimating];
    }else {
        [self.button.imageView startAnimating];
    }
}
//导航栏右button，进入播放界面
- (void)handlePlayerView:(UIButton *)sender {
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
    [self.button.imageView stopAnimating];
    [self.navigationController pushViewController:playController animated:YES];
}


//封装请求数据方法
- (void)setupHttp {
    if (isRadioDown == 1) {
        
        [NetworkingManager requestPOSTWithUrlString:kRadioListURL parDic:nil finish:^(id responseObject) {
            [self handleDataInHttp:responseObject];
           
        } error:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }else {
        
        [NetworkingManager requestPOSTWithUrlString:kRadioListNEXT parDic:@{@"start":@(isRadioPage)} finish:^(id responseObject) {
            [self handleDataHttpNext:responseObject];
            [self hideProgressHUD];
        } error:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
    
   
}
//封装数据请求
- (void)handleDataInHttp:(id)responseObject {
    if (isRadioDown == 1) {
        [self.dataArray removeAllObjects];
        [self.imageArray removeAllObjects];
        [self.indexPathArray removeAllObjects];
    }
    
    NSDictionary *dic = responseObject;
    NSDictionary *dataDic = dic[@"data"];
    NSArray *listArray = dataDic[@"alllist"];
    NSArray *carouselArray = dataDic[@"carousel"];
    for (NSDictionary *dic in listArray) {
        RadioListModel *model = [[RadioListModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataArray addObject:model];
    }
    for (NSDictionary *dic in carouselArray) {
        RadioCircleModel *model = [[RadioCircleModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.imageArray addObject:model];
    }
    [self tableViewSetHeaderView:self.tableView];
    [self.tableView.mj_header endRefreshing];
    [self.tableView reloadData];
}

//封装上拉加载解析
- (void)handleDataHttpNext:(id)responseObject {
    NSDictionary *dic = responseObject;
    NSDictionary *dataDic = dic[@"data"];
    NSArray *listArray = dataDic[@"list"];
    for (NSDictionary *dic in listArray) {
        RadioListModel *model = [[RadioListModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataArray addObject:model];
    }
    [self.tableView.mj_footer endRefreshing];
    [self.tableView reloadData];
}
- (UITableView *)tableView {
    if (_tableView == nil) {
        [self setupView];
    }
    return _tableView;
}

//封装界面
- (void)setupView {
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"RadioListCell" bundle:nil] forCellReuseIdentifier:@"radioCell"];
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    
}
//封装头部视图
- (void)tableViewSetHeaderView:(UITableView *)tableView {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, 200)];
    NSMutableArray *imageArray = [NSMutableArray array];
    for (RadioCircleModel *model in self.imageArray) {
        NSString *url = model.img;
        [imageArray addObject:url];
    }
    self.cricleView = [[CircleView alloc]initWithImageURLArray:imageArray changeTime:2.0 withFrame:CGRectMake(0, 0, kDeviceWidth, 200)];
    __weak RadioViewController *weakSelf = self;
    if (self.isFirst == 1) {
        [self.cricleView removeTimer];
    }
    [self.cricleView setTapActionBlock:^(NSInteger page) {
        RadioDetailVC *detailVC = [[RadioDetailVC alloc]init];
        RadioCircleModel *model = weakSelf.imageArray[page];
        detailVC.circleModel = model;
        NSArray *radioid = [model.url componentsSeparatedByString:@"/"];
        detailVC.radioid = [radioid lastObject];
        [weakSelf.navigationController pushViewController:detailVC animated:YES];
    }];
    [view addSubview:self.cricleView];
    tableView.tableHeaderView = view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RadioListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"radioCell" forIndexPath:indexPath];
    RadioListModel *model = self.dataArray[indexPath.row];
    [cell.coverimg setImageWithURL:[NSURL URLWithString:model.coverimg]];
    cell.titleLabel.text = model.title;
    cell.unameLabel.text = model.uname;
    cell.descLabel.text = model.desc;
    
    CGFloat b = [model.count floatValue];
    if (b > 999) {
        CGFloat c = b / 1000;
        cell.countLabel.text = [NSString stringWithFormat:@"%.2lfk", c];
    }else {
        cell.countLabel.text = [NSString stringWithFormat:@"%@", model.count];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RadioListModel *model = self.dataArray[indexPath.row];
    RadioDetailVC *detailVC = [[RadioDetailVC alloc]init];
    detailVC.model = model;
    detailVC.NVTitle = model.title;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)dealloc {
    NSLog(@"第一界面");
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //设置Cell的动画效果为3D效果
    //设置x和y的初始值为0.1；
    if (![_indexPathArray containsObject:indexPath]) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        //x和y的最终值为1
        [UIView animateWithDuration:1 animations:^{
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1);
        }];
        [_indexPathArray addObject:indexPath];
    }
}
- (void)startOrStopPlayMusic:(NSNotification *)notify {
    [self.button.imageView stopAnimating];
}

@end
