//
//  ReadInfoDetailVC.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "ReadInfoDetailVC.h"
#import "CommentViewController.h"
#import "LoginViewController.h"

#import "UserLikeModel.h"
//引入友盟
#import "UMSocial.h"
@interface ReadInfoDetailVC ()<UIWebViewDelegate,UMSocialUIDelegate>
@property (nonatomic, strong)UIWebView *myWebView;
@end

@implementation ReadInfoDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [backImageView setImage:[UIImage imageNamed:@"timg.jpg"]];
    [self.view addSubview:backImageView];
    
    //返回上一界面
     UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(handleBackView:)];
    
    self.navigationItem.leftBarButtonItems = @[item];
    
    
    //创建对象
    self.myWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight - 64)];
    [self.view addSubview:self.myWebView];
    //重点
    //1.自适应屏幕大小
    [self.myWebView sizeToFit];
    //2.设置代理对象
    self.myWebView.delegate = self;
    //数据请求
    [self requestData];
    UIBarButtonItem *collectItem = [[UIBarButtonItem alloc] initWithTitle:@"收藏" style:UIBarButtonItemStyleDone target:self action:@selector(collectAction:)];
    collectItem.tintColor = [UIColor lightGrayColor];
     UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithTitle:@"评论" style:UIBarButtonItemStyleDone target:self action:@selector(commentAction:)];
    commentItem.tintColor = [UIColor lightGrayColor];

    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStyleDone target:self action:@selector(shareAction:)];
    shareItem.tintColor = [UIColor lightGrayColor];

    self.navigationItem.rightBarButtonItems = @[collectItem, commentItem, shareItem];
    
    //查询数据库是否收藏过
    AppDelegate *myApp = [UIApplication sharedApplication].delegate;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"UserLikeModel"];
   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"coverimg = %@ and title = %@", self.tempModel.coverimg, self.tempModel.title];
    request.predicate = predicate;
    NSArray *array = [myApp.managedObjectContext executeFetchRequest:request error:nil];
    if (array.count == 0) {
        collectItem.title = @"收藏";
    }else {
        collectItem.title = @"取消收藏";
    }
    
}

#pragma mark -- 收藏
- (void)collectAction:(UIBarButtonItem *)sender {
    //先获取上下文管理器
    NSManagedObjectContext *managedContext = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    
    if ([sender.title isEqualToString:@"取消收藏"]) {
        //代表已经收藏过 那么该删除数据了
        //删除数据
        //1.查询这张表
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserLikeModel"];
        //2.设置谓词(查询当条数据)
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"coverimg = %@ and title = %@", self.tempModel.coverimg, self.tempModel.title];
        //3.将谓词赋值给查询对象
        fetchRequest.predicate = predicate;
        //4.获取查询结果
        NSArray *array = [managedContext executeFetchRequest:fetchRequest error:nil];
        //5.删除数据s
        [managedContext deleteObject:[array firstObject]];
        //6.刷新数据库
        [managedContext save:nil];
        //7.将sender的title设置为收藏
        sender.title = @"收藏";
        
    }else {
        //没有收藏过, 要添加数据(title = 收藏)
        //添加数据
        UserLikeModel *likeModel = [NSEntityDescription insertNewObjectForEntityForName:@"UserLikeModel" inManagedObjectContext:managedContext];
        //赋值操作
        likeModel.title = self.tempModel.title;
        likeModel.coverimg = self.tempModel.coverimg;
        likeModel.uname = self.tempModel.name;
        likeModel.readid = self.tempModel.readid;
        likeModel.content = self.tempModel.content;
        //保存
        [managedContext save:nil];
        //将title改为取消收藏
        sender.title = @"取消收藏";
        
    }
   
    
    
}


#pragma mark  -- 评论
- (void)commentAction:(UIBarButtonItem *)sender {
    
    //想要进行评论界面，就要判断auth这个值是否存在,它是登录成功后的返回值，所以，如果此值存在，就评论，如果不在就跳转到登录界面
    NSUserDefaults *userDfaults = [NSUserDefaults standardUserDefaults];
    if ([userDfaults objectForKey:@"auth"] ) {
        //存在 就跳转到评论界面
        CommentViewController *commentVC  = [[CommentViewController alloc]init];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:commentVC];
        //属性传值
        commentVC.tempDetailModel = self.tempModel;
        [self presentViewController:navigation animated:YES completion:nil];
    }else {
        //跳转到登录界面
        LoginViewController *loginVC = [[LoginViewController alloc]init];
        
        [self.view.window.rootViewController presentViewController:loginVC animated:YES completion:nil];
    }
}

#pragma mark -- 分享
- (void)shareAction:(UIBarButtonItem *)sender {
    [UMSocialSnsService presentSnsIconSheetView:self appKey:UMAPPK shareText:@"分享内容http://pianke.file.alimmdn.com/upload/20160428/f9c3893caefa4e2e8643e70e03035d66.MP3" shareImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.tempModel.coverimg]]] shareToSnsNames:@[UMShareToSina,UMShareToDouban] delegate:self];
}




#pragma mark -- 实现web代理方法
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *str=[NSString stringWithFormat:@"var script = document.createElement('script');"
       "script.type = 'text/javascript';"
         "script.text = \"function ResizeImages() { "
         "var myimg,oldwidth;"
          "var maxwidth =%f;"// UIWebView中显示的图片宽度
          "for(i=0;i <document.images.length;i++){"
            "myimg = document.images[i];"
           "if(myimg.width > maxwidth){"
            "oldwidth = myimg.width;"
             "myimg.width = maxwidth;"
              "}"
               "}"
              "}\";"
             "document.getElementsByTagName('head')[0].appendChild(script);",self.view.frame.size.width-15];
 [webView stringByEvaluatingJavaScriptFromString:str];
 [webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
}

#pragma mark -- 网络请求
- (void)requestData {
    NSString *contentid = nil;
    if (self.typeID) {
        contentid = self.typeID;
    }else {
        contentid = self.tempModel.readid;
    }
    [NetworkingManager requestPOSTWithUrlString:kReadInfURL parDic:@{@"contentid":contentid} finish:^(id responseObject) {
        [self.myWebView loadHTMLString:[[responseObject objectForKey:@"data"] objectForKey:@"html"] baseURL:nil];
         
    } error:^(NSError *error) {
        
    }];
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
