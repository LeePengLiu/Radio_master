//
//  TopicDetailCell.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicDetailModel.h"
@interface TopicDetailCell : UITableViewCell
@property (strong, nonatomic)TopicDetailModel *model;
@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *contectLabel;

@end
