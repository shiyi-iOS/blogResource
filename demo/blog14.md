---
title: iOS多线程 ---- NSOperation使用总结
date: 2018-03-29 14:10:19
tags: [NSOperation, 多线程]
categories: [技术]
password:
photos:
---

## 前言

> 这里先附上iOS中4中多线程开发方式的图表,方便我们理解4中线程之间的关系

![pic1](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog14pic/1.png)

## NSOperation 简介

NSOperation、NSOperationQueue 是苹果提供给我们的一套多线程解决方案。实际上 NSOperation、NSOperationQueue 是基于 GCD 更高一层的封装，完全面向对象。但是比 GCD 更简单易用、代码可读性也更高。

NSOperation、NSOperationQueue优点：

- 可添加完成的代码块，在操作完成后执行。
- 添加操作之间的依赖关系，方便的控制执行顺序。
- 设定操作执行的优先级。
- 可以很方便的取消一个操作的执行。
- 使用 KVO 观察对操作执行状态的更改：isExecuteing、isFinished、isCancelled。

既然是基于 GCD 的更高一层的封装。那么，GCD 中的一些概念同样适用于 NSOperation、NSOperationQueue。在 NSOperation、NSOperationQueue 中也有类似的**任务（操作）**和**队列（操作队列）**的概念。

- **操作（Operation）：**
    - 执行操作的意思，换句话说就是你在线程中执行的那段代码。
    - 在 GCD 中是放在 block 中的。在 NSOperation 中，我们使用 NSOperation 子类 NSInvocationOperation、NSBlockOperation，或者自定义子类来封装操作。

- **操作队列（Operation Queues）：**
    - 这里的队列指操作队列，即用来存放操作的队列。不同于 GCD 中的调度队列 FIFO（先进先出）的原则。NSOperationQueue 对于添加到队列中的操作，首先进入准备就绪的状态（就绪状态取决于操作之间的依赖关系），然后进入就绪状态的操作的开始执行顺序（非结束执行顺序）由操作之间相对的优先级决定（优先级是操作对象自身的属性）。
    - 操作队列通过设置最大并发操作数（maxConcurrentOperationCount）来控制并发、串行。
    - NSOperationQueue 为我们提供了两种不同类型的队列：主队列和自定义队列。主队列运行在主线程之上，而自定义队列在后台执行。

### NSOperation、NSOperationQueue 使用步骤

NSOperation 需要配合 NSOperationQueue 来实现多线程。因为默认情况下，NSOperation 单独使用时系统同步执行操作，配合 NSOperationQueue 我们能更好的实现异步执行。

NSOperation 实现多线程的使用步骤分为三步：

- 创建操作：先将需要执行的操作封装到一个 NSOperation 对象中。
- 创建队列：创建 NSOperationQueue 对象。
- 将操作加入到队列中：将 NSOperation 对象添加到 NSOperationQueue 对象中。

之后系统会自动将 NSOperationQueue 中的 NSOperation 取出来，在新线程中执行操作。

## NSOperation 和 NSOperationQueue 基本使用

### 1.创建操作

NSOperation 是个抽象类，不能用来封装操作。我们只有使用它的子类来封装操作。我们有三种方式来封装操作。

- 使用子类 NSInvocationOperation
- 使用子类 NSBlockOperation
- 自定义继承自 NSOperation 的子类，通过实现内部相应的方法来封装操作。

在不使用 NSOperationQueue，单独使用 NSOperation 的情况下系统同步执行操作，下面我们学习以下操作的三种创建方式。

#### 1.1 使用子类 NSInvocationOperation

``` objectivec

- (void)test1 {
    
    //创建 NSInvocationOperation 对象
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    
    //调用 start 方法开始执行操作
    [op start];
    
}

- (void)task1 {
    
    for (int i = 0; i < 2; i++) {
        
        [NSThread sleepForTimeInterval:2.];//模拟耗时操作
        NSLog(@"====%@",[NSThread currentThread]);//打印当前线程
        
    }
    
}

```

> 输出结果
> 
> 2018-03-29 14:34:29.200501+0800 NSOperation[7616:3267572] ====<NSThread: 0x1016085d0>{number = 1, name = main}
> 
> 2018-03-29 14:34:31.203190+0800 NSOperation[7616:3267572] ====<NSThread: 0x1016085d0>{number = 1, name = main}

可以看到：在没有使用 NSOperationQueue、在主线程中单独使用使用子类 NSInvocationOperation 执行一个操作的情况下，操作是在当前线程执行的，并没有开启新线程。

