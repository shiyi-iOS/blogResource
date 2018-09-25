//
//  ViewController.m
//  FMDBDemo
//
//  Created by zjjk on 2018/8/30.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import "ViewController.h"

#import <FMDB/FMDB.h>
#import "Student.h"

@interface ViewController ()
{
    FMDatabase *_db;//FMDB对象
    int mark_student;//学生标记
    NSString *_docPath;//沙盒地址（数据库地址）
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //1.获取数据库文件的路径
    _docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"_docPath==%@",_docPath);
    mark_student = 1;
    //设置数据库名称
    NSString *fileName = [_docPath stringByAppendingPathComponent:@"student.sqlite"];
    
    //2.获取数据库
    _db = [FMDatabase databaseWithPath:fileName];
    if ([_db open]) {
        NSLog(@"打开数据库成功");
    } else {
        NSLog(@"打开数据库失败");
    }

    //3.创建表
    BOOL result = [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_student (id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL, sex text NOT NULL);"];
    if (result) {
        NSLog(@"创建表成功");
    } else {
        NSLog(@"创建表失败");
    }
    
//    [_db close];

    for (int i = 0; i < 4; i++) {
        
        //插入数据
        NSString *name = [NSString stringWithFormat:@"测试名字%@",@(mark_student)];
        int age = mark_student;
        NSString *sex = @"男";
        mark_student ++;
        //1.executeUpdate:不确定的参数用？来占位（后面参数必须是oc对象，；代表语句结束）
        BOOL result = [_db executeUpdate:@"INSERT INTO t_student (name, age, sex) VALUES (?,?,?)",name,@(age),sex];
        //2.executeUpdateWithForamat：不确定的参数用%@，%d等来占位 （参数为原始数据类型，执行语句不区分大小写）
        //    BOOL result = [_db executeUpdateWithFormat:@"insert into t_student (name,age, sex) values (%@,%i,%@)",name,age,sex];
        //3.参数是数组的使用方式
        //    BOOL result = [_db executeUpdate:@"INSERT INTO t_student(name,age,sex) VALUES  (?,?,?);" withArgumentsInArray:@[name,@(age),sex]];
        if (result) {
            NSLog(@"插入成功");
        } else {
            NSLog(@"插入失败");
        }

    }
    
    //1.不确定的参数用？来占位 （后面参数必须是oc对象,需要将int包装成OC对象）
    int idNum = 11;
    BOOL result1 = [_db executeUpdate:@"delete from t_student where id = ?",@(idNum)];
    //2.不确定的参数用%@，%d等来占位
    //BOOL result = [_db executeUpdateWithFormat:@"delete from t_student where name = %@",@"王子涵"];
    if (result1) {
        NSLog(@"删除成功");
    } else {
        NSLog(@"删除失败");
    }
    
    //修改学生的名字
    NSString *newName = @"新名字";
    NSString *oldName = @"测试名字2";
    BOOL result2 = [_db executeUpdate:@"update t_student set name = ? where name = ?",newName,oldName];
    if (result2) {
        NSLog(@"修改成功");
    } else {
        NSLog(@"修改失败");
    }

    //查询整个表
    FMResultSet * resultSet = [_db executeQuery:@"select * from t_student"];
    //根据条件查询
    //FMResultSet * resultSet = [_db executeQuery:@"select * from t_student where id < ?", @(4)];
    //遍历结果集合
    while ([resultSet next]) {
        int idNum = [resultSet intForColumn:@"id"];
        NSString *name = [resultSet objectForColumn:@"name"];
        int age = [resultSet intForColumn:@"age"];
        NSString *sex = [resultSet objectForColumn:@"sex"];
        NSLog(@"学号：%@ 姓名：%@ 年龄：%@ 性别：%@",@(idNum),name,@(age),sex);
    }
    
    //如果表格存在 则销毁
//    BOOL result = [_db executeUpdate:@"drop table if exists t_student"];
//    if (result) {
//        NSLog(@"删除表成功");
//    } else {
//        NSLog(@"删除表失败");
//    }

    /* 用事务处理一系列数据库操作，省时效率高 */
    
    //1.开启事务
    [_db beginTransaction];
    NSDate *begin = [NSDate date];
    BOOL rollBack = NO;
    @try {
        //2.在事务中执行任务
        for (int i = 0; i< 500; i++) {
            NSString *name = [NSString stringWithFormat:@"text_%d",i];
            NSInteger age = i;
            NSInteger ID = i *1000;
            
            BOOL result = [_db executeUpdateWithFormat:@"insert into t_student (name,age,id) values (%@,%li,%li)",name,(long)age,(long)ID];
            if (result) {
                NSLog(@"在事务中insert success");
            }
        }
    }
    @catch(NSException *exception) {
        //3.在事务中执行任务失败，退回开启事务之前的状态
        rollBack = YES;
        [_db rollback];
    }
    @finally {
        //4. 在事务中执行任务成功之后
        rollBack = NO;
        [_db commit];
    }
    NSDate *end = [NSDate date];
    NSTimeInterval time = [end timeIntervalSinceDate:begin];
    NSLog(@"在事务中执行插入任务 所需要的时间 = %f",time);

    [_db close];//处理完数据库操作后要关闭
    
    /* https://www.jianshu.com/p/7958d31c2a97 FMDB使用方法 */

}


@end
