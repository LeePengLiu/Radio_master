//
//  RadioDetailModel.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "RadioDetailModel.h"
#import <objc/runtime.h>
@implementation RadioDetailModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    //NSLog(@"出错了%@", key);

}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    //利用runtime动态获取当前类中的所有实例变量
    unsigned int count = 0;
    Ivar *instances = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        //获取数组中的每一个实例变量
        Ivar ivar = instances[i];
        //获取每一个实例变量的名字
        const char *cString = ivar_getName(ivar);
        //把C语音中字符串类型转成OC字符串类型
        //NSString *string = [NSString stringWithUTF8String:cString];
        NSString *OCString = [[NSString alloc]initWithCString:cString encoding:NSUTF8StringEncoding];
        //NSLog(@"c:%s, oc:%@", cString, OCString);
        id value = [self valueForKey:OCString];
        [aCoder encodeObject:value forKey:OCString];
    }
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar *instances = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i++) {
            Ivar ivar = instances[i];
            const char *cString = ivar_getName(ivar);
            NSString *OCString = [[NSString alloc]initWithCString:cString encoding:NSUTF8StringEncoding];
                id value = [aDecoder decodeObjectForKey:OCString];
                [self setValue:value forKey:OCString];
        }
    }
    return self;
}

@end
