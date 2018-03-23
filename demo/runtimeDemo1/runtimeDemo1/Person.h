//
//  Person.h
//  runtimeDemo1
//
//  Created by zjjk on 2018/3/16.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface Person : NSObject

{
    NSString *_variableString;
}

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, assign) NSUInteger age;

@property (nonatomic, assign) BOOL sex;

//获取对象的所有属性名
- (NSArray *)allProperties;

//获取对象的所有属性名和属性值
- (NSDictionary *)allPropertyNamesAndValues;

//获取对象的所有方法名
- (void)allMethods;

//获取对象的成员变量名称
- (NSArray *)allMemberVariables;

- (NSArray *)allPropertiesAndIvars;

@end
