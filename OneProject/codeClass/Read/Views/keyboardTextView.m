//
//  keyboardTextView.m
//  OneProject
//
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "keyboardTextView.h"

@implementation keyboardTextView
//重写初始化方法
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //初始化textView并且方法当前view上（封装）
        [self initWithTextViewWithFrame:CGRectMake(5, 5, self.frame.size.width - 10, self.frame.size.height - 10)];
    }
    return self;
}
#pragma mark -- 封装textView
- (void)initWithTextViewWithFrame:(CGRect)frame {
    self.textView = [[UITextView alloc]initWithFrame:frame];
    //遵循代理方法
    self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor lightGrayColor];
    //键盘上的按钮改为send 发送
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.font = [UIFont systemFontOfSize:18];
    self.textView.layer.cornerRadius = 5;
    self.textView.layer.masksToBounds = YES;
    [self addSubview:self.textView];
}

#pragma mark --  TextViewDelegate -- 
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //点击键盘上的发送键（换行）那个按钮
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(keyboardView:)]) {
            [self.delegate keyboardView:textView];
        }
    }
    
    return YES;
}

//输入框发生变化会立马执行的方法
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.frame.size.height > 45) {
        return;
    }
    //输入框内容发生变化，我们要根据变化来修改输入框的大小
    NSString *str = textView.text;
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:18]};
    CGSize size = [str sizeWithAttributes:dic];
    //把textView的宽度取出
    CGFloat width = self.textView.frame.size.width;
    if (size.width > width) {
        //如果输入的字符串大于本身的宽 就进行高度调整
        self.isChange = YES;//用来记录frame是否调整过
        CGRect keyFrame = self.frame;
        keyFrame.size.height += 23;
        keyFrame.origin.y -= 23;//向上移动
        self.frame = keyFrame;
        CGRect textFrame = self.textView.frame;
        textFrame.size.height += 23;
        self.textView.frame = textFrame;
    }
    
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    self.isChange = NO;
}




@end
