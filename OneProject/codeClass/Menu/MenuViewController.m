//
//  MenuViewController.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "MenuViewController.h"
#import "DDMenuController.h"//第三方抽屉控制器
#import "ReadViewController.h"
#import "RadioViewController.h"
#import "TopicViewController.h"
#import "GoodProductViewController.h"
#import "UIButton+Action.h"
#import "LoginViewController.h"
#import "DownLoadController.h"
#import "LikeViewController.h"
#import "AppDelegate.h"
#import <MessageUI/MessageUI.h>
#import "Masonry.h"
#import "setViewController.h"
//引入程序代理类
#import "AppDelegate.h"
@interface MenuViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,MFMessageComposeViewControllerDelegate>
//菜单栏列表
@property (nonatomic ,strong)NSArray *listArray;
//声明头像
@property (nonatomic, strong)UIImageView *headerImageView;
//登录界面
@property (nonatomic, strong)UIButton *loginButton;
@property (nonatomic, strong)UIButton *downLoadButton;
@property (nonatomic, strong)UIButton *likeButton;
@property (nonatomic, strong)UIView *rootView;
@property (nonatomic, strong)UIButton *setButton;

@property (nonatomic, strong)UINavigationController *NAredioVC;
@property (nonatomic, strong)UINavigationController *NTopicVC;
@property (nonatomic, strong)UINavigationController *NGoodVC;
@end

@implementation MenuViewController
- (void)dealloc
{
    NSLog(@"qjqjqjqjqqq");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageBack = [[UIImageView alloc]initWithFrame:self.tableView.frame];
    imageBack.image = [UIImage imageNamed:@"viewImage.jpeg"];
   
    self.tableView.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - 100);
    self.tableView.backgroundView = imageBack;
    self.tableView.separatorColor = [UIColor clearColor];
    //给数组开空间
    self.listArray = @[@"          阅  读", @"          电  台", @"          话  题                ", @"          良  品"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"menuCell"];
    self.tableView.rowHeight = (self.tableView.frame.size.height - 200) / 4;
    //摆放控件
    //头像
    //登录注册按钮
    [self addrootview];
     self.tableView.scrollEnabled = NO;
    
    // 
    RadioViewController *redioVC = [[RadioViewController alloc]init];
    self.NAredioVC = [[UINavigationController alloc]initWithRootViewController:redioVC];
    [redioVC setupHttp];
    //进入界面之前让轮播图计时器停止计时
    redioVC.isFirst = 1;
    TopicViewController *topicVC = [[TopicViewController alloc]init];
    self.NTopicVC = [[UINavigationController alloc]initWithRootViewController:topicVC];
    [topicVC setHttp];
    
    GoodProductViewController *goodVC = [[GoodProductViewController alloc]init];
    self.NGoodVC = [[UINavigationController alloc]initWithRootViewController:goodVC];
    [goodVC requestHttp];
}
//实现登录事件
- (void)handleLoginButtonAction:(UIButton *)sender {
    //一个按钮要做两种功能  登录或者退出登录
    //利用用户的uid来判断当前按钮的状态（因为只有登录成功的用户的uid）
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"uid"]) {
        
        UIAlertController *control = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否退出登录" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [userDefaults removeObjectForKey:@"icon"];
            [userDefaults removeObjectForKey:@"uid"];
            [userDefaults removeObjectForKey:@"auth"];
            [userDefaults removeObjectForKey:@"coverimg"];
            self.headerImageView.image = nil;
            //并且将按钮标题重新置为登录|注册
            [sender setTitle:@"登录|注册" forState:UIControlStateNormal];
        }];
        [control addAction:cancel];
        [control addAction:confirm];
        [self presentViewController:control animated:YES completion:nil];
       
    }else {
        //此时uid 不存在 那意味着用户没有登录
        //跳转到登录界面
        //这里要用根视图控制器来推模态，因为
        LoginViewController *loginVC = [[LoginViewController alloc]init];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:loginVC animated:YES completion:nil];
    }
}
//实现下载事件
- (void)handleDownLoadAction:(UIButton *)sender {
    DownLoadController *downLoadVC = [[DownLoadController alloc]init];
   [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:downLoadVC animated:YES completion:nil];

}
//实现收藏事件
- (void)handleLikeButtonAction:(UIButton *)sender {
    LikeViewController *likeVC = [[LikeViewController alloc]init];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:likeVC animated:YES completion:nil];
}

