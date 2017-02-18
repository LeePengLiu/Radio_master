//
//  TopicModel.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "TopicModel.h"

@implementation TopicModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"userinfo"]) {
        NSDictionary *dic = value;
        self.uid = dic[@"uid"];
        self.uname = dic[@"uname"];
        self.icon = dic[@"icon"];
    }
    if ([key isEqualToString:@"counterList"]) {
        NSDictionary *dic = value;
        self.comment = dic[@"comment"];
        self.like = dic[@"like"];
        
        self.view = dic[@"view"];
    }
}
@end
