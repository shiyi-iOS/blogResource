//
//  NSObject+Swiz.h
//  runtimeDemo1
//
//  Created by zjjk on 2018/3/23.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface NSObject (Swiz)

/**
 交换方法

 @param originalSelector 原方法
 @param swizzledSelector 要替换的新方法
 */
+ (void)methodSwizzlingWithOriginalSelector:(SEL)originalSelector bySwizzledSelector:(SEL)swizzledSelector;

/**
 判断类中是否含有该属性
 
 @param property 属性名称
 @return 判断结果
 */
- (BOOL)hasProperty:(NSString *)property;

@end
