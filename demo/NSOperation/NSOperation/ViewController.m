//
//  ViewController.m
//  NSOperation
//
//  Created by zjjk on 2018/3/29.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import "ViewController.h"
#import "MyOperation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self test7];
    
    //开启新线程使用子类 NSInvocationOperation
//    [NSThread detachNewThreadSelector:@selector(test1) toTarget:self withObject:nil];
    
}

- (void)test7 {
    
    //创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //设置最大并发操作数
//    queue.maxConcurrentOperationCount = 1; // 串行队列
     queue.maxConcurrentOperationCount = 2; // 并发队列
    // queue.maxConcurrentOperationCount = 8; // 并发队列

    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
}

- (void)test6 {
    
    //创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [queue addOperationWithBlock:^{
       
        for (int i = 0; i < 2; i++) {
            
            [NSThread sleepForTimeInterval:2.];//模拟耗时操作
            NSLog(@"1====%@",[NSThread currentThread]);//打印当前线程
            
        }
        
    }];
    
    [queue addOperationWithBlock:^{
        
        for (int i = 0; i < 2; i++) {
            
            [NSThread sleepForTimeInterval:2.];//模拟耗时操作
            NSLog(@"2====%@",[NSThread currentThread]);//打印当前线程
            
        }
        
    }];
    
    [queue addOperationWithBlock:^{
        
        for (int i = 0; i < 2; i++) {
            
            [NSThread sleepForTimeInterval:2.];//模拟耗时操作
            NSLog(@"3====%@",[NSThread currentThread]);//打印当前线程
            
        }
        
    }];
    
}

- (void)test5 {

    //创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];

    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task2) object:nil];

    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        
        for (int i = 0; i < 2; i++) {
            
            [NSThread sleepForTimeInterval:2.];//模拟耗时操作
            NSLog(@"3====%@",[NSThread currentThread]);//打印当前线程
            
        }
        
    }];
    
    [op3 addExecutionBlock:^{
       
        for (int i = 0; i < 2; i++) {
            
            [NSThread sleepForTimeInterval:2.];//模拟耗时操作
            NSLog(@"4====%@",[NSThread currentThread]);//打印当前线程
            
        }
        
    }];
    
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
    
}

- (void)test4 {

    MyOperation *op = [[MyOperation alloc] init];
    [op start];
    
}


- (void)test1 {
    
    //创建 NSInvocationOperation 对象
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    
    //调用 start 方法开始执行操作
    [op start];
    
}

- (void)task1 {
    
    for (int i = 0; i < 2; i++) {
        
        [NSThread sleepForTimeInterval:2.];//模拟耗时操作
        NSLog(@"1====%@",[NSThread currentThread]);//打印当前线程
        
    }
    
}

- (void)task2 {
    
    for (int i = 0; i < 2; i++) {
        
        [NSThread sleepForTimeInterval:2.];//模拟耗时操作
        NSLog(@"2====%@",[NSThread currentThread]);//打印当前线程
        
    }
    
}

- (void)test2 {
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        
        for (int i = 0; i < 2; i++) {
            
            [NSThread sleepForTimeInterval:2.];//模拟耗时操作
            NSLog(@"====%@",[NSThread currentThread]);//打印当前线程
            
        }
        
    }];
    
    [op start];
    
}

/**
 * 使用子类 NSBlockOperation
 * 调用方法 AddExecutionBlock:
 */
- (void)test3 {

    // 1.创建 NSBlockOperation 对象
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    // 2.添加额外的操作
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"5---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"6---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"7---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"8---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    // 3.调用 start 方法开始执行操作
    [op start];
    
}

@end
