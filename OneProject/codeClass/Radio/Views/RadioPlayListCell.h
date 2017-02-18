//
//  RadioPlayListCell.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioDetailModel.h"

@interface RadioPlayListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *singerLabel;
@property (nonatomic, strong) RadioDetailModel *model;
@end
