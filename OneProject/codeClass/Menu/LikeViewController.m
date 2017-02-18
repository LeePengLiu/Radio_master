//
//  LikeViewController.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "LikeViewController.h"
#import "ReadDetailCell.h"
#import "ReadDetailModel.h"
#import "AppDelegate.h"
#import "UserLikeModel.h"
@interface LikeViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)AppDelegate *myApp;
@end

@implementation LikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataArray = [NSMutableArray array];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"ReadDetailCell" bundle:nil] forCellReuseIdentifier:@"likeViewCell"];
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //返回上一界面
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 25, 50, 40);
    [button setTitle:@"<返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(handleBackAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
     //封装查询coreData方法
    [self setupCoreData];
}

#pragma mark -- coreData取数据
- (void)setupCoreData {
    NSManagedObjectContext *managedContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserLikeModel"];
     NSArray *array = [managedContext executeFetchRequest:fetchRequest error:nil];
    [self.dataArray addObjectsFromArray:array];

    if (self.dataArray.count == 0) {

        UIAlertController *control = [UIAlertController alertControllerWithTitle:@"提示" message:@"此处空空如也，快去四处走走吧" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [control addAction:cancel];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:control animated:YES completion:nil];
      
    
    }
}

#pragma mark -- tableView配置
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReadDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"likeViewCell" forIndexPath:indexPath];
    UserLikeModel *tempModel = self.dataArray[indexPath.row];
    
    [cell dataForCellWithLikeModel:tempModel];
    return cell;
}


#pragma mark -- 返回上一界面
- (void)handleBackAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
