//
//  UIButton+Custom.m
//  runtimeDemo1
//
//  Created by zjjk on 2018/3/21.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import "UIButton+Custom.h"
#import <objc/runtime.h>

@implementation UIButton (Custom)

- (void)setNumber:(NSString *)number {
    //这里使用方法的指针地址作为唯一的key
    objc_setAssociatedObject(self, @selector(number), number, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)number {
    return objc_getAssociatedObject(self, @selector(number));
}

@end
