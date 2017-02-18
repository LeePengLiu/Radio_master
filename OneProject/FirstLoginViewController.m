//
//  FirstLoginViewController.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "FirstLoginViewController.h"
#import "AppDelegate.h"
#import "ReadViewController.h"
@interface FirstLoginViewController ()
@property (nonatomic, strong)NSMutableArray *imageArray;
@property (nonatomic, strong)UIScrollView *scrollView;
@end

@implementation FirstLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    self.scrollView.contentSize = CGSizeMake(kDeviceWidth * 3, kDeviceHeight);
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(kDeviceWidth * i, 0, kDeviceWidth, kDeviceHeight)];
        [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"image%d.jpg", i]]];
        [self.scrollView addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        if (i == 2) {
            //添加轻拍手势
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
            [imageView addGestureRecognizer:tap];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(kDeviceWidth / 2 - 60, kDeviceHeight - 100, 120, 50)];
            label.text = @"点击图片开启心灵之旅";
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            [imageView addSubview:label];
        }
    }
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
}
#pragma mark -- 轻拍手势
- (void)tapAction:(UITapGestureRecognizer *)sender {
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    //1.先获取可视化中的根视图控制器
    ReadViewController *readVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
    //2.添加导航控制器
    UINavigationController *navgation = [[UINavigationController alloc]initWithRootViewController:readVC];
    //3.创建抽屉控制器
    app.ddMenuController = [[DDMenuController alloc]initWithRootViewController:navgation];
    //4.创建MenuViewController(我们自己创建的)
    MenuViewController *menuVC = [[MenuViewController alloc]init];
    //5.将menuVC指定为DDMenu的左控制器
    app.ddMenuController.leftViewController = menuVC;
    //6.最后 把DDMenu设置为根视图控制器
    app.window.rootViewController = app.ddMenuController;
    app.window.backgroundColor = [UIColor whiteColor];
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
