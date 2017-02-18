//
//  CleanCaches.m
//  TingYinYue
//
//  Created by WangXiaopeng on 16/4/23.
//  Copyright © 2016年 WangXiaopeng. All rights reserved.
//

#import "CleanCaches.h"
/**
 *  清理缓存
 */
@implementation CleanCaches
/**
 *  返回path路径下的文件大小
 */
+ (double)sizeWithFilePath:(NSString *)path {
    //1.文件管理器
    NSFileManager *manager = [NSFileManager defaultManager];
    //2.检测路径的合理性
    BOOL dir = NO;
    BOOL isExist = [manager fileExistsAtPath:path isDirectory:&dir];
    if (!isExist) {
        return 0;
    }
    //3.判断是否为文件夹
    if (dir) {//如果是文件夹 遍历文件夹中所有的文件
        //这个方法能获得这个文件夹下所有的子路径(直接、间接子路径)
        NSArray *subpaths = [manager subpathsAtPath:path];
        int totalSize = 0;
        for (NSString *subpath in subpaths) {
            NSString *fullPath = [path stringByAppendingPathComponent:subpath];
            BOOL dir = NO;
            [manager fileExistsAtPath:fullPath isDirectory:&dir];
            if (!dir) {//如果子路径是个文件
                NSDictionary *attrs = [manager attributesOfItemAtPath:fullPath error:nil];
                totalSize += [attrs[NSFileSize] intValue];
            }
        }
        return totalSize / (1024 * 1024.0);
    } else {
        //文件
        NSDictionary *attrs = [manager attributesOfItemAtPath:path error:nil];
        return [attrs[NSFileSize] intValue] / (1024 * 1024.0);
    }
    
}
/**
 *  删除path路径下的文件
 */
+ (void)clearCachesWithFilePath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:path error:nil];
}
/**
 *  删除文件夹下所有文件
 */
+ (void)clearSubFilesWithFilePath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *allPaths = [manager subpathsAtPath:path];
    for (NSString *str in allPaths) {
        [manager removeItemAtPath:[path stringByAppendingPathComponent:str] error:nil];
    }
}
/**
 *  获取沙盒Library文件夹
 */
+ (NSString *)LibraryDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
}
/**
 *  获取沙盒Docement文件夹
 */
+ (NSString *)DocumentDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}
/**
 *  获取沙盒Preference文件夹
 */
+ (NSString *)PreferencePanesDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSUserDomainMask, YES) firstObject];
}
/**
 *  获取沙盒Caches文件目录
 */
+ (NSString *)CachesDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}




@end
