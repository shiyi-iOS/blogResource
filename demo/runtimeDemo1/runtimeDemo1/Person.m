//
//  Person.m
//  runtimeDemo1
//
//  Created by zjjk on 2018/3/16.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import "Person.h"

@implementation Person

- (NSArray *)allPropertiesAndIvars {
    
    unsigned int count;
    
    //获取类的所有属性
    
    //如果没有属性，则count为0，properties为nil
    
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i = 0; i < count; i++) {
        
        // 获取属性名称
        
        const char *propertyName = property_getName(properties[i]);
        
        NSString *name = [NSString stringWithUTF8String:propertyName];
        
        [propertiesArray addObject:name];
        
    }
    
    unsigned int outCount;

    Ivar *ivars = class_copyIvarList([self class], &outCount);
    NSMutableArray *ivarsArray = [NSMutableArray arrayWithCapacity:outCount];

    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        [ivarsArray addObject:key];
    }
    
    free(ivars);
    
    //注意，这里properties是一个数组指针，是C的语法
    
    //我们需要使用free函数来释放内存，否则会造成内存泄露
    
    free(properties);
    
    return @[propertiesArray,ivarsArray];
    
}

- (NSArray *)allProperties {
    
    unsigned int count;
    
    //获取类的所有属性
    
    //如果没有属性，则count为0，properties为nil
    
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i = 0; i < count; i++) {
        
        // 获取属性名称
        
        const char *propertyName = property_getName(properties[i]);
        
        NSString *name = [NSString stringWithUTF8String:propertyName];
        
        [propertiesArray addObject:name];
        
    }
    
    //注意，这里properties是一个数组指针，是C的语法
    
    //我们需要使用free函数来释放内存，否则会造成内存泄露
    
    free(properties);
    
    return propertiesArray;
    
}

- (NSDictionary *)allPropertyNamesAndValues {
    
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    
    unsigned int outCount;
    
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        
        NSString *propertyName = [NSString stringWithUTF8String:name];
        
        id propertyValue = [self valueForKey:propertyName];
        
        if (propertyValue && propertyValue != nil) {
            [resultDict setObject:propertyValue forKey:propertyName];
        }
        
    }
    
    free(properties);
    
    return resultDict;
    
}

- (void)allMethods {
    
    unsigned int  outCount = 0;
    
    Method *methods = class_copyMethodList([self class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        
        Method method = methods[i];
        
        SEL methodSEL = method_getName(method);
        
        const char *name = sel_getName(methodSEL);
        
        NSString *methodName = [NSString stringWithUTF8String:name];
        
        int arguments = method_getNumberOfArguments(method);
        
        NSLog(@"方法名：%@,参数个数： %d",methodName,arguments);
        
    }
    
    //记得释放
    free(methods);
    
}

- (NSArray *)allMemberVariables {
    
    unsigned int count = 0;
    
    Ivar *ivars = class_copyIvarList([self class], &count);
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < count; i++) {
        
        Ivar varibale = ivars[i];
        
        const char *name = ivar_getName(varibale);
        
        NSString *varName = [NSString stringWithUTF8String:name];
        
        [results addObject:varName];
        
    }
    
    free(ivars);
    
    return results;
    
}




@end