//头部视图
- (void)addrootview {
    //头视图
        self.rootView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, 200)];
        //self.rootView.backgroundColor  = [UIColor lightGrayColor];
        self.tableView.tableHeaderView = self.rootView;
        //*********摆放控件*******
        self.headerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(25, 70, 80, 80)];
        self.headerImageView.layer.cornerRadius = 39;
        self.headerImageView.layer.masksToBounds = YES;
        self.headerImageView.userInteractionEnabled = YES;
    self.headerImageView.image = [UIImage imageNamed:@"header.png"];
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject];
    NSString *imagePath = [cache stringByAppendingPathComponent:@"images"];
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    NSKeyedUnarchiver *keyedUn = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    UIImage *image = [keyedUn decodeObjectForKey:@"image"];
    [keyedUn finishDecoding];
    if (image) {
        self.headerImageView.image = image;
    }
    
  
    
        UITapGestureRecognizer *headerImageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerimageTapAction:)];
        [self.headerImageView addGestureRecognizer:headerImageTap];
        [self.rootView addSubview:self.headerImageView];
        //登录注册按钮
        self.loginButton = [UIButton setButtonWithFrame:CGRectMake(130, 75, 100, 30) title:@"登录|注册" target:self action:@selector(handleLoginButtonAction:)];
    
    //UIButton *button10086 = [UIButton setButtonWithFrame:CGRectMake(190, 30, 100, 30) title:@"电话|短信" target:self action:@selector(handleCallAction:)];
   // [self.rootView addSubview:button10086];
        [self.rootView addSubview:self.loginButton];
        //下载
       // self.downLoadButton = [UIButton setButtonWithFrame:CGRectMake(80, 60, 80, 30) title:@"下载" target:self action:@selector(handleDownLoadAction:)];
       // [self.view addSubview:self.downLoadButton];
        //喜欢
        self.likeButton = [UIButton setButtonWithFrame:CGRectMake(130, 120, 80, 30) title:@"收藏" target:self action:@selector(handleLikeButtonAction:)];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rootView addSubview:self.likeButton];
    //切圆角
    self.loginButton.layer.cornerRadius = 3;
    self.loginButton.layer.masksToBounds = YES;
    self.downLoadButton.layer.cornerRadius = 3;
    self.downLoadButton.layer.masksToBounds = YES;
    self.likeButton.layer.cornerRadius = 3;
    self.likeButton.layer.masksToBounds = YES;
    
    self.setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.setButton.frame = CGRectMake(20, kDeviceHeight - 30 - 64, 64, 64);
    [self.view addSubview:self.setButton];
    [self.setButton setImage:[UIImage imageNamed:@"set@2x.png"] forState:UIControlStateNormal];
    [self.setButton addTarget:self action:@selector(handleSetAction:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)handleSetAction:(UIButton *)sender {
    setViewController *setVC = [[setViewController alloc]init];
    UINavigationController *setNA = [[UINavigationController alloc]initWithRootViewController:setVC];
    DDMenuController *menuController = ((AppDelegate *)[UIApplication sharedApplication].delegate).ddMenuController;
    [menuController setRootController:setNA animated:YES];
    for (int i = 0; i < self.listArray.count; i++) {
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexP];
            cell.textLabel.textColor = [UIColor grayColor];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //假设登录成功
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]) {
        [self.loginButton setTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"uname"]  forState: UIControlStateNormal];
       // NSString *tempStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"coverimg"];
       // [self.headerImageView setImageWithURL:[NSURL URLWithString:tempStr]];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    }

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    cell.textLabel.text = self.listArray[indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
    cell.textLabel.font = [UIFont systemFontOfSize:25];
    cell.textLabel.textColor = [UIColor grayColor];
    //cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
         cell.textLabel.textColor = [UIColor whiteColor];
    }
    return cell;
}

#pragma mark -- cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //先获取根控制器 DDMenuController
    DDMenuController *menuController = ((AppDelegate *)[UIApplication sharedApplication].delegate).ddMenuController;
    //通过判断cell的下标，来确定应该进入哪一个控制器
    switch (indexPath.row) {
        case 0:{
            [menuController setRootController:self.NAreadVC animated:YES];
        }
            break;
        case 1: {
            [menuController setRootController:self.NAredioVC animated:YES];
        }
            break;
        case 2: {
            [menuController setRootController:self.NTopicVC animated:YES];
        }
            break;
        case 3: {
            [menuController setRootController:self.NGoodVC animated:YES];
        }
            break;
        default:
            break;
    }
    for (int i = 0; i < self.listArray.count; i++) {
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexP];
        if (indexP == indexPath) {
            cell.textLabel.textColor = [UIColor whiteColor];
        }else {
            cell.textLabel.textColor = [UIColor grayColor];
        }
    }
    
}


#pragma mark -- 从相册选择头像
- (void)headerimageTapAction:(UITapGestureRecognizer *)sender {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"选择图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 判断是否支持相机
    
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        __weak MenuViewController *weakSelf = self;
        UIAlertAction *define = [UIAlertAction actionWithTitle:@"从相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
            imagePicker.delegate = weakSelf;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
           [self.view.window.rootViewController presentViewController:imagePicker animated:YES completion:nil];

        }];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIAlertAction *Camera = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
            imagePicker.delegate = weakSelf;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
             [alertC addAction:Camera];
           [self.view.window.rootViewController presentViewController:imagePicker animated:YES completion:nil];
        }];
        
    }
        [alertC addAction:cancel];
        [alertC addAction:define];
    
        [self presentViewController:alertC animated:YES completion:nil];


}
#pragma mark -- 相册选择代理方法

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
   
    UIImage *imagePicker = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"%@", NSHomeDirectory());
    
    NSData *fData = UIImageJPEGRepresentation(imagePicker, 1);
    UIImage *imageF = [UIImage imageWithData:fData];
    self.headerImageView.image = imageF;
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject];
    NSString *imagePath = [cache stringByAppendingPathComponent:@"images"];

    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:imageF forKey:@"image"];
    [archiver finishEncoding];
    BOOL isSuccess = [data writeToFile:imagePath atomically:YES];
    NSLog(isSuccess ? @"yes" : @"no");
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -- 发送短信或拨打电话方法
//- (void)handleCallAction:(UIButton *)sender {
//    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://10086"]];
////    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"sms://10000"]];
//    [self showMessageView];
//}
- (void)showMessageView {
    
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc]init];
        messageVC.messageComposeDelegate = self;
        messageVC.recipients = [NSArray arrayWithObjects:@"10010", nil];
        messageVC.body = @"测试短信";
        [self presentViewController:messageVC animated:YES completion:nil];
    }
    
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:NO completion:nil];
}


@end
