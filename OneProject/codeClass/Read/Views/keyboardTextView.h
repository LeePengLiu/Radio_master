//
//  keyboardTextView.h
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol keboardTextViewDelegate <NSObject>

//代理对象需要实现的方法
- (void)keyboardView:(UITextView *)aTextView;

@end


@interface keyboardTextView : UIView<UITextViewDelegate>
@property (nonatomic, strong)UITextView *textView;
//声明代理属性
@property (nonatomic, strong)id<keboardTextViewDelegate> delegate;
//监测输入是否改变
@property (nonatomic, assign)BOOL isChange;
@end
