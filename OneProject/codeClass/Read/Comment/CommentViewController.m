//
//  CommentViewController.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentModel.h"
#import "CommentCell.h"
#import "keyboardTextView.h"//自己封装的textView
@interface CommentViewController ()<UITableViewDataSource,UITableViewDelegate,keboardTextViewDelegate>
//声明数据源数组
@property (nonatomic, strong)NSMutableArray *listCommentArray;
//设置输入框为属性
@property (nonatomic, strong)keyboardTextView *keyboardView;
@property (nonatomic, strong)UITableView *tableView;
@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"发表评论";
    self.listCommentArray = [NSMutableArray array];
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentCell" bundle:nil] forCellReuseIdentifier:@"commentCell"];
    self.tableView.rowHeight = 160;
  //在导航栏上添加返回按钮
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backAction:)];
    //设置为左按钮
    self.navigationItem.leftBarButtonItem = backItem;
    //添加导航栏右按钮 用于发表评论
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc]initWithTitle:@"发表评论" style:UIBarButtonItemStyleDone target:self action:@selector(addItemAction:)];
    //设置为右按钮
    self.navigationItem.rightBarButtonItem = addItem;
    [self requestData];
}
#pragma mark -- 开始封装网络请求
- (void)requestData {
    //获取评论列表，需要登录成功的auth 以及文章的id
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *auth = [userDefaults objectForKey:@"auth"];
    //文章的id
    NSString *contentid = self.tempDetailModel.readid;
    //网络
    [NetworkingManager requestPOSTWithUrlString:KConmentListUrl parDic:@{@"auth":auth,@"contentid":contentid} finish:^(id responseObject) {
        //调用解析方法
        [self handleParserDataWith:responseObject];
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}
//解析网络请求
- (void)handleParserDataWith:(id)responseObject {
    [self.listCommentArray removeAllObjects];
    NSArray *listArray = [[responseObject objectForKey:@"data"] objectForKey:@"list"];
    for (NSDictionary *dic in listArray) {
        CommentModel *model = [[CommentModel alloc]init];
        
        [model setValuesForKeysWithDictionary:dic];
        [self.listCommentArray addObject:model];
            }
    
//回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
   

}
#pragma mark -- 返回上一界面
- (void)backAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -- 发表评论
- (void)addItemAction:(UIBarButtonItem *)sender {
    //弹出输入框操作
    //监测键盘即将出现
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardshow:) name:UIKeyboardWillShowNotification object:nil];
    //键盘即将消失的监测方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    //创建我们的输入框
    if (self.keyboardView == nil) {
        self.keyboardView = [[keyboardTextView alloc]initWithFrame:CGRectMake(0, kDeviceHeight - 39.5, kDeviceWidth, 44)];
        }
        //代理对象
        self.keyboardView.delegate = self;
        [self.keyboardView.textView becomeFirstResponder];
        [self.view addSubview:self.keyboardView];
    
}
#pragma mark -- 实现键盘即将消失的方法
- (void)keyboardHide:(NSNotification *)notifi {
    //获取键盘的高度
    CGRect keyboardRect = [notifi.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];//将字符串转为CGRect的结构体
    //获取键盘收回的时间
    float time = [[notifi.userInfo objectForKey:UIKeyboardWillHideNotification] floatValue];
    //现在使用动画改变keyboardView的位置
    [UIView animateWithDuration:time animations:^{
        self.keyboardView.transform = CGAffineTransformMakeTranslation(0, keyboardRect.size.height);
        self.keyboardView.textView.text = @"";
        //并且从父视图上移除
        [self.keyboardView removeFromSuperview];
    }];
  
}
#pragma mark -- 实现键盘即将出现的方法
- (void)keyboardshow:(NSNotification *)notifi {
    //同样 获取键盘的高度
    CGRect keyboardRect = [notifi.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    //获取键盘弹出所需要的时间
    float time = [[notifi.userInfo objectForKey:UIKeyboardWillShowNotification] floatValue];
    //以此来做动画
    [UIView animateWithDuration:time animations:^{
        self.keyboardView.transform = CGAffineTransformMakeTranslation(0, -keyboardRect.size.height) ;
        
    }];
}
#pragma mark -- 实现textView代理方法
- (void)keyboardView:(UITextView *)aTextView {
    
    //网络请求 向服务器发送评论内容
    //用户登录成功的唯一标识
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *auth = [userDefaults objectForKey:@"auth"];
    //content用户评论发表的言论
    NSString *content = [NSString stringWithFormat:@"%@", aTextView.text];
    //contentid:标识 需要被评论的文章的标识
    NSString *contentid = self.tempDetailModel.readid;
    //开始请求
    [NetworkingManager requestPOSTWithUrlString:KAddConmentUrl parDic:@{@"auth":auth,@"content":content,@"contentid":contentid} finish:^(id responseObject) {
        int result = [[responseObject objectForKey:@"result"] intValue];
        if (result == 1) {
            /*
            //只有服务器给我们评论成功的标识，我们才需要插入cell，否则需要提示用户 评论失败
            //获取评论信息 直接插入cell 不再浪费流量重新请求数据
            CommentModel *model = [[CommentModel alloc]init];
            NSDictionary *dic = @{@"uname":[userDefaults objectForKey:@"uname"], @"icon":[userDefaults objectForKey:@"icon"]};
            NSDictionary *tempDic = @{@"addtime_f":@"刚刚",@"content":content,@"userinfo":dic};
            [model setValuesForKeysWithDictionary:tempDic];
            //加入数据源
            [self.listCommentArray insertObject:model atIndex:0];
            //按下标 插入cell
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
             */
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
              [self requestData];
                
            });

            
        }
    } error:^(NSError *error) {
        
    }];
    
    //释放第一响应者 收回键盘
    [aTextView resignFirstResponder];
    
}

#pragma mark -- 界面即将消失  当用window添加的视图 在退出当前界面时要进行手动释放 因为window一直存在
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    if (self.keyboardView != nil) {
//        [self.keyboardView.textView resignFirstResponder];
//    }
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listCommentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier: @"commentCell" forIndexPath:indexPath];
    CommentModel *model = self.listCommentArray[indexPath.row];
    [cell showDataWithModel:model];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentModel *model = self.listCommentArray[indexPath.row];
    if ([model.userinfo[@"uname"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"uname"]]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentModel *model = self.listCommentArray[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
            //用户登录成功的唯一标识
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *auth = [userDefaults objectForKey:@"auth"];
            //content用户评论发表的言论
            //contentid:标识 需要被评论的文章的标识
            NSString *contentid = self.tempDetailModel.readid;
            //开始请求
        [NetworkingManager requestPOSTWithUrlString:KdelCommentUrl parDic:@{@"auth":auth,@"commentid":model.contentid,@"contentid":contentid} finish:^(id responseObject) {
            int result = [[responseObject objectForKey:@"result"] intValue];
            if (result == 1) {
                [self.listCommentArray removeObject:model];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    
//                    [self requestData];
//                    
//                });
            }
           
        } error:^(NSError *error) {
            NSLog(@"%@", error);
        }];
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
