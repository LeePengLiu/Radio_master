//
//  RegisterViewController.m
//  OneProject
//
//  Copyright © 2016年 刘威. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()
//声明gender属性 用来接收按钮事件结束后的
@property (nonatomic, assign)NSInteger gender;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
//男孩
//- (IBAction)boyButtonAction:(UIButton *)sender {
//    sender.backgroundColor = [UIColor blueColor];
//    self.girlButton.backgroundColor = [UIColor whiteColor];
//}
//- (IBAction)girlButtonAction:(UIButton *)sender {
//    sender.backgroundColor = [UIColor blueColor];
//    self.boyButton.backgroundColor = [UIColor whiteColor];
//}

//注册
- (IBAction)registerButtonAction:(UIButton *)sender {
    [NetworkingManager requestPOSTWithUrlString:KRegisUrl parDic:@{@"email":self.userNameTF.text, @"passwd":self.passwordTF.text,@"gender":@(self.gender),@"uname":self.nickNameTF.text} finish:^(id responseObject) {
        //如果注册成功 就让注册界面收回 并且保存帐号密码信息 方便用户登录界面使用
        
        int result = [[responseObject objectForKey:@"result"] intValue];
        if (result == 1) {
            //注册成功,存储用户的帐号和密码（一般在登录成功的时候存储uid 头像等个人信息）
            //如果注册失败 就给出提示框，将后台返回给我的错误信息告诉用户
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:self.userNameTF.text forKey:@"userName"];
            [userDefaults setObject:self.passwordTF.text forKey:@"password"];
            [userDefaults synchronize];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else {
            NSString *message = [[responseObject objectForKey:@"data"] objectForKey:@"msg"];
            UIAlertController *control = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil];
            [control addAction:cancel];
            [self presentViewController:control animated:YES completion:nil];
        }
    } error:^(NSError *error) {
        NSLog(@"%@", error);
        
        
        
         }];
}

- (IBAction)returnLoginAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.userNameTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self.nickNameTF resignFirstResponder];
}



@end
