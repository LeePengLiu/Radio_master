//
//  CommentCell.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentModel.h"
@interface CommentCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;

//声明方法 内部给cell赋值
- (void)showDataWithModel:(CommentModel *)tempModel;
@end
