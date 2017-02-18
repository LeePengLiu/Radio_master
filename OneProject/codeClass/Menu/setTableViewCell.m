//
//  setTableViewCell.m
//  OneProject
//
//  Created by 刘国栋 on 16/7/10.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "setTableViewCell.h"

@implementation setTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    CGFloat fileSize = [CleanCaches sizeWithFilePath:[CleanCaches LibraryDirectory]];
    NSDictionary *attribute = @{NSForegroundColorAttributeName : [UIColor redColor]};
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2lfMB", fileSize] attributes:attribute];
    
    self.label = [[DNOLabelAnimation alloc] initWithFrame:CGRectMake(kDeviceWidth - 115, 0, 100, 50) attributedText:string];
    //self.label.textAlignment = NSTextAlignmentRight;
    self.label.font = [UIFont systemFontOfSize:17];
    self.label.rate = 10;

    self.label.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:self.label];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
