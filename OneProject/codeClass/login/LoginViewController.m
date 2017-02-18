//
//  LoginViewController.m
//  OneProject
//
//  Copyright © 2016年 刘威. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

//返回抽屉文件
- (IBAction)returnButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
//进入注册界面
- (IBAction)registerButtonAction:(UIButton *)sender {
    //使用模态跳转到注册界面
    RegisterViewController *registVC = [[RegisterViewController alloc]init];
    [self presentViewController:registVC animated:YES completion:nil];
}
//登录事件

- (IBAction)loginButtonAction:(UIButton *)sender {
    //需要将账号密码发送给服务器
    [NetworkingManager requestPOSTWithUrlString:KLoginUrl parDic:@{@"email":self.userNameTF.text, @"passwd":self.passwordTF.text} finish:^(id responseObject) {
        //登录成功后。接收并且解析服务器返回的数据。并且存储方便进行下次调用接口时作为参数使用。（比如：评论、收藏等都需要用户信息作为参数）
        NSDictionary *dic = [responseObject objectForKey:@"data"];
        //存储到沙盒中
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:[dic objectForKey:@"auth"] forKey:@"auth"];
        [userDefault setObject:[dic objectForKey:@"coverimg"] forKey:@"coverimg"];
        [userDefault setObject:[dic objectForKey:@"icon"] forKey:@"icon"];
        [userDefault setObject:[dic objectForKey:@"uid"] forKey:@"uid"];
        [userDefault setObject:[dic objectForKey:@"uname"] forKey:@"uname"];
        //最后一步。同步到沙盒中
        [userDefault synchronize];
        //返回上一界面
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } error:^(NSError *error) {
        NSLog(@"登录失败%@",error);
        
    }];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //配置。默认情况输入框上没有字符串的。并且密码输入框加密
    self.userNameTF.text = @"";
    self.passwordTF.text = @"";
    self.passwordTF.secureTextEntry = YES;
}

#pragma mark -- 视图即将出现
- (void)viewWillAppear:(BOOL)animated {
   NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //如果保存了帐号和密码
    if ([userDefault objectForKey:@"userName"]) {
        self.userNameTF.text = [userDefault objectForKey:@"userName"];
        self.passwordTF.text = [userDefault objectForKey:@"password"];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.userNameTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
   
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
