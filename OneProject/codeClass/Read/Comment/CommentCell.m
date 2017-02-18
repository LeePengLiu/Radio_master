//
//  CommentCell.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell


//实现赋值方法
- (void)showDataWithModel:(CommentModel *)tempModel {
    if (tempModel) {
        NSString *iconURL = [tempModel.userinfo objectForKey:@"icon"];
        NSString *nameStr = [tempModel.userinfo objectForKey:@"uname"];
        //赋值开始
        [self.headerImageView setImageWithURL:[NSURL URLWithString:iconURL]];
        self.nameLabel.text = nameStr;
        self.timeLabel.text = tempModel.addtime_f;
        self.contentLabel.text = tempModel.content;
    }
}


- (void)awakeFromNib {
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

   
}

@end
