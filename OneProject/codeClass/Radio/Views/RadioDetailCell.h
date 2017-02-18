//
//  RadioDetailCell.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioDetailModel.h"
@interface RadioDetailCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *coverimageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *musicVisitLabel;
@property (strong, nonatomic) IBOutlet UILabel *likeLabel;
@property (nonatomic, strong)RadioDetailModel *model;
@end
