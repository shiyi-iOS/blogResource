//
//  Person+associative.m
//  runtimeDemo1
//
//  Created by zjjk on 2018/3/16.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import "Person+associative.h"
#import <objc/runtime.h>

@implementation Person (associative)

- (void)setSonName:(NSString *)sonName {
    
    objc_setAssociatedObject(self, @selector(sonName), sonName, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}

- (NSString *)sonName {
    
    NSObject *obj = objc_getAssociatedObject(self, @selector(sonName));
    
    if (obj && [obj isKindOfClass:[NSString class]]) {
        return  (NSString *)obj;
    }
    
    return nil;
    
}

@end
