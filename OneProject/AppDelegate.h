//
//  AppDelegate.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DDMenuController.h"//即将作为根视图控制器
#import "ReadViewController.h"
#import "MenuViewController.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "FirstLoginViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong)DDMenuController *ddMenuController;
//void(^)(UIEvent *event)是类型
//Block 是变量名
@property (nonatomic, copy)void(^Block)(UIEvent *event);
@property (nonatomic, copy)void(^HeadphoneBlock)(NSInteger isPlay);
@property (nonatomic, copy)void(^ArchiveBlock)();
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

