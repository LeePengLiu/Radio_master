//
//  GoodListCell.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodListModel.h"
@interface GoodListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *coverimgVIew;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UILabel *comment;
@property (strong, nonatomic) IBOutlet UILabel *likeLabel;
@property (nonatomic, strong)GoodListModel *model;
@end
