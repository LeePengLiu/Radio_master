//
//  setViewController.m
//  OneProject
//
//  Created by 刘坦 on 16/7/10.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "setViewController.h"
#import "CleanCaches.h"
#import "DNOLabelAnimation.h"
#import "setTableViewCell.h"
@interface setViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)DNOLabelAnimation *label;
@end

@implementation setViewController
- (UITableView *)tableView {
    if (_tableView == nil) {
        self.tableView = [[UITableView alloc]initWithFrame:kFrame style:UITableViewStyleGrouped];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.scrollEnabled = NO;
        [self.tableView registerNib:[UINib nibWithNibName:@"setTableViewCell" bundle:nil] forCellReuseIdentifier:@"CELL"];
    }
    return _tableView;
}
- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        self.dataArray = [NSMutableArray arrayWithObjects:@"清理缓存", nil];
    }
    return _dataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNavigationRightItem];
    [self.view addSubview:self.tableView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    setTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    cell.cleanLabel.text = self.dataArray[indexPath.row];
    self.label = cell.label;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    [self.label startAnimation];
    [self performSelector:@selector(stopAnimationOnLabel) withObject:self afterDelay:0.8];
    
   
}
- (void)stopAnimationOnLabel {
    [CleanCaches clearSubFilesWithFilePath:[CleanCaches LibraryDirectory]];
    CGFloat fileSize = [CleanCaches sizeWithFilePath:[CleanCaches LibraryDirectory]];
    [self.label stopAnimation];
    NSDictionary *attribute = @{NSForegroundColorAttributeName : [UIColor redColor]};
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2lfMB", fileSize] attributes:attribute];
    self.label.attributedText = string;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
