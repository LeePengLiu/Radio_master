//
//  RadioListModel.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "RadioListModel.h"

@implementation RadioListModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"userinfo"]) {
        self.uname = value[@"uname"];
    }
}



@end
