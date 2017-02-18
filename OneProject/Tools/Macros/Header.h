//
//  Header.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#ifndef Header_h
#define Header_h
//header.h 文件 一般用于添加宏定义 以及一些常用的数据
//屏幕的宽度
#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
//屏幕的高度
#define kDeviceHeight [UIScreen mainScreen].bounds.size.height
//frame适应导航栏64
#define kFrame CGRectMake(0, 64, kDeviceWidth, kDeviceHeight - 64)
//社会化分享
#define UMAPPK   @"564913af67e58ed0d7005bb3"  // 友盟注册的AppKey

#endif /* Header_h */
