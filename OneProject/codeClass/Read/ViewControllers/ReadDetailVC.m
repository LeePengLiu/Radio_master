//
//  ReadDetailVC.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "ReadDetailVC.h"
#import "ReadDetailModel.h"
#import "ReadDetailCell.h"
#import "ReadInfoDetailVC.h"
#import "UIScrollView+MJRefresh.h"
@interface ReadDetailVC ()<UITableViewDelegate,UITableViewDataSource>
//声明两个表视图
@property (nonatomic, strong)UITableView *newsTableView;
@property (nonatomic, strong)UITableView *hotTabelView;
//滑动视图
@property (nonatomic, strong)UIScrollView *rootScrollView;
@property (nonatomic, strong)UISegmentedControl *segmentedControl;
//数据源数组
//最新数组数据源
@property (nonatomic, strong)NSMutableArray *newsDataArray;
//最热数组数据源
@property (nonatomic, strong)NSMutableArray *hotDataArray;
//用于上拉加载更多数据的属性
@property (nonatomic, assign)NSInteger start;

@property (nonatomic, assign)NSInteger hotStart;
@property (nonatomic, assign)NSInteger newsStart;
@property (nonatomic, strong)NSMutableArray *hotIndexPathArray;
@property (nonatomic, strong)NSMutableArray *newsIndexPathArray;
@end
BOOL isDown = YES;
@implementation ReadDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
     self.automaticallyAdjustsScrollViewInsets = NO;
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [backImageView setImage:[UIImage imageNamed:@"timg.jpg"]];
    [self.view addSubview:backImageView];
    //返回上一界面
     UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(handleBackView:)];
    [self setNavigationRightItem];
    self.navigationItem.leftBarButtonItems = @[item];
    self.hotIndexPathArray = [NSMutableArray array];
    self.newsIndexPathArray = [NSMutableArray array];
    self.newsDataArray = [NSMutableArray array];
    self.hotDataArray = [NSMutableArray array];
    //封装添加表视图的方法
    //封装请求数据的方法
    //最热的数据请求
    //*******************刷新、加载控件******************
    //给加载数据参数赋初始值
    self.newsStart = 0;
    self.hotStart = 0;
    
    [self addScrollViewAndTableView];
    
    //添加两个头部刷新视图
    __weak ReadDetailVC *weakSelf = self;
    [self.hotTabelView addRefreshWithRefreshViewType:LORefreshViewTypeHeaderDefault refreshingBlock:^{
        //下拉刷新
        //1,请求最新的数据
        weakSelf.hotStart = 0;
        isDown = YES;
        //2.安全起见，清空数组放在数据请求之后 放在封装model之前
        [weakSelf requestDataWithSort:@"hot"];
    }];
    //添加最新数据的头部控件
    [self.newsTableView addRefreshWithRefreshViewType:LORefreshViewTypeHeaderDefault refreshingBlock:^{
        weakSelf.newsStart = 0;
        isDown = YES;
        [weakSelf requestDataWithSort:@"addtime"];
    }];
    
    //添加最热数据的尾部
    [self.hotTabelView addRefreshWithRefreshViewType:LORefreshViewTypeFooterDefault refreshingBlock:^{
        isDown = 0;
        weakSelf.hotStart += 10;
        [weakSelf requestDataWithSort:@"hot"];
    }];
    //添加最新数据的尾部
    [self.newsTableView addRefreshWithRefreshViewType:LORefreshViewTypeFooterDefault refreshingBlock:^{
        isDown = 0;
        weakSelf.newsStart += 10;
        [weakSelf requestDataWithSort:@"addtime"];
    }];
    
    
    
    
    
    [self requestDataWithSort:@"hot"];
    //最新的数据请求
    [self requestDataWithSort:@"addtime"];
     
    //关闭导航栏自适应的64高度
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //[self showProgressHUDWithString:@"玩命加载中"];
}
#pragma mark -- 添加滑动视图和表视图
- (void)addScrollViewAndTableView {
    //1.创建最新的表视图
    self.newsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight - 64)  style:UITableViewStylePlain];
    self.newsTableView.delegate = self;
    self.newsTableView.dataSource = self;
    self.newsTableView.showsVerticalScrollIndicator = NO;
    [self.newsTableView registerNib:[UINib nibWithNibName:@"ReadDetailCell" bundle:nil] forCellReuseIdentifier:@"newCell"];
    //2.创建最热表视图
    self.hotTabelView = [[UITableView alloc]initWithFrame:CGRectMake(kDeviceWidth, 0, kDeviceWidth, kDeviceHeight - 64) style:UITableViewStylePlain];
    self.hotTabelView.dataSource = self;
    self.hotTabelView.delegate = self;
    self.hotTabelView.showsVerticalScrollIndicator = NO;
    [self.hotTabelView registerNib:[UINib nibWithNibName:@"ReadDetailCell" bundle:nil] forCellReuseIdentifier:@"hotCell"];
    //*********************滑动视图*******************
    self.rootScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight - 64)];
    self.rootScrollView.contentSize = CGSizeMake(kDeviceWidth * 2, kDeviceHeight - 64);
    self.rootScrollView.pagingEnabled = YES;
    self.rootScrollView.delegate = self;
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.newsTableView];
    [self.rootScrollView addSubview:self.hotTabelView];
    //*********************添加分栏控件*******************
    self.segmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"最新", @"最热"]];
    self.segmentedControl.frame = CGRectMake(0, 0, 100, 30);
    self.segmentedControl.tintColor = [UIColor grayColor];
    //5.设置字体颜色和大小
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:15],
                          NSForegroundColorAttributeName:[UIColor grayColor]};
    [self.segmentedControl setTitleTextAttributes:dic forState:UIControlStateNormal];

    self.navigationItem.titleView = self.segmentedControl;
    //
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged];
}
#pragma mark -- 实现分栏的点击方法
- (void)segmentedAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self.rootScrollView setContentOffset:CGPointMake(0, 0)animated:NO];
    }else {
        [self.rootScrollView setContentOffset:CGPointMake(kDeviceWidth, 0)animated:NO];
    }
}
#pragma mark -- UIScrollViewDelegate -
//滑动视图改变 分栏的选中状态也要改变
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //判断 只有是滑动视图才需要修改
    if (scrollView == self.rootScrollView) {
        self.segmentedControl.selectedSegmentIndex = scrollView.contentOffset.x / kDeviceWidth;
    }
}
#pragma mark --开始网络请求
- (void)requestDataWithSort:(NSString *)sort {
    //详情接口需要typeID（在从上个界面接收的model中）
    NSString *typeID = self.tempModel.type;
    
    //利用sort参数 来判断该取哪一种start
    NSInteger tempStart = 0;
    if ([sort isEqualToString:@"hot"]) {
        tempStart = self.hotStart;
    }else {
        tempStart = self.newsStart;
    }
    NSString *startStr = [NSString stringWithFormat:@"%ld", tempStart];
    
    //请求开始
    [NetworkingManager requestPOSTWithUrlString:kReadDetailURL parDic:@{@"typeid": typeID, @"sort": sort, @"start":startStr} finish:^(id responseObject) {
        //调用数据解析
        [self handleDataWithSort:sort responseObject:responseObject];
    } error:^(NSError *error) {
        NSLog(@"出错了%@", error);
        
    }];
}
#pragma mark -- 数据解析
    
