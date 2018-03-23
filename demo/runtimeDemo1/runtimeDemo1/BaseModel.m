//
//  BaseModel.m
//  runtimeDemo1
//
//  Created by zjjk on 2018/3/21.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import "BaseModel.h"
#import <objc/runtime.h>

@implementation BaseModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    unsigned int outCount;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
    free(ivars);
    
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self == [super init]) {
        unsigned int outCount;
        Ivar *ivars = class_copyIvarList([self class], &outCount);
        for (int i = 0; i < outCount; i++) {
            
            Ivar ivar = ivars[i];
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
            
        }
        free(ivars);

    }
    return self;
}

@end
