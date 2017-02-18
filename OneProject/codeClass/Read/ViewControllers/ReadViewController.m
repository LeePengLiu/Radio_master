//
//  ReadViewController.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "ReadViewController.h"
//轮播图 网络请求在pch文件 无需再次引入
#import "ReadListCell.h"
#import "ReadListModel.h"
#import "ReadCircleModel.h"
#import "ReadDetailVC.h"
#import "ReadInfoDetailVC.h"
#import "ReadDetailModel.h"
@interface ReadViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
//声明集合视力属性
@property (nonatomic, strong)UICollectionView *collectionView;
//轮播图数据源
@property (nonatomic, strong)NSMutableArray *circleImageArray;
//阅读列表数据源
@property (nonatomic, strong)NSMutableArray *readListArray;
//将轮播声明为属性
@property (nonatomic, strong)CircleView *circleView;
@property (nonatomic, strong)NSMutableArray *indexPathArray;
//开机图
@property (nonatomic, strong)UIImageView *openImageView;
@end

@implementation ReadViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    //打开App之后，第一次进入界面，解档一次播放记录
    //开始解档
    [[ArchiveManager sharedArchiveManager] unarchiver];
 
    [self setNavigationRightItem];
    //导航栏背景透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.title = @"阅  读";
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [backImageView setImage:[UIImage imageNamed:@"timg.jpg"]];
    [self.view addSubview:backImageView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.circleImageArray = [NSMutableArray array];
    self.readListArray = [NSMutableArray array];
    self.indexPathArray = [NSMutableArray array];
    self.view.backgroundColor = [UIColor redColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self showProgressHUD];
    [self creatCollectionView];
    [self setOpenView];
    //[self requestData];
    //**********请求数据方法***********
    //**********展示列表视图方法*********
}
- (void)setOpenView {
    self.openImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    self.openImageView.image = [UIImage imageNamed:@"open.jpg"];
    [self.view insertSubview:self.openImageView aboveSubview:self.collectionView];
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - 展示集合视图方法

- (void)creatCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = 2;
    //设置上下最小间距
    layout.minimumLineSpacing = 5;
    //设置item大小
    layout.itemSize = CGSizeMake((kDeviceWidth - 20) / 3, (kDeviceHeight -64 - 165 - 20) / 3);
    //设置分区边界
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 0, 5);
    //创建集合视图
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 165 + 64, kDeviceWidth, kDeviceHeight - 64) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    //注册cell
    [self.collectionView registerNib:[UINib nibWithNibName:@"ReadListCell" bundle:nil] forCellWithReuseIdentifier:@"readCell"];
     //背景色
     //集合视图背景颜色是黑色
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    //添加到视图图上
    [self.view addSubview:self.collectionView];
}
#pragma mark -- 请求数据
- (void)requestData {
    //使用封装好的网络请坟
    [NetworkingManager requestGETWithUrlString:kReadListURL parDic:nil finish:^(id responseObject) {
        //开始解析数据（封装）
        [self handleParserDataWithResponse:responseObject];
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

//解析数据封装
- (void)handleParserDataWithResponse:(id)data {
    //先封装轮播图数据源
    NSArray *imageArray = [[data objectForKey:@"data"] objectForKey:@"carousel"];
    //创建临时数组 用于给轮播图传值
    NSMutableArray *urlImageArray = [NSMutableArray array];
    //遍历数组 封装model
    for (NSDictionary *dic in imageArray) {
        //先把img图片连接放进轮播数组中
        [urlImageArray addObject:[dic objectForKey:@"img"]];
        //再封装model（是为了点周轮播图时进行传值用的,需要进入轮插图详情）
        ReadCircleModel *circleModel = [[ReadCircleModel alloc]init];
        [circleModel setValuesForKeysWithDictionary:dic];
        //model放进数据源中
        [self.circleImageArray addObject:circleModel];
    }
    //遍历结束，意味着轮播图url准备完毕
    //添加轮播图
    self.circleView = [[CircleView alloc]initWithImageURLArray:urlImageArray changeTime:2.0 withFrame:CGRectMake(0, 64, kDeviceWidth, 165)];
    //点击事件
    __weak ReadViewController *weakSelf = self;
    self.circleView.tapActionBlock = ^(NSInteger pageIndex) {
        ReadInfoDetailVC *infoVC = [[ReadInfoDetailVC alloc]init];
        ReadCircleModel *model = weakSelf.circleImageArray[pageIndex];
        infoVC.circleModel = model;
        NSArray *array = [model.url componentsSeparatedByString:@"/"];
        infoVC.typeID = [array lastObject];
        infoVC.tempModel = [[ReadDetailModel alloc]init];
        infoVC.tempModel.coverimg = model.img;
        infoVC.tempModel.title = @"轮播图进来的";
        infoVC.tempModel.readid = [array lastObject];
        [weakSelf.navigationController pushViewController:infoVC animated:YES];
    };
    [self.view addSubview:self.circleView];
    
    NSArray *listArray = [[data objectForKey:@"data"] objectForKey:@"list"];
    //遍历数组
    for ( NSDictionary *dic in listArray) {
        //封装模型
        ReadListModel *listModel = [[ReadListModel alloc]init];
        [listModel setValuesForKeysWithDictionary:dic];
        [self.readListArray addObject:listModel];
    }
    [self.openImageView removeFromSuperview];
    self.navigationController.navigationBar.hidden = NO;
    //刷新界面
    [self.collectionView reloadData];
    //隐藏小菊花
    [self hideProgressHUD];
}

#pragma mark -- UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.readListArray.count;
}

//配置CELL


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ReadListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"readCell" forIndexPath:indexPath];
    //取出对应的model
    ReadListModel *tempModel = [self.readListArray objectAtIndex:indexPath.row];
    //给cell赋值
    cell.nameLabel.text = [NSString stringWithFormat:@"%@%@", tempModel.name, tempModel.enname];
    //给图片赋值
    NSURL *url = [NSURL URLWithString:tempModel.coverimg];
    [cell.coverImage setImageWithURL:url];
    
    return cell;
}

//点击cell要执行的方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //点击cell 将cell上展示的model传递给详情界面，因为详情接口中的参数在model中
    ReadDetailVC *readDetailVC = [[ReadDetailVC alloc]init];
    readDetailVC.tempModel = [self.readListArray objectAtIndex:indexPath.row];
    //NSLog(@"%@",readDetailVC.tempModel.type);
    [self.navigationController pushViewController:readDetailVC animated:YES];
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    //设置Cell的动画效果为3D效果
    //设置x和y的初始值为0.1；
    //if (![_indexPathArray containsObject:indexPath]) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        //x和y的最终值为1
        [UIView animateWithDuration:1 animations:^{
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1);
        }];
      //  [_indexPathArray addObject:indexPath];
    //}
}
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [self.circleView initWithTimer];
//}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.circleView initWithTimer];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.circleView removeTimer];
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