- (void)handleDataWithSort:(NSString *)sort responseObject:(id)data {
    //不管是最新还是最热 数据都在list键值对中
    NSArray *tempArray = [[data objectForKey:@"data"] objectForKey:@"list"];
    
   
    //最热开始遍历
    if ([sort isEqualToString:@"hot"]) {
        if (isDown == YES) {
            [self.hotDataArray removeAllObjects];
            [self.hotIndexPathArray removeAllObjects];
        }
        for (NSDictionary *dic in tempArray) {
            ReadDetailModel *hotModel = [[ReadDetailModel alloc]init];
            [hotModel setValuesForKeysWithDictionary:dic];
            hotModel.readid = [dic objectForKey:@"id"];
            [self.hotDataArray addObject:hotModel];
            
        }
        
        
        [self.hotTabelView reloadData];
    }else {
        if (isDown == YES) {
            [self.newsDataArray removeAllObjects];
            [self.newsIndexPathArray removeAllObjects];
        }
        for (NSDictionary *dic in tempArray) {
            ReadDetailModel *newModel = [[ReadDetailModel alloc]init];
            [newModel setValuesForKeysWithDictionary:dic];
            newModel.readid = [dic objectForKey:@"id"];
            [self.newsDataArray addObject:newModel];

        }
        [self.newsTableView reloadData];
    }
    [self.hotTabelView.defaultHeader endRefreshing];
    [self.hotTabelView.defaultFooter endRefreshing];
    [self.newsTableView.defaultHeader endRefreshing];
    [self.newsTableView.defaultFooter endRefreshing];
}