如果在其他线程中执行操作，则打印结果为其他线程:

``` objectivec

    //开启新线程使用子类 NSInvocationOperation
    [NSThread detachNewThreadSelector:@selector(test1) toTarget:self withObject:nil];

```

> 输出结果
> 
> 2018-03-29 14:38:51.806340+0800 NSOperation[7620:3269315] ====<NSThread: 0x100ba6170>{number = 4, name = (null)}
> 
> 2018-03-29 14:38:53.811905+0800 NSOperation[7620:3269315] ====<NSThread: 0x100ba6170>{number = 4, name = (null)}

可以看到：在其他线程中单独使用子类 NSInvocationOperation，操作是在当前调用的其他线程执行的，并没有开启新线程。

#### 1.2 使用子类 NSBlockOperation

``` objectivec

- (void)test2 {
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        
        for (int i = 0; i < 2; i++) {
            
            [NSThread sleepForTimeInterval:2.];//模拟耗时操作
            NSLog(@"====%@",[NSThread currentThread]);//打印当前线程
            
        }
        
    }];
    
    [op start];
    
}

```

> 输出结果
> 
> 2018-03-29 14:42:55.827989+0800 NSOperation[7624:3270578] ====<NSThread: 0x15dd065d0>{number = 1, name = main}
> 
> 2018-03-29 14:42:57.829362+0800 NSOperation[7624:3270578] ====<NSThread: 0x15dd065d0>{number = 1, name = main}

可以看到：在没有使用 NSOperationQueue、在主线程中单独使用 NSBlockOperation 执行一个操作的情况下，操作是在当前线程执行的，并没有开启新线程。

> 注意：和上边 NSInvocationOperation 使用一样。因为代码是在主线程中调用的，所以打印结果为主线程。如果在其他线程中执行操作，则打印结果为其他线程。

但是，NSBlockOperation 还提供了一个方法 addExecutionBlock:，通过 addExecutionBlock: 就可以为 NSBlockOperation 添加额外的操作。这些操作（包括 blockOperationWithBlock 中的操作）可以在不同的线程中同时（并发）执行。只有当所有相关的操作已经完成执行时，才视为完成。

如果添加的操作多的话，blockOperationWithBlock: 中的操作也可能会在其他线程（非当前线程）中执行，这是由系统决定的，并不是说添加到 blockOperationWithBlock: 中的操作一定会在当前线程中执行。（可以使用 addExecutionBlock: 多添加几个操作试试）。

> 输出结果
> 
> 2018-03-29 14:53:57.490126+0800 NSOperation[7638:3275333] 2---<NSThread: 0x10098a770>{number = 4, name = (null)}
> 
> 2018-03-29 14:53:57.490231+0800 NSOperation[7638:3275269] 1---<NSThread: 0x10080b900>{number = 1, name = main}
> 
> 2018-03-29 14:53:59.491328+0800 NSOperation[7638:3275333] 2---<NSThread: 0x10098a770>{number = 4, name = (null)}
> 
> 2018-03-29 14:53:59.491328+0800 NSOperation[7638:3275269] 1---<NSThread: 0x10080b900>{number = 1, name = main}
> 
> 2018-03-29 14:54:01.492634+0800 NSOperation[7638:3275333] 3---<NSThread: 0x10098a770>{number = 4, name = (null)}
> 
2018-03-29 14:54:01.492647+0800 NSOperation[7638:3275269] 4---<NSThread: 0x10080b900>{number = 1, name = main}

2018-03-29 14:54:03.494205+0800 NSOperation[7638:3275333] 3---<NSThread: 0x10098a770>{number = 4, name = (null)}

2018-03-29 14:54:03.494280+0800 NSOperation[7638:3275269] 4---<NSThread: 0x10080b900>{number = 1, name = main}

2018-03-29 14:54:05.496033+0800 NSOperation[7638:3275333] 5---<NSThread: 0x10098a770>{number = 4, name = (null)}

2018-03-29 14:54:05.496393+0800 NSOperation[7638:3275269] 6---<NSThread: 0x10080b900>{number = 1, name = main}

2018-03-29 14:54:07.497648+0800 NSOperation[7638:3275333] 5---<NSThread: 0x10098a770>{number = 4, name = (null)}

2018-03-29 14:54:07.498156+0800 NSOperation[7638:3275269] 6---<NSThread: 0x10080b900>{number = 1, name = main}

