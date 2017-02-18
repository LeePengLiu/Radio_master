//
//  CleanCaches.h
//  TingYinYue
//
//  Created by WangXiaopeng on 16/4/23.
//  Copyright © 2016年 WangXiaopeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CleanCaches : NSObject
/**
 *  返回path路径下的文件大小
 */
+ (double)sizeWithFilePath:(NSString *)path;
/**
 *  删除path路径下的文件
 */
+ (void)clearCachesWithFilePath:(NSString *)path;
/**
 *  删除文件夹下所有文件
 */
+ (void)clearSubFilesWithFilePath:(NSString *)path;
/**
 *  获取沙盒Library文件夹
 */
+ (NSString *)LibraryDirectory;
/**
 *  获取沙盒Docement文件夹
 */
+ (NSString *)DocumentDirectory;
/**
 *  获取沙盒Preference文件夹
 */
+ (NSString *)PreferencePanesDirectory;
/**
 *  获取沙盒Caches文件目录
 */
+ (NSString *)CachesDirectory;

@end