#pragma mark -- 配置表视图
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.hotTabelView) {
        return self.hotDataArray.count;
    }else {
        return self.newsDataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.hotTabelView) {
        //最热
        ReadDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hotCell" forIndexPath:indexPath];
        //取出对应的model
        ReadDetailModel *hotModel = [self.hotDataArray objectAtIndex:indexPath.row];
        //调用cell内部的赋值方法
        [cell dataForCellWithModel:hotModel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
        //最新
        ReadDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newCell" forIndexPath:indexPath];
        //取出对应的model
        ReadDetailModel *newModel = [self.newsDataArray objectAtIndex:indexPath.row];
        //调用赋值方法
        [cell dataForCellWithModel:newModel];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
   
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ReadInfoDetailVC *readInfoVC = [[ReadInfoDetailVC alloc]init];
    if (tableView == self.hotTabelView) {
        readInfoVC.tempModel = [self.hotDataArray objectAtIndex:indexPath.row];
    }else {
        readInfoVC.tempModel = [self.newsDataArray objectAtIndex:indexPath.row];
    }
    [self.navigationController pushViewController:readInfoVC animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.hotTabelView) {
        if ([self.hotIndexPathArray containsObject:indexPath]) {
            return;
        }else {
            [self.hotIndexPathArray addObject:indexPath];
        }
    }else {
        if ([self.newsIndexPathArray containsObject:indexPath]) {
            return;
        }else {
            [self.newsIndexPathArray addObject:indexPath];
        }
    }
   
    CATransform3D rotation;
    rotation = CATransform3DMakeRotation((90.0*M_PI/180), 0.0, 0.7, 0.4);
    rotation.m44 = 1.0/-600;
    //阴影
    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
    //阴影偏移
    cell.layer.shadowOffset = CGSizeMake(10, 10);
    //透明度
    cell.alpha = 0;
    
    cell.layer.transform = rotation;
    
    //锚点
    cell.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    [UIView beginAnimations:@"rotaion" context:NULL];
    
    [UIView setAnimationDuration:0.8];
    
    cell.layer.transform = CATransform3DIdentity;
    
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    
    [UIView commitAnimations];
}



- (void)dealloc {
    
    //移除观察者
    [self.newsTableView removeObserver:self.newsTableView.defaultFooter forKeyPath:@"contentSize"];
    [self.newsTableView removeObserver:self.newsTableView.defaultHeader forKeyPath:@"contentOffset"];
    [self.newsTableView removeObserver:self.newsTableView.defaultFooter forKeyPath:@"contentOffset"];
    
    [self.hotTabelView removeObserver:self.hotTabelView.defaultFooter forKeyPath:@"contentSize"];
    [self.hotTabelView removeObserver:self.hotTabelView.defaultHeader forKeyPath:@"contentOffset"];
    [self.hotTabelView removeObserver:self.hotTabelView.defaultFooter forKeyPath:@"contentOffset"];
}
//返回上一界面
- (void)handleBackView:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
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