2018-03-29 14:54:09.499295+0800 NSOperation[7638:3275333] 7---<NSThread: 0x10098a770>{number = 4, name = (null)}

2018-03-29 14:54:09.501359+0800 NSOperation[7638:3275269] 8---<NSThread: 0x10080b900>{number = 1, name = main}

2018-03-29 14:54:11.508197+0800 NSOperation[7638:3275333] 7---<NSThread: 0x10098a770>{number = 4, name = (null)}

2018-03-29 14:54:11.508644+0800 NSOperation[7638:3275269] 8---<NSThread: 0x10080b900>{number = 1, name = main}

可以看出：使用子类 NSBlockOperation，并调用方法 AddExecutionBlock: 的情况下，blockOperationWithBlock:方法中的操作 和 addExecutionBlock: 中的操作是在不同的线程中异步执行的。

然而， blockOperationWithBlock:方法中的操作也不一定在当前线程（主线程）中执行的，blockOperationWithBlock: 中的操作也可能会在其他线程（非当前线程）中执行。

一般情况下，如果一个 NSBlockOperation 对象封装了多个操作。NSBlockOperation 是否开启新线程，取决于操作的个数。如果添加的操作的个数多，就会自动开启新线程。当然开启的线程数是由系统来决定的。

#### 1.3 使用自定义继承自 NSOperation 的子类

如果使用子类 NSInvocationOperation、NSBlockOperation 不能满足日常需求，我们可以使用自定义继承自 NSOperation 的子类。可以通过重写 main 或者 start 方法 来定义自己的 NSOperation 对象。重写main方法比较简单，我们不需要管理操作的状态属性 isExecuting 和 isFinished。当 main 执行完返回的时候，这个操作就结束了。

先定义一个继承自 NSOperation 的子类，重写main方法。

``` objectivec

#import "MyOperation.h"

@implementation MyOperation

- (void)main {
    
    if (!self.isCancelled) {
        
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1---%@", [NSThread currentThread]);
        }
        
    }
    
}

```

``` objectivec

- (void)test4 {

    MyOperation *op = [[MyOperation alloc] init];
    [op start];
    
}

```

> 输出结果
> 
> 2018-03-29 15:04:37.414522+0800 NSOperation[7641:3278181] 1---<NSThread: 0x100804bd0>{number = 1, name = main}
> 
2018-03-29 15:04:39.415830+0800 NSOperation[7641:3278181] 1---<NSThread: 0x100804bd0>{number = 1, name = main}

可以看出：在没有使用 NSOperationQueue、在主线程单独使用自定义继承自 NSOperation 的子类的情况下，是在主线程执行操作，并没有开启新线程。

### 2. 创建队列

NSOperationQueue 一共有两种队列：主队列、自定义队列。其中自定义队列同时包含了串行、并发功能。下边是主队列、自定义队列的基本创建方法和特点。

- 主队列
   - 凡是添加到主队列中的操作，都会放到主线程中执行。
  
``` objectivec

    //主队列获取方法
    NSOperationQueue *queue = [NSOperationQueue mainQueue];

```

- 自定义队列（非主队列）
   - 添加到这种队列中的操作，就会自动放到子线程中执行。
   - 同时包含了：串行、并发功能。

``` objectivec

// 自定义队列创建方法
NSOperationQueue *queue = [[NSOperationQueue alloc] init];

```

### 3. 将操作加入到队列中

将创建好的操作加入到队列中去，总共有两种方法：

- `- (void)addOperation:(NSOperation *)op;`
	- 先创建操作，再将创建好的操作加入到创建好的队列中去。

``` objectivec
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

```

> 输出结果
> 
> 2018-03-29 15:16:25.857485+0800 NSOperation[7647:3282773] 3====<NSThread: 0x10108a000>{number = 5, name = (null)}
> 
2018-03-29 15:16:25.857621+0800 NSOperation[7647:3282770] 1====<NSThread: 0x1010714b0>{number = 4, name = (null)}
> 
> 2018-03-29 15:16:25.857512+0800 NSOperation[7647:3282772] 4====<NSThread: 0x1010a6530>{number = 6, name = (null)}
> 
> 2018-03-29 15:16:25.857569+0800 NSOperation[7647:3282771] 2====<NSThread: 0x1011b40b0>{number = 3, name = (null)}
> 
> 2018-03-29 15:16:27.859051+0800 NSOperation[7647:3282771] 2====<NSThread: 0x1011b40b0>{number = 3, name = (null)}
> 
> 2018-03-29 15:16:27.859051+0800 NSOperation[7647:3282773] 3====<NSThread: 0x10108a000>{number = 5, name = (null)}
> 
> 2018-03-29 15:16:27.862702+0800 NSOperation[7647:3282770] 1====<NSThread: 0x1010714b0>{number = 4, name = (null)}
> 
> 2018-03-29 15:16:27.862848+0800 NSOperation[7647:3282772] 4====<NSThread: 0x1010a6530>{number = 6, name = (null)}

