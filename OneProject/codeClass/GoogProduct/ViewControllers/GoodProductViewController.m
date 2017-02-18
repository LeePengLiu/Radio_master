//
//  GoodProductViewController.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "GoodProductViewController.h"
#import "GoodDetailVC.h"
@interface GoodProductViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *indexPathArray;
@property (nonatomic, strong)UIButton *button;
@end
NSInteger isPageP = 0;
NSInteger isDownN = 1;
@implementation GoodProductViewController

- (NSMutableArray *)indexPathArray {
    if (_indexPathArray == nil) {
        self.indexPathArray = [NSMutableArray array];
    }
    return _indexPathArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //导航栏背景透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [backImageView setImage:[UIImage imageNamed:@"timg.jpg"]];
    [self.view addSubview:backImageView];
    //[self setNavigationRightItem];
    
    self.dataArray = [NSMutableArray array];
   
    //[self requestHttp];
    __weak GoodProductViewController *weakSelf = self;
    MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingBlock:^{
        isPageP = 0;
        isDownN = 1;
        [weakSelf requestHttp];
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.automaticallyChangeAlpha = YES;
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
    MJChiBaoZiFooter *footer = [MJChiBaoZiFooter footerWithRefreshingBlock:^{
        isPageP += 10;
        isDownN = 0;
        [weakSelf requestHttp];
    } ];
    // 隐藏刷新状态的文字
    footer.stateLabel.hidden = YES;
    footer.refreshingTitleHidden = YES;
    self.tableView.mj_footer = footer;
}
- (UITableView *)tableView {
    if (_tableView == nil) {
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:self.tableView];
        [self.tableView registerNib:[UINib nibWithNibName:@"GoodListCell" bundle:nil] forCellReuseIdentifier:@"goodCell"];
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.button setTitle:@"..." forState:UIControlStateNormal];
        self.button.backgroundColor = [UIColor grayColor];
        [self.button addTarget:self action:@selector(handleShowLeft:) forControlEvents:UIControlEventTouchUpInside];
        self.button.frame = CGRectMake(kDeviceWidth - 40 - 25, kDeviceHeight - 40 - 25, 40, 40);
        [self.view insertSubview:self.button aboveSubview:self.tableView];
        
}
    return _tableView;
}
- (void)handleShowLeft:(UIButton *)sender {
    DDMenuController *menuController = ((AppDelegate *)[UIApplication sharedApplication].delegate).ddMenuController;
    [menuController showLeftController:YES];
}
//封装请求数据
- (void)requestHttp {
    [NetworkingManager requestPOSTWithUrlString:KGoodProdductURL parDic:@{@"deviceid":@"63A94D37-33F9-40FF-9EBB-481182338873",@"client":@"1",@"sort":@"addtime",@"limit":@10,@"version":@"3.0.2",@"start":@(isPageP),@"auth":@"Wc06FCrkoq1DCMVzGMTikDJxQ8bm3Mrm2NpT9qWjwzcWP23tBKQx1c4P0"} finish:^(id responseObject) {
        [self handleDataWithData:responseObject];
    } error:^(NSError *error) {
        
    }];
}
//封装解析数据
- (void)handleDataWithData:(id)data {
    
    NSArray *tempArray = [[data objectForKey:@"data"] objectForKey:@"list"];
    if (isDownN == 1) {
         [self.dataArray removeAllObjects];
         [self.indexPathArray removeAllObjects];
         [self.tableView.mj_header endRefreshing];
    }else {
         [self.tableView.mj_footer endRefreshing];
    }
    for (NSDictionary *tempDic in tempArray) {
        GoodListModel *model = [[GoodListModel alloc]init];
        [model setValuesForKeysWithDictionary:tempDic];
        [self.dataArray addObject:model];
     
    }    
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 303;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodCell" forIndexPath:indexPath];
    GoodListModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodListModel *model = self.dataArray[indexPath.row];
    GoodDetailVC *detailVC = [[GoodDetailVC alloc]init];
    detailVC.model = model;
    [self.navigationController pushViewController:detailVC animated:YES];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //设置Cell的动画效果为3D效果
    //设置x和y的初始值为0.1；
    if (![self.indexPathArray containsObject:indexPath] && indexPath.row != 0 && indexPath.row != 1) {
        cell.transform = CGAffineTransformMakeTranslation(0, 300);
        //x和y的最终值为1
        [UIView animateWithDuration:0.8 animations:^{
            cell.transform = CGAffineTransformIdentity;
        }];
        [self.indexPathArray addObject:indexPath];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    //定时器暂停
//    NSLog(@"aaa");
//    if (scrollView == self.tableView) {
//        self.button.hidden = YES;
//    }
//    
//}
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    NSLog(@"bbb");
//    if (scrollView == self.tableView) {
//         self.button.hidden = NO;
//    }
//   
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
