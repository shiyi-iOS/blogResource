//
//  NSObject+Json.m
//  runtimeDemo1
//
//  Created by zjjk on 2018/3/19.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import "NSObject+Json.h"
#import <objc/runtime.h>

@implementation NSObject (Json)

- (instancetype)initWithDict:(NSDictionary *)dict {
    
    if (self = [self init]) {
        
        NSMutableArray *keys = [NSMutableArray array];
        NSMutableArray *attributes = [NSMutableArray array];
        
        unsigned int outCount;
        
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        for (int i = 0; i < outCount; i++) {
            
            objc_property_t property = properties[i];
            
            NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            [keys addObject:propertyName];
            
            NSString *propertyAttribute = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
            [attributes addObject:propertyAttribute];
            
        }
        free(properties);
        
        for (NSString *key in keys) {
            if ([dict valueForKey:key] == nil) {
                continue;
            }
            [self setValue:[dict valueForKey:key] forKey:key];
        }
        
    }
    return self;
}


@end
