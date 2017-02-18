//
//  TopicDetailModel.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "TopicDetailModel.h"

@implementation TopicDetailModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"userinfo"]) {
        NSDictionary *dic = value;
        self.uname = [dic objectForKey:@"uname"];
        self.icon = [dic objectForKey:@"icon"];
    }
}
@end
