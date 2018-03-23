//
//  UIButton+Swiz.m
//  runtimeDemo1
//
//  Created by zjjk on 2018/3/23.
//  Copyright © 2018年 zjjk. All rights reserved.
//

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

@end
