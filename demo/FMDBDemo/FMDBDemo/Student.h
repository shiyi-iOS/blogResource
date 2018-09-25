//
//  Student.h
//  FMDBDemo
//
//  Created by zjjk on 2018/8/30.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Student : NSObject

@property (nonatomic, assign) int id;//学号
@property (nonatomic, strong) NSString *name;//姓名
@property (nonatomic, strong) NSString *sex;//性别
@property (nonatomic, assign) int age;//年龄

@end
