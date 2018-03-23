//
//  UIViewController+Logging.m
//  runtimeDemo1
//
//  Created by zjjk on 2018/3/21.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import "UIViewController+Logging.h"
#import <objc/runtime.h>

@implementation UIViewController (Logging)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        Class targetClass = [self class];
        SEL originalSelector = @selector(viewDidAppear:);
        SEL swizzledSelector = @selector(swizzled_viewDidAppear:);
        swizzleMethod(targetClass, originalSelector, swizzledSelector);
    });
}

void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    IMP swizzledImp = method_getImplementation(swizzledMethod);
    char *swizzledTypes = (char *)method_getTypeEncoding(swizzledMethod);
    
    IMP originalImp = method_getImplementation(originalMethod);
    char *originalTypes = (char *)method_getTypeEncoding(originalMethod);
    
    //给 UIViewController 新增 originalSelector 方法，并指向的当前类中 swizzledSelector 的实现
    BOOL success = class_addMethod(class, originalSelector, swizzledImp, swizzledTypes);
    if (success) {
        // 替换 swizzledSelector 方法为 originalSelector 方法
        class_replaceMethod(class, swizzledSelector, originalImp, originalTypes);
    }else {
        //添加失败，表明已经有这个方法，直接交换
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}

- (void)swizzled_viewDidAppear:(BOOL)animation {
    [self swizzled_viewDidAppear:animation];
    
    NSLog(@"%@ viewDidAppear",NSStringFromClass([self class]));
}

@end
