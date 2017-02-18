//
//  setTableViewCell.h
//  OneProject
//
//  Created by 刘坦 on 16/7/10.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CleanCaches.h"
#import "DNOLabelAnimation.h"
@interface setTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cleanLabel;
@property (nonatomic, strong)DNOLabelAnimation *label;
@end
