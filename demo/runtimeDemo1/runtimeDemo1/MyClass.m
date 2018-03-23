//
//  MyClass.m
//  runtimeDemo1
//
//  Created by zjjk on 2018/3/16.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import "MyClass.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "OtherClass.h"

@implementation MyClass

NSString *mergeString(id self, SEL _cmd, NSString *str1, NSString *str2) {
    
    return [NSString stringWithFormat:@"%@%@",str1,str2];
    
}

#pragma mark - 动态方法解析

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
    //获取方法名
    NSString *selectorString = NSStringFromSelector(sel);
    //根据方法名添加方法
    if ([selectorString isEqualToString:@"mergeString:andStr:"]) {
        class_addMethod([self class], sel, (IMP)mergeString, "@@:@@");
    }
    
    return [super resolveInstanceMethod:sel];
    
}

#pragma mark - 备用接收者

- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    //获取方法名
    NSString *selectorString = NSStringFromSelector(aSelector);
    //根据方法名添加方法
    if ([selectorString isEqualToString:@"arrayWithString:"]) {
        
        OtherClass *otherClass = [[OtherClass alloc] init];
        
        return otherClass;
        
    }
    
    return [super forwardingTargetForSelector:aSelector];
    
}

#pragma mark - 完整消息转发

//必须重写这个方法，为给定的selector提供一个合适的方法签名
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    
    if (!signature) {
        
        if ([OtherClass instancesRespondToSelector:aSelector]) {
            
            signature = [OtherClass instanceMethodSignatureForSelector:aSelector];
            
        }
        
    }
    
    return signature;
    
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    //anInvocation选择将消息转发给其它对象
    if ([OtherClass instancesRespondToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:[[OtherClass alloc] init] ];
    }
    
}

@end
