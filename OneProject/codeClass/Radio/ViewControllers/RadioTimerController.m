//
//  RadioTimerController.m
//  OneProject
//
//  Created by 刘坦 on 16/7/9.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "RadioTimerController.h"
#import "UIButton+Action.h"
@interface RadioTimerController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, assign)NSInteger timerCurrent;
@property (nonatomic, strong)UITapGestureRecognizer *tap;
@property (nonatomic, strong)UIView *tapView;
@property (nonatomic, strong)UIDatePicker *datePicker;
@property (nonatomic, strong)UIButton *cancelButton;
@property (nonatomic, strong)UIButton *finishButton;
@property (nonatomic, strong)UIView *CustomTimeView;
@end

@implementation RadioTimerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor redColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"left.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(handleBackView:)];
    
    self.navigationItem.leftBarButtonItems = @[item];    
    [self.view addSubview:self.tableView];
    self.tapView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
    self.tapView.backgroundColor = [UIColor colorWithRed:105 / 255.0 green:105 / 255.0 blue:105 / 255.0 alpha:0.7];
    //[self.view insertSubview:self.tapView aboveSubview:self.tableView];
   
    self.CustomTimeView = [[UIView alloc]initWithFrame:CGRectMake(0, kDeviceHeight, kDeviceWidth, 220)];
    self.CustomTimeView.backgroundColor = [UIColor colorWithRed:244 / 255.0 green:244 / 255.0 blue:244 / 255.0 alpha:1];
    [self.view addSubview:self.CustomTimeView];
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, kDeviceWidth, 180)];
    //设置本地语言
    self.datePicker.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh"];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    //设置日期显示的格式
    self.datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
    [self.CustomTimeView addSubview:self.datePicker];
    self.cancelButton = [UIButton setButtonWithFrame:CGRectMake(0,0, 60, 40) title:@"取消" target:self action:@selector(handleCancelAction:)];
    self.finishButton = [UIButton setButtonWithFrame:CGRectMake(kDeviceWidth - 60, 0, 60, 40) title:@"确定" target:self action:@selector(handleFinishAction:)];
    [self.CustomTimeView addSubview:self.cancelButton];
    [self.CustomTimeView addSubview:self.finishButton];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (touch.view == self.tapView) {
            [self removeTheCustiomTimerView];
        }
    }
}
//取消自定义定时
- (void)handleCancelAction:(UIButton *)sender {
    [self removeTheCustiomTimerView];
}
//确定自定义时间
- (void)handleFinishAction:(UIButton *)sender {
    for (int i = 0; i < self.dataArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (i == 0) {
            cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"yes.png"]];
        }else {
            cell.accessoryView = nil;
            cell.userInteractionEnabled = YES;
        }
}
    NSDate* date = self.datePicker.date;
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* nowHour = [cal components:NSHourCalendarUnit fromDate:date];
    NSDateComponents* nowMinute = [cal components:NSMinuteCalendarUnit fromDate:date];
    [PlayerManager sharedPlayerManager].totalStopTime = (nowHour.hour * 60 * 60) + (nowMinute.minute * 60);
    if (nowMinute.minute == 0) {
        [PlayerManager sharedPlayerManager].totalStopTime = 60;
    }
    [[PlayerManager sharedPlayerManager] setTheStopTimer];
    [PlayerManager sharedPlayerManager].willStopIndex = 0;
    NSLog(@"%ld,%@", nowHour.hour,nowMinute);
       [self removeTheCustiomTimerView];
}

//显示和移除自定义关闭
- (void)showTheCustomTimerView {
    [self.view insertSubview:self.tapView aboveSubview:self.tableView];
    [UIView animateWithDuration:0.3 animations:^{
        self.CustomTimeView.transform = CGAffineTransformMakeTranslation(0, -220);
    }];
}
- (void)removeTheCustiomTimerView {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.CustomTimeView.transform = CGAffineTransformMakeTranslation(0, 0);
        
    } completion:^(BOOL finished) {
        [self.tapView removeFromSuperview];
    }];
}

- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        self.dataArray = [NSMutableArray arrayWithObjects:@"自定义",@"10秒钟",@"20分钟",@"30分钟" ,@"60分钟",@"关闭",nil];
    }
    return _dataArray;
}
- (UITableView *)tableView {
    if (_tableView == nil) {
        self.tableView = [[UITableView alloc]initWithFrame:kFrame style:UITableViewStyleGrouped];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.scrollEnabled = NO;
        
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
    }
    return _tableView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return  20;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    if (indexPath.row == self.timerCurrent) {
        cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"yes.png"]];
        if (self.timerCurrent != 0) {
            cell.userInteractionEnabled = NO;
        }
    }
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i < self.dataArray.count; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (i == indexPath.row) {
            if (i != 0) {
                 cell.userInteractionEnabled = NO;
                 cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"yes.png"]];
            }
        }else if(indexPath.row != 0){
            cell.accessoryView = nil;
            cell.userInteractionEnabled = YES;
        }
    }
    switch (indexPath.row) {
        case 0:
           // NSLog(@"%ld", indexPath.row);
            [self showTheCustomTimerView];
            break;
        case 1:
            NSLog(@"%ld", indexPath.row);
            [PlayerManager sharedPlayerManager].totalStopTime = 10;
            [PlayerManager sharedPlayerManager].willStopIndex = 1;
            [[PlayerManager sharedPlayerManager] setTheStopTimer];
            break;
        case 2:
            NSLog(@"%ld", indexPath.row);
            [PlayerManager sharedPlayerManager].totalStopTime = 60 * 20;
            [PlayerManager sharedPlayerManager].willStopIndex = 2;
            [[PlayerManager sharedPlayerManager] setTheStopTimer];
            break;
        case 3:
            NSLog(@"%ld", indexPath.row);
            [PlayerManager sharedPlayerManager].totalStopTime = 60 * 30;
            [PlayerManager sharedPlayerManager].willStopIndex = 3;
            [[PlayerManager sharedPlayerManager] setTheStopTimer];
            break;
        case 4:
            NSLog(@"%ld", indexPath.row);
            [PlayerManager sharedPlayerManager].totalStopTime = 60 * 60;
            [PlayerManager sharedPlayerManager].willStopIndex = 4;
            [[PlayerManager sharedPlayerManager] setTheStopTimer];
            break;
        case 5:
            NSLog(@"%ld", indexPath.row);
            [PlayerManager sharedPlayerManager].totalStopTime = 0;
            [PlayerManager sharedPlayerManager].willStopIndex = 5;
            [[PlayerManager sharedPlayerManager] stopSetTheStopTimer];
            break;
        default:
            break;
    }
}








- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = @"定时关闭";
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                                                    NSForegroundColorAttributeName:[UIColor blackColor]};
    self.timerCurrent = [PlayerManager sharedPlayerManager].willStopIndex;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}
- (void)dealloc {
    NSLog(@"aaaa");
}

//返回上一界面
- (void)handleBackView:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
