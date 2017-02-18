//
//  RadioListModel.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RadioListModel : NSObject
@property (nonatomic,strong)NSString *radioid,*title,*coverimg,*desc,*isnew, *uname;
@property (nonatomic, strong)NSNumber *count;
//@property (nonatomic, strong)NSDictionary *userinfo;
@end
