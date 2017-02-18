//
//  AppDelegate.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "AppDelegate.h"
#import "PlayerManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstLogin"]) {
//        [self setFirstLogin];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstLogin"];
//    }else {
    //1.先获取可视化中的根视图控制器
    
    ReadViewController *readVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
    [readVC requestData];
    //2.添加导航控制器
    UINavigationController *navgation = [[UINavigationController alloc]initWithRootViewController:readVC];
    //3.创建抽屉控制器
    self.ddMenuController = [[DDMenuController alloc]initWithRootViewController:navgation];
    //4.创建MenuViewController(我们自己创建的)
    MenuViewController *menuVC = [[MenuViewController alloc]init];
    menuVC.NAreadVC = navgation;
    //5.将menuVC指定为DDMenu的左控制器
    self.ddMenuController.leftViewController = menuVC;
    //6.最后 把DDMenu设置为根视图控制器
    self.window.rootViewController = self.ddMenuController;
    self.window.backgroundColor = [UIColor whiteColor];

    
    
    
    //友盟 设置AppKey
    [UMSocialData setAppKey:UMAPPK];
    //如果将来要分享到QQ或者微信
    //[UMSocialQQHandler setQQWithAppId:@"" appKey:@"" url:@"分享链接"];
    
//    }
    //创建audio会话对象
    AVAudioSession *session = [AVAudioSession sharedInstance];
    //激活该会话
    [session setActive:YES error:nil];
    //支持后台播放
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //应用程序开始接受远程事件
    [application beginReceivingRemoteControlEvents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)   name:AVAudioSessionRouteChangeNotification object:[
                                                                                                                                                                      AVAudioSession sharedInstance]];
    NSLog(@"%@", NSHomeDirectory());
    
    
    
    return YES;
}
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            //            NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            //插入耳机
            if (self.HeadphoneBlock) {
                self.HeadphoneBlock(0);
            }
            
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            //            NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            //拔出耳机
            if (self.HeadphoneBlock) {
                self.HeadphoneBlock(1);
            }
            
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}
#pragma mark -- 封装第一次登录事件
- (void)setFirstLogin {
    FirstLoginViewController *firstVC = [[FirstLoginViewController alloc]init];
    self.window.rootViewController = firstVC;
}



//接收到远程操控事件（只要在锁屏下，点了播放或者暂停等，都会触发）
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    
    //将事件传回到控制器中，对比，看是触发了什么事件
    if (self.Block) {
        self.Block(event);
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (self.ArchiveBlock) {
        self.ArchiveBlock();
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    if (self.ArchiveBlock) {
        self.ArchiveBlock();
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.baidu.www.OneProject" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"OneProject" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"OneProject.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
