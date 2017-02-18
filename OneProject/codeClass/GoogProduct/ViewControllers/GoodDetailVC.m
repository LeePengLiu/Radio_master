//
//  GoodDetailVC.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "GoodDetailVC.h"

@interface GoodDetailVC ()<UIWebViewDelegate>
@property (nonatomic, strong)UIWebView *myWebView;
@end

@implementation GoodDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor grayColor];
    self.myWebView = [[UIWebView alloc]initWithFrame:self.view.frame];
    self.myWebView.delegate = self;
    [self.view addSubview:self.myWebView];
    [self.myWebView sizeToFit];
    [self requestHttp];
   
}

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

- (void)requestHttp {
    [NetworkingManager requestPOSTWithUrlString:kReadInfURL parDic:@{@"contentid":self.model.contentid} finish:^(id responseObject) {
       
        [self.myWebView loadHTMLString:[[responseObject objectForKey:@"data"] objectForKey:@"html"] baseURL:nil];
    } error:^(NSError *error) {
        
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
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
