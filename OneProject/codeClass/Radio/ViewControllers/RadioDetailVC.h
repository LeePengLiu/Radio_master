//
//  RadioDetailVC.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "BaseViewController.h"
#import "RadioListModel.h"
#import "RadioCircleModel.h"
@interface RadioDetailVC : BaseViewController
@property (nonatomic, strong)RadioListModel *model;
@property (nonatomic, strong)RadioCircleModel *circleModel;
@property (nonatomic, strong)NSString *radioid;
@property (nonatomic, strong)NSString *NVTitle;
@end