- 可以看出：使用 NSOperation 子类创建操作，并使用 addOperation: 将操作加入到操作队列后能够开启新线程，进行并发执行。

- `- (void)addOperationWithBlock:(void (^)(void))block;`
	- 无需先创建操作，在 block 中添加操作，直接将包含操作的 block 加入到队列中

``` objectivec

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

```

> 输出结果
> 
> 2018-03-29 15:21:12.789872+0800 NSOperation[7652:3284661] 2====<NSThread: 0x10065f6f0>{number = 3, name = (null)}
> 
> 2018-03-29 15:21:12.790435+0800 NSOperation[7652:3284658] 1====<NSThread: 0x1006b8bc0>{number = 4, name = (null)}
> 
> 2018-03-29 15:21:12.790890+0800 NSOperation[7652:3284657] 3====<NSThread: 0x100655410>{number = 5, name = (null)}
> 
> 2018-03-29 15:21:14.795218+0800 NSOperation[7652:3284661] 2====<NSThread: 0x10065f6f0>{number = 3, name = (null)}
> 
> 2018-03-29 15:21:14.795510+0800 NSOperation[7652:3284658] 1====<NSThread: 0x1006b8bc0>{number = 4, name = (null)}
> 
> 2018-03-29 15:21:14.795622+0800 NSOperation[7652:3284657] 3====<NSThread: 0x100655410>{number = 5, name = (null)}

- 可以看出：使用 addOperationWithBlock: 将操作加入到操作队列后能够开启新线程，进行并发执行。

## NSOperationQueue 控制串行执行、并发执行

之前我们说过，NSOperationQueue 创建的自定义队列同时具有串行、并发功能，上边我们演示了并发功能，那么他的串行功能是如何实现的？

这里有个关键属性 maxConcurrentOperationCount，叫做最大并发操作数。用来控制一个特定队列中可以有多少个操作同时参与并发执行。

> 注意：这里 maxConcurrentOperationCount 控制的不是并发线程的数量，而是一个队列中同时能并发执行的最大操作数。而且一个操作也并非只能在一个线程中运行。


- 最大并发操作数：`maxConcurrentOperationCount`
	- `maxConcurrentOperationCount` 默认情况下为-1，表示不进行限制，可进行并发执行。
	- `maxConcurrentOperationCount` 为1时，队列为串行队列。只能串行执行。
	- `maxConcurrentOperationCount` 大于1时，队列为并发队列。操作并发执行，当然这个值不应超过系统限制，即使自己设置一个很大的值，系统也会自动调整为 min{自己设定的值，系统设定的默认最大值}。

``` objectivec

- (void)test7 {
    
    //创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //设置最大并发操作数
    queue.maxConcurrentOperationCount = 1; // 串行队列
    // queue.maxConcurrentOperationCount = 2; // 并发队列
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

```

> 最大并发数为1时的输出结果
> 
> 2018-03-29 15:26:24.948020+0800 NSOperation[7655:3286985] 1---<NSThread: 0x111e9cc50>{number = 3, name = (null)}
> 
> 2018-03-29 15:26:26.953245+0800 NSOperation[7655:3286985] 1---<NSThread: 0x111e9cc50>{number = 3, name = (null)}
> 
> 2018-03-29 15:26:28.958958+0800 NSOperation[7655:3286985] 2---<NSThread: 0x111e9cc50>{number = 3, name = (null)}
> 
> 2018-03-29 15:26:30.962255+0800 NSOperation[7655:3286985] 2---<NSThread: 0x111e9cc50>{number = 3, name = (null)}
> 
> 2018-03-29 15:26:32.968364+0800 NSOperation[7655:3286988] 3---<NSThread: 0x111d43de0>{number = 4, name = (null)}
> 
> 2018-03-29 15:26:34.973820+0800 NSOperation[7655:3286988] 3---<NSThread: 0x111d43de0>{number = 4, name = (null)}
> 
> 2018-03-29 15:26:36.979529+0800 NSOperation[7655:3286988] 4---<NSThread: 0x111d43de0>{number = 4, name = (null)}
> 
> 2018-03-29 15:26:38.982150+0800 NSOperation[7655:3286988] 4---<NSThread: 0x111d43de0>{number = 4, name = (null)}

