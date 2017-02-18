//
//  TopicViewController.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "TopicViewController.h"
#import "TopicListCell.h"
#import "TopicListCellTwo.h"
#import "TopicModel.h"
#import "TopicViewDetailVC.h"

@interface TopicViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *indexPathArray;
@end
NSInteger isRefresh = 1;
NSInteger isPage = 0;
@implementation TopicViewController
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        self.dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.indexPathArray = [NSMutableArray array];
    [self setNavigationRightItem];
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [backImageView setImage:[UIImage imageNamed:@"timg.jpg"]];
    [self.view addSubview:backImageView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //导航栏背景透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor yellowColor];
   // [self setHttp];
    [self setWithCallBack];
}
- (UITableView *)tableView {
    if (_tableView == nil) {
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight - 64) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.showsVerticalScrollIndicator = NO;
        [self.tableView registerNib:[UINib nibWithNibName:@"TopicListCell" bundle:nil] forCellReuseIdentifier:@"oneCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"TopicListCellTwo" bundle:nil] forCellReuseIdentifier:@"twoCell"];
        [self.view addSubview:self.tableView];
    }
    return _tableView;
}
- (void)setHttp {
    [NetworkingManager requestGETWithUrlString:kTopicListURL parDic:nil finish:^(id responseObject) {
        [self handleDataWithData:responseObject];
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
}
//封装解析
- (void)handleDataWithData:(id)data {
    NSArray *tempArray = [[data objectForKey:@"data"] objectForKey:@"list"];
    
    if (isRefresh == 1) {
        [self.dataArray removeAllObjects];
        [self.indexPathArray removeAllObjects];
    }
    
    for (NSDictionary *dic in tempArray) {
        TopicModel *model = [[TopicModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataArray addObject:model];
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        if (isRefresh == 1) {
            [self.tableView.mj_header endRefreshing];
        }else {
            [self.tableView.mj_footer endRefreshing];
        }
        [self.tableView reloadData];
    });
}
                  
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TopicModel *model = self.dataArray[indexPath.row];
    
    if (model.coverimg.length == 0) {
        return 230;
    }
    return 250;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TopicModel *model = self.dataArray[indexPath.row];
    if (model.coverimg.length == 0) {
        TopicListCellTwo *cell = [tableView dequeueReusableCellWithIdentifier:@"twoCell" forIndexPath:indexPath];
        cell.model = model;
       cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    TopicListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"oneCell" forIndexPath:indexPath];
    cell.model = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)setWithCallBack {
    __weak TopicViewController *vc = self;
    MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingBlock:^{
        isRefresh = 1;
        [vc setHttp];
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.automaticallyChangeAlpha = YES;
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
    MJChiBaoZiFooter *footer = [MJChiBaoZiFooter footerWithRefreshingBlock:^{
        isPage ++;
        isRefresh = 0;
        [NetworkingManager requestPOSTWithUrlString:kTopicListURL parDic:@{@"deviceid":@"63A94D37-33F9-40FF-9EBB-481182338873",@"client":@"1",@"sort":@"addtime",@"limit":@10,@"version":@"3.0.2",@"start":@(isPage),@"auth":@"Wc06FCrkoq1DCMVzGMTikDJxQ8bm3Mrm2NpT9qWjwzcWP23tBKQx1c4P0"} finish:^(id responseObject) {
            [vc handleDataWithData:responseObject];
        } error:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    } ];
    // 隐藏刷新状态的文字
    footer.stateLabel.hidden = YES;
    footer.refreshingTitleHidden = YES;
    self.tableView.mj_footer = footer;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TopicModel *model = self.dataArray[indexPath.row];
    TopicViewDetailVC *detailVC = [[TopicViewDetailVC alloc]init];
    detailVC.model = model;
    [self.navigationController pushViewController:detailVC animated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
