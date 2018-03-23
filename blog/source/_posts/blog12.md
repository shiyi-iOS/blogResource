---
title: iOS runtime 总结（七）---- 实际使用
date: 2018-03-22 10:50:14
tags: [runtime]
categories: [技术]
password:
photos:
---

## 引言

> 这里我以工程中使用到一些runtime相关的代码作为例子，供大家参考和使用

## 基础准备


先给NSObject加个分类，封装下方法交换，方便后面使用


![pic1](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog12pic/1.png)


> 下面总结的方法，大家可自行去尝试下效果


## 给button增加个防止连续重复点击的时间差


在 `"UIButton+Swiz.h"` 中：

``` objectivec

#import <UIKit/UIKit.h>

@interface UIButton (Swiz)

//点击间隔
@property (nonatomic, assign) NSTimeInterval timeInterval;

//用于设置单个按钮是否需要timeInterval 
@property (nonatomic, assign) BOOL isIgnore;

@end

```

在 `"UIButton+Swiz.m"` 中：

``` objectivec

#import "UIButton+Swiz.h"
#import "NSObject+Swiz.h"

#define defaultInterval 0.3

@implementation UIButton (Swiz)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self methodSwizzlingWithOriginalSelector:@selector(sendAction:to:forEvent:) bySwizzledSelector:@selector(sure_SendAction:to:forEvent:)];
    });
}

- (void)sure_SendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    
    if (self.isIgnore) {
        //不需要timeInterval 被hook
        [self sure_SendAction:action to:target forEvent:event];
        return;
    }
    
    if ([NSStringFromClass(self.class) isEqualToString:@"UIButton"]) {
        self.timeInterval = self.timeInterval == 0 ? defaultInterval : self.timeInterval;
        if (self.isIgnoreEvent) {
            return;
        }else if (self.timeInterval > 0) {
            [self performSelector:@selector(resetState) withObject:nil afterDelay:self.timeInterval];
        }
        
    }
    
    self.isIgnoreEvent = YES;
    [self sure_SendAction:action to:target forEvent:event];
    
}

- (void)resetState {
    [self setIsIgnoreEvent:NO];
}

#pragma mark - runtime动态绑定一个isIgnoreEvent属性

- (BOOL)isIgnoreEvent {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsIgnoreEvent:(BOOL)isIgnoreEvent {
    objc_setAssociatedObject(self, @selector(isIgnoreEvent), @(isIgnoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - runtime动态绑定自定义的两个属性

- (NSTimeInterval)timeInterval {
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}
- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    objc_setAssociatedObject(self, @selector(timeInterval), @(timeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isIgnore {
    //_cmd == @select(isIgnore); 和set方法里一致
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsIgnore:(BOOL)isIgnore {
    // 注意BOOL类型 需要用OBJC_ASSOCIATION_RETAIN_NONATOMIC 不要用错，否则set方法会赋值出错
    objc_setAssociatedObject(self, @selector(isIgnore), @(isIgnore), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

```

## 给button增加点击范围

在 ` "UIButton+Swiz.h" ` 中加入：

``` objectivec

//设置超出自身范围的额外点击区域
@property (nonatomic, assign) UIEdgeInsets touchAreaInsets;

```

在 ` "UIButton+Swiz.m" ` 中加入：

``` objectivec

- (UIEdgeInsets)touchAreaInsets {
    return [objc_getAssociatedObject(self, _cmd) UIEdgeInsetsValue];
}

- (void)setTouchAreaInsets:(UIEdgeInsets)touchAreaInsets {
    NSValue *value = [NSValue valueWithUIEdgeInsets:touchAreaInsets];
    objc_setAssociatedObject(self, @selector(touchAreaInsets), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIEdgeInsets touchAreaInsets = self.touchAreaInsets;
    CGRect bounds = self.bounds;
    bounds = CGRectMake(bounds.origin.x - touchAreaInsets.left, bounds.origin.y - touchAreaInsets.top, bounds.size.width + touchAreaInsets.left + touchAreaInsets.right, bounds.size.height + touchAreaInsets.top + touchAreaInsets.bottom);
    
    return CGRectContainsPoint(bounds, point);
    
}

```

## 判断类中是否含有该属性

在有些时候我们需要通过KVC去修改某个类的私有变量，但是又不知道该属性是否存在，如果类中不存在该属性，那么通过KVC赋值就会crash，这时我们可以通过运行时进行判断，可在 `NSObject` 的分类中增加如下方法:

``` objectivec

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

```