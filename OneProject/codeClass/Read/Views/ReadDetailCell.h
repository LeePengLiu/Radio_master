//
//  ReadDetailCell.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadDetailModel.h"
#import "UserLikeModel.h"
@interface ReadDetailCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *coverimageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (nonatomic, strong)ReadDetailModel *readDetailModel;
//声明方法 将model带进来给cell赋值
- (void)dataForCellWithModel:(ReadDetailModel *)tempModel;
//收藏界面 将实体model带进来给cell赋值
- (void)dataForCellWithLikeModel:(UserLikeModel *)tempModel;
@end