> 最大并发数为2时的输出结果
> 
> 2018-03-29 15:32:15.387645+0800 NSOperation[7658:3288714] 2---<NSThread: 0x14fd054e0>{number = 4, name = (null)}
> 
> 2018-03-29 15:32:15.388613+0800 NSOperation[7658:3288715] 1---<NSThread: 0x14feb8c30>{number = 3, name = (null)}
> 
> 2018-03-29 15:32:17.392895+0800 NSOperation[7658:3288714] 2---<NSThread: 0x14fd054e0>{number = 4, name = (null)}
> 
> 2018-03-29 15:32:17.393010+0800 NSOperation[7658:3288715] 1---<NSThread: 0x14feb8c30>{number = 3, name = (null)}
> 
> 2018-03-29 15:32:19.398230+0800 NSOperation[7658:3288715] 4---<NSThread: 0x14feb8c30>{number = 3, name = (null)}
> 
> 2018-03-29 15:32:19.398230+0800 NSOperation[7658:3288714] 3---<NSThread: 0x14fd054e0>{number = 4, name = (null)}
> 
> 2018-03-29 15:32:21.403261+0800 NSOperation[7658:3288715] 4---<NSThread: 0x14feb8c30>{number = 3, name = (null)}
> 
> 2018-03-29 15:32:21.403433+0800 NSOperation[7658:3288714] 3---<NSThread: 0x14fd054e0>{number = 4, name = (null)}

- 可以看出：当最大并发操作数为1时，操作是按顺序串行执行的，并且一个操作完成之后，下一个操作才开始执行。当最大操作并发数为2时，操作是并发执行的，可以同时执行两个操作。而开启线程数量是由系统决定的，不需要我们来管理。

## NSOperation 操作依赖

通过操作依赖，我们可以很方便的控制操作之间的执行先后顺序，NSOperation 提供了3个接口供我们管理和查看依赖。

- `- (void)addDependency:(NSOperation *)op;` 添加依赖，使当前操作依赖于操作 op 的完成。
- `- (void)removeDependency:(NSOperation *)op;` 移除依赖，取消当前操作对操作 op 的依赖。
- `@property (readonly, copy) NSArray<NSOperation *> *dependencies;` 在当前操作开始执行之前完成执行的所有操作对象数组。

当然，我们经常用到的还是添加依赖操作。现在考虑这样的需求，比如说有 A、B 两个操作，其中 A 执行完操作，B 才能执行操作。

如果使用依赖来处理的话，那么就需要让操作 B 依赖于操作 A。具体代码如下：

``` objectivec

- (void)test8 {
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
        
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
        
    }];
    
    [op2 addDependency:op1];//添加依赖
    
    [queue addOperation:op1];
    [queue addOperation:op2];
    
}

```

> 输出结果
> 
> 2018-04-02 16:20:26.529972+0800 NSOperation[9401:278609] 1---<NSThread: 0x60400027b500>{number = 3, name = (null)}
> 
> 2018-04-02 16:20:28.534974+0800 NSOperation[9401:278609] 1---<NSThread: 0x60400027b500>{number = 3, name = (null)}
> 
> 2018-04-02 16:20:30.538225+0800 NSOperation[9401:278607] 2---<NSThread: 0x604000276180>{number = 4, name = (null)}
> 
> 2018-04-02 16:20:32.542203+0800 NSOperation[9401:278607] 2---<NSThread: 0x604000276180>{number = 4, name = (null)}

- 可以看到：通过添加操作依赖，无论运行几次，其结果都是 op1 先执行，op2 后执行。


## NSOperation 优先级

NSOperation 提供了queuePriority（优先级）属性，queuePriority属性适用于同一操作队列中的操作，不适用于不同操作队列中的操作。默认情况下，所有新创建的操作对象优先级都是NSOperationQueuePriorityNormal。但是我们可以通过setQueuePriority:方法来改变当前操作在同一队列中的执行优先级。

``` objectivec

// 优先级的取值
typedef NS_ENUM(NSInteger, NSOperationQueuePriority) {
    NSOperationQueuePriorityVeryLow = -8L,
    NSOperationQueuePriorityLow = -4L,
    NSOperationQueuePriorityNormal = 0,
    NSOperationQueuePriorityHigh = 4,
    NSOperationQueuePriorityVeryHigh = 8
};

```

