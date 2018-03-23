//
//  NSObject+Swiz.m
//  runtimeDemo1
//
//  Created by zjjk on 2018/3/23.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import "NSObject+Swiz.h"

@implementation NSObject (Swiz)

/**
 交换方法
 
 @param originalSelector 原方法
 @param swizzledSelector 要替换的新方法
 */
+ (void)methodSwizzlingWithOriginalSelector:(SEL)originalSelector bySwizzledSelector:(SEL)swizzledSelector {
    
    Class class = [self class];
    //原有方法
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    //替换原有方法的新方法
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    IMP originalImp = method_getImplementation(originalMethod);
    char *originalTypes = (char *)method_getTypeEncoding(originalMethod);
    
    IMP swizzledImp = method_getImplementation(swizzledMethod);
    char *swizzledTypes = (char *)method_getTypeEncoding(swizzledMethod);
    
    //先尝试給源SEL添加IMP，这里是为了避免源SEL没有实现IMP的情况
    BOOL didAddMethod = class_addMethod(class,originalSelector, swizzledImp, swizzledTypes);
    
    if (didAddMethod) {
        //添加成功：说明源SEL没有实现IMP，将源SEL的IMP替换到交换SEL的IMP
        class_replaceMethod(class,swizzledSelector, originalImp, originalTypes);
        
    }else {
        //添加失败：说明源SEL已经有IMP，直接将两个SEL的IMP交换即可
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}

/**
 判断类中是否含有该属性

 @param property 属性名称
 @return 判断结果
 */
- (BOOL)hasProperty:(NSString *)property {
    
    BOOL flag = NO;
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        
        const char *propertyName = ivar_getName(ivars[i]);
        NSString *propertyString = [NSString stringWithUTF8String:propertyName];
        if ([propertyString isEqualToString:property]) {
            flag = YES;
            break;
        }
        
    }
    
    return flag;
}

@end
