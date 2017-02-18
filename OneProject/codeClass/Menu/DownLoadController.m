//
//  DownLoadController.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "DownLoadController.h"
#import "DownLoadManager.h"
#import "DownLoadCell.h"
#import "RadioDetailModel.h"
@interface DownLoadController ()
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)DownLoadManager *manager;
@end

@implementation DownLoadController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [DownLoadManager sharedDownLoadManager];
    [self.tableView registerNib:[UINib nibWithNibName:@"DownLoadCell" bundle:nil] forCellReuseIdentifier:@"downLoadCell"];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(15, 30, 32, 32);
    [button addTarget:self action:@selector(handleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    
    [view addSubview:button];
    self.tableView.tableHeaderView = view;
    
}
//返回上一界面
- (void)handleButtonAction:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [self.view removeFromSuperview];
//}


#pragma mark - Table view 加载数据

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.manager.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownLoadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downLoadCell" forIndexPath:indexPath];
    RadioDetailModel *model = self.manager.dataArray[indexPath.row];
    cell.unameLabel.text = model.title;
    cell.unameLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *tempDic = model.playInfo[@"authorinfo"];
    cell.titleLabel.text = tempDic[@"uname"];
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    cell.titleLabel.textColor = [UIColor colorWithRed:214 / 255.0 green:214 / 255.0 blue:214 / 255.0 alpha:1];
    [model setProgressBlock:^(float progress, float bytes) {
        cell.myProgressVIew.progress = progress;
        cell.progressLabel.text = [NSString stringWithFormat:@"%.2f%%", progress * 100];
    }];
    cell.downloadTask = model.downloadTask;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor yellowColor];
    return cell;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
