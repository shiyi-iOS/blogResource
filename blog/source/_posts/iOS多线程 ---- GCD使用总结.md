---
title: iOS多线程 ---- GCD使用总结
date: 2018-03-14 09:21:34
tags: [GCD, 多线程]
categories: [技术]
password:
---

## 一、GCD简介

> Grand Central Dispatch(GCD) 是 Apple 开发的一个多核编程的较新的解决方法。它主要用于优化应用程序以支持多核处理器以及其他对称多处理系统。它是一个在线程池模式的基础上执行的并发任务。在 Mac OS X 10.6 雪豹中首次推出，也可在 iOS 4 及以上版本使用。

**使用GCD的好处**

- GCD 能通过推迟昂贵计算任务并在后台运行它们来改善你的应用的响应性能
- GCD 会自动利用更多的 CPU 内核（比如双核、四核）
- GCD 会自动管理线程的生命周期（创建线程、调度任务、销毁线程）

## 二、GCD 常用术语
 
在 GCD 中，我们通常在 block 里执行任务代码，执行任务有两种方式：**同步执行（sync）**和**异步执行（async）**。两者的主要区别是：**是否等待队列的任务执行结束，以及是否具备开启新线程的能力。**

- **同步执行（sync）：**
	- 同步添加任务到指定的队列中，在添加的任务执行结束之前，会一直等待，直到队列里面的任务完成之后再继续执行。
	- 只能在当前线程中执行任务，不具备开启新线程的能力。
- **异步执行（async）：**
	- 异步添加任务到指定的队列中，它不会做任何等待，可以继续执行任务。
	- 可以在新的线程中执行任务，具备开启新线程的能力。

举个简单例子：你要打电话给小明和小白。

同步执行就是，你打电话给小明的时候，不能同时打给小白，等到给小明打完了，才能打给小白（等待任务执行结束）。而且只能用当前的电话（不具备开启新线程的能力）。

而异步执行就是，你打电话给小明的时候，不等和小明通话结束，还能直接给小白打电话，不用等着和小明通话结束再打（不用等待任务执行结束）。除了当前电话，你还可以使用其他所能使用的电话（具备开启新线程的能力）。

> 注意：异步执行（async）虽然具有开启新线程的能力，但是并不一定开启新线程。这跟任务所指定的队列类型有关（下面会讲）。

**队列（Dispatch Queue）：** 这里的队列指执行任务的等待队列，即用来存放任务的队列。队列是一种特殊的线性表，采用 FIFO（先进先出）的原则，即新任务总是被插入到队列的末尾，而读取任务的时候总是从队列的头部开始读取。每读取一个任务，则从队列中释放一个任务。队列的结构可参考下图：

![picture1](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog4pic/1.png)

在 GCD 中有两种队列：**串行队列**和**并发队列**。两者都符合 FIFO（先进先出）的原则。两者的主要区别是：**执行顺序不同，以及开启线程数不同。**

- 串行队列（Serial Dispatch Queue）：
 
	- 每次只有一个任务被执行。让任务一个接着一个地执行。（只开启一个线程，一个任务执行完毕后，再执行下一个任务）

- 并发队列（Concurrent Dispatch Queue）：

	- 可以让多个任务并发（同时）执行。（可以开启多个线程，并且同时执行任务）

## 三、GCD提供的方法

GCD 的使用步骤其实很简单，只有两步:

1. 创建一个队列（串行队列或并发队列）
	
2. 将任务追加到任务的等待队列中，然后系统就会根据任务类型执行任务（同步执行或异步执行）

### 1. 队列的创建/获取方法

- 可以使用 `dispatch_queue_create` 来创建队列，需要传入两个参数，第一个参数表示队列的唯一标识符，用于 DEBUG，可为空，Dispatch Queue 的名称推荐使用应用程序 ID 这种逆序全程域名；第二个参数用来识别是串行队列还是并发队列。`DISPATCH_QUEUE_SERIAL` 表示串行队列，`DISPATCH_QUEUE_CONCURRENT` 表示并发队列。

``` objectivec
    // 串行队列的创建方法
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
    // 并发队列的创建方法
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_CONCURRENT);
```

- 对于串行队列，GCD 提供了的一种特殊的串行队列：**主队列（Main Dispatch Queue）**。
	- 所有放在主队列中的任务，都会放到主线程中执行。
	- 可使用 `dispatch_get_main_queue()` 获得主队列。

``` objectivec
	// 主队列的获取方法
	dispatch_queue_t queue = dispatch_get_main_queue();
	
```

- 对于并发队列，GCD 默认提供了**全局并发队列（Global Dispatch Queue）**。

	- 可以使用 `dispatch_get_global_queue` 来获取。需要传入两个参数。第一个参数表示队列优先级，一般用 `DISPATCH_QUEUE_PRIORITY_DEFAULT` 。第二个参数暂时没用，用 `0` 即可。

``` objectivec
	// 全局并发队列的获取方法
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

```

### 2. 任务的创建方法

GCD 提供了同步执行任务的创建方法 `dispatch_sync` 和异步执行任务创建方法 `dispatch_async` 。

``` objectivec
	// 同步执行任务创建方法
	dispatch_sync(queue, ^{
	    // 这里放同步执行任务代码
	});
	// 异步执行任务创建方法
	dispatch_async(queue, ^{
	    // 这里放异步执行任务代码
	});

```

虽然使用 GCD 只需两步，但是既然我们有两种队列（串行队列/并发队列），两种任务执行方式（同步执行/异步执行），那么我们就有了四种不同的组合方式。这四种不同的组合方式是：

> 1. 同步执行 + 并发队列
> 2. 异步执行 + 并发队列
> 3. 同步执行 + 串行队列
> 4. 异步执行 + 串行队列

实际上，刚才还说了两种特殊队列：全局并发队列、主队列。全局并发队列可以作为普通并发队列来使用。但是主队列因为有点特殊，所以我们就又多了两种组合方式。这样就有六种不同的组合方式了。

> 1. 同步执行 + 主队列
> 2. 异步执行 + 主队列

## 四、GCD的基本使用

### 1. 同步执行 + 并发队列

- 在当前线程中执行任务，不会开启新线程，执行完一个任务，再执行下一个任务。

``` objectivec
/**
 * 同步执行 + 并发队列
 * 特点：在当前线程中执行任务，不会开启新线程，执行完一个任务，再执行下一个任务。
 */
- (void)syncConcurrent {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"syncConcurrent---begin");
    
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_sync(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    NSLog(@"syncConcurrent---end");
}

```

> 输出结果：
> 
> 2018-03-14 10:48:58.322012+0800 GCDDemo1[1849:70838] currentThread---<NSThread: 0x60400006b940>{number = 1, name = main}
> 2018-03-14 10:48:58.322214+0800 GCDDemo1[1849:70838] syncConcurrent---begin
> 2018-03-14 10:49:00.322971+0800 GCDDemo1[1849:70838] 1---<NSThread: 0x60400006b940>{number = 1, name = main}
> 2018-03-14 10:49:02.323947+0800 GCDDemo1[1849:70838] 1---<NSThread: 0x60400006b940>{number = 1, name = main}
> 2018-03-14 10:49:04.324712+0800 GCDDemo1[1849:70838] 2---<NSThread: 0x60400006b940>{number = 1, name = main}
> 2018-03-14 10:49:06.325088+0800 GCDDemo1[1849:70838] 2---<NSThread: 0x60400006b940>{number = 1, name = main}
> 2018-03-14 10:49:08.325530+0800 GCDDemo1[1849:70838] 3---<NSThread: 0x60400006b940>{number = 1, name = main}
> 2018-03-14 10:49:10.326147+0800 GCDDemo1[1849:70838] 3---<NSThread: 0x60400006b940>{number = 1, name = main}
> 2018-03-14 10:49:10.326585+0800 GCDDemo1[1849:70838] syncConcurrent---end

从 `同步执行 + 并发队列` 中可看到：

  - 所有任务都是在当前线程（主线程）中执行的，没有开启新的线程（同步执行不具备开启新线程的能力）。

  - 所有任务都在打印的 `syncConcurrent---begin` 和 `syncConcurrent---end` 之间执行的（同步任务需要等待队列的任务执行结束）。
  - 任务按顺序执行的。按顺序执行的原因：虽然 `并发队列` 可以开启多个线程，并且同时执行多个任务。但是因为本身不能创建新线程，只有当前线程这一个线程（`同步任务`不具备开启新线程的能力），所以也就不存在并发。而且当前线程只有等待当前队列中正在执行的任务执行完毕之后，才能继续接着执行下面的操作（`同步任务`需要等待队列的任务执行结束）。所以任务只能一个接一个按顺序执行，不能同时被执行。

### 2. 异步执行 + 并发队列

- 可以开启多个线程，任务交替（同时）执行。

``` objectivec
/**
 * 异步执行 + 并发队列
 * 特点：可以开启多个线程，任务交替（同时）执行。
 */
- (void)asyncConcurrent {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncConcurrent---begin");
    
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    NSLog(@"asyncConcurrent---end");
}

```

> 输出结果：
> 
> 2018-03-14 11:01:57.692961+0800 GCDDemo1[1905:78877] currentThread---<NSThread: 0x60000006ccc0>{number = 1, name = main}
> 2018-03-14 11:01:57.719769+0800 GCDDemo1[1905:78877] asyncConcurrent---begin
> 2018-03-14 11:01:57.719990+0800 GCDDemo1[1905:78877] asyncConcurrent---end
> 2018-03-14 11:01:59.721258+0800 GCDDemo1[1905:79082] 1---<NSThread: 0x600000263040>{number = 3, name = (null)}
> 2018-03-14 11:01:59.721264+0800 GCDDemo1[1905:79081] 2---<NSThread: 0x60000026b900>{number = 4, name = (null)}
> 2018-03-14 11:01:59.721296+0800 GCDDemo1[1905:79085] 3---<NSThread: 0x604000278180>{number = 5, name = (null)}
> 2018-03-14 11:02:01.722360+0800 GCDDemo1[1905:79081] 2---<NSThread: 0x60000026b900>{number = 4, name = (null)}
> 2018-03-14 11:02:01.722360+0800 GCDDemo1[1905:79082] 1---<NSThread: 0x600000263040>{number = 3, name = (null)}
> 2018-03-14 11:02:01.722382+0800 GCDDemo1[1905:79085] 3---<NSThread: 0x604000278180>{number = 5, name = (null)}

在 `异步执行 + 并发队列` 中可以看出：

   - 除了当前线程（主线程），系统又开启了3个线程，并且任务是交替/同时执行的。（`异步执行`具备开启新线程的能力。且`并发队列`可开启多个线程，同时执行多个任务）。
   - 所有任务是在打印的 `syncConcurrent---begin` 和 `syncConcurrent---end` 之后才执行的。说明当前线程没有等待，而是直接开启了新线程，在新线程中执行任务（`异步执行`不做等待，可以继续执行任务）。

### 3. 同步执行 + 串行队列

- 不会开启新线程，在当前线程执行任务。任务是串行的，执行完一个任务，再执行下一个任务。

``` objectivec

/**
 * 同步执行 + 串行队列
 * 特点：不会开启新线程，在当前线程执行任务。任务是串行的，执行完一个任务，再执行下一个任务。
 */
- (void)syncSerial {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"syncSerial---begin");
    
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_sync(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_sync(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    NSLog(@"syncSerial---end");
}

```

> 输出结果为：
> 
> 2018-03-14 11:06:49.184007+0800 GCDDemo1[1945:82494] currentThread---<NSThread: 0x604000072f00>{number = 1, name = main}
> 2018-03-14 11:06:49.184219+0800 GCDDemo1[1945:82494] syncSerial---begin
> 2018-03-14 11:06:51.185431+0800 GCDDemo1[1945:82494] 1---<NSThread: 0x604000072f00>{number = 1, name = main}
> 2018-03-14 11:06:53.186840+0800 GCDDemo1[1945:82494] 1---<NSThread: 0x604000072f00>{number = 1, name = main}
> 2018-03-14 11:06:55.187418+0800 GCDDemo1[1945:82494] 2---<NSThread: 0x604000072f00>{number = 1, name = main}
> 2018-03-14 11:06:57.188837+0800 GCDDemo1[1945:82494] 2---<NSThread: 0x604000072f00>{number = 1, name = main}
> 2018-03-14 11:06:59.189861+0800 GCDDemo1[1945:82494] 3---<NSThread: 0x604000072f00>{number = 1, name = main}
> 2018-03-14 11:07:01.190613+0800 GCDDemo1[1945:82494] 3---<NSThread: 0x604000072f00>{number = 1, name = main}
> 2018-03-14 11:07:01.191055+0800 GCDDemo1[1945:82494] syncSerial---end


在`同步执行 + 串行队列`可以看到：

  - 所有任务都是在当前线程（主线程）中执行的，并没有开启新的线程（同步执行不具备开启新线程的能力）。
  - 所有任务都在打印的syncConcurrent---begin和syncConcurrent---end之间执行（同步任务需要等待队列的任务执行结束）。
  - 任务是按顺序执行的（串行队列每次只有一个任务被执行，任务一个接一个按顺序执行）。
  
### 4. 异步执行 + 串行队列

- 会开启新线程，但是因为任务是串行的，执行完一个任务，再执行下一个任务

``` objectivec

/**
 * 异步执行 + 串行队列
 * 特点：会开启新线程，但是因为任务是串行的，执行完一个任务，再执行下一个任务。
 */
- (void)asyncSerial {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncSerial---begin");
    
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    NSLog(@"asyncSerial---end");
}

```

> 输出结果为：
> 
> 2018-03-14 11:10:25.852255+0800 GCDDemo1[1987:85325] currentThread---<NSThread: 0x60400007c0c0>{number = 1, name = main}
> 2018-03-14 11:10:25.852446+0800 GCDDemo1[1987:85325] asyncSerial---begin
> 2018-03-14 11:10:25.852601+0800 GCDDemo1[1987:85325] asyncSerial---end
> 2018-03-14 11:10:27.854119+0800 GCDDemo1[1987:85430] 1---<NSThread: 0x600000460280>{number = 3, name = (null)}
> 2018-03-14 11:10:29.856678+0800 GCDDemo1[1987:85430] 1---<NSThread: 0x600000460280>{number = 3, name = (null)}
> 2018-03-14 11:10:31.860508+0800 GCDDemo1[1987:85430] 2---<NSThread: 0x600000460280>{number = 3, name = (null)}
> 2018-03-14 11:10:33.863252+0800 GCDDemo1[1987:85430] 2---<NSThread: 0x600000460280>{number = 3, name = (null)}
> 2018-03-14 11:10:35.863730+0800 GCDDemo1[1987:85430] 3---<NSThread: 0x600000460280>{number = 3, name = (null)}
> 2018-03-14 11:10:37.865454+0800 GCDDemo1[1987:85430] 3---<NSThread: 0x600000460280>{number = 3, name = (null)}

在`异步执行 + 串行队列`可以看到：
 
   - 开启了一条新线程（异步执行具备开启新线程的能力，`串行队列`只开启一个线程）。
   - 所有任务是在打印的 `syncConcurrent---begin` 和 `syncConcurrent---end` 之后才开始执行的（`异步执行`不会做任何等待，可以继续执行任务）。
   - 任务是按顺序执行的（`串行队列`每次只有一个任务被执行，任务一个接一个按顺序执行）。
   
----
 
**主队列：**GCD自带的一种特殊的串行队列
 
 	- 所有放在主队列中的任务，都会放到主线程中执行
 	- 可使用dispatch_get_main_queue()获得主队列

### 5. 同步执行 + 主队列

`同步执行 + 主队列` 在不同线程中调用结果也是不一样，在主线程中调用会出现死锁，而在其他线程中则不会。

#### 5.1 在主线程中调用`同步执行 + 主队列`

- 互相等待卡住不可行

``` objectivec

/**
 * 同步执行 + 主队列
 * 特点(主线程调用)：互等卡主不执行。
 * 特点(其他线程调用)：不会开启新线程，执行完一个任务，再执行下一个任务。
 */
- (void)syncMain {
    
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"syncMain---begin");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_sync(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_sync(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    NSLog(@"syncMain---end");
}

```

> 输出结果
> 
> 2018-03-14 11:17:39.275258+0800 GCDDemo1[2046:90602] currentThread---<NSThread: 0x60400006e740>{number = 1, name = main}
> 2018-03-14 11:17:39.275437+0800 GCDDemo1[2046:90602] syncMain---begin

在`同步执行 + 主队列`可以惊奇的发现：

   - 在主线程中使用`同步执行 + 主队列`，追加到主线程的任务1、任务2、任务3都不再执行了，而且syncMain---end也没有打印，在Xcode 9上还会报崩溃。这是为什么呢？

这是因为我们在主线程中执行 `syncMain` 方法，相当于把 `syncMain` 任务放到了主线程的队列中。而 `同步执行` 会等待当前队列中的任务执行完毕，才会接着执行。那么当我们把 `任务1` 追加到主队列中，`任务1` 就在等待主线程处理完 `syncMain` 任务。而 `syncMain` 任务需要等待 `任务1` 执行完毕，才能接着执行。

那么，现在的情况就是 `syncMain` 任务和 `任务1` 都在等对方执行完毕。这样大家互相等待，所以就卡住了，所以我们的任务执行不了，而且 `syncMain---end` 也没有打印。

#### 5.2 在其他线程中调用`同步执行 + 主队列`

- 不会开启新线程，执行完一个任务，再执行下一个任务

``` objectivec
// 使用 NSThread 的 detachNewThreadSelector 方法会创建线程，并自动启动线程执行
 selector 任务
[NSThread detachNewThreadSelector:@selector(syncMain) toTarget:self withObject:nil];

```

> 输出结果：
> 
> 2018-03-14 11:23:05.466225+0800 GCDDemo1[2080:94606] currentThread---<NSThread: 0x604000270f40>{number = 3, name = (null)}
> 2018-03-14 11:23:05.478127+0800 GCDDemo1[2080:94606] syncMain---begin
> 2018-03-14 11:23:07.480904+0800 GCDDemo1[2080:94470] 1---<NSThread: 0x60000006a4c0>{number = 1, name = main}
> 2018-03-14 11:23:09.481443+0800 GCDDemo1[2080:94470] 1---<NSThread: 0x60000006a4c0>{number = 1, name = main}
> 2018-03-14 11:23:11.484207+0800 GCDDemo1[2080:94470] 2---<NSThread: 0x60000006a4c0>{number = 1, name = main}
> 2018-03-14 11:23:13.486038+0800 GCDDemo1[2080:94470] 2---<NSThread: 0x60000006a4c0>{number = 1, name = main}
> 2018-03-14 11:23:15.488007+0800 GCDDemo1[2080:94470] 3---<NSThread: 0x60000006a4c0>{number = 1, name = main}
> 2018-03-14 11:23:17.488561+0800 GCDDemo1[2080:94470] 3---<NSThread: 0x60000006a4c0>{number = 1, name = main}
> 2018-03-14 11:23:17.490313+0800 GCDDemo1[2080:94606] syncMain---end

在其他线程中使用`同步执行 + 主队列`可看到：

   - 所有任务都是在主线程（非当前线程）中执行的，没有开启新的线程（所有放在`主队列`中的任务，都会放到主线程中执行）。
   - 所有任务都在打印的 `syncConcurrent---begin` 和 `syncConcurrent---end` 之间执行（`同步任务`需要等待队列的任务执行结束）。
   - 任务是按顺序执行的（主队列是`串行队列`，每次只有一个任务被执行，任务一个接一个按顺序执行）。
 
为什么现在就不会卡住了呢？
因为 `syncMain 任务` 放到了其他线程里，而 `任务1、任务2、任务3` 都在追加到主队列中，这三个任务都会在主线程中执行。 `syncMain 任务` 在其他线程中执行到追加 `任务1` 到主队列中，因为主队列现在没有正在执行的任务，所以，会直接执行主队列的 `任务1` ，等 `任务1` 执行完毕，再接着执行 `任务2、任务3` 。所以这里不会卡住线程。

### 6. 异步执行 + 主队列

- 只在主线程中执行任务，执行完一个任务，再执行下一个任务。

``` objectivec
/**
 * 异步执行 + 主队列
 * 特点：只在主线程中执行任务，执行完一个任务，再执行下一个任务
 */
- (void)asyncMain {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncMain---begin");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    NSLog(@"asyncMain---end");
}

```

> 输出结果：
> 
> 2018-03-14 11:29:40.481045+0800 GCDDemo1[2108:98613] currentThread---<NSThread: 0x604000078a00>{number = 1, name = main}
> 2018-03-14 11:29:40.481543+0800 GCDDemo1[2108:98613] asyncMain---begin
> 2018-03-14 11:29:40.481784+0800 GCDDemo1[2108:98613] asyncMain---end
> 2018-03-14 11:29:42.489512+0800 GCDDemo1[2108:98613] 1---<NSThread: 0x604000078a00>{number = 1, name = main}
> 2018-03-14 11:29:44.489838+0800 GCDDemo1[2108:98613] 1---<NSThread: 0x604000078a00>{number = 1, name = main}
> 2018-03-14 11:29:46.490323+0800 GCDDemo1[2108:98613] 2---<NSThread: 0x604000078a00>{number = 1, name = main}
> 2018-03-14 11:29:48.491654+0800 GCDDemo1[2108:98613] 2---<NSThread: 0x604000078a00>{number = 1, name = main}
> 2018-03-14 11:29:50.492748+0800 GCDDemo1[2108:98613] 3---<NSThread: 0x604000078a00>{number = 1, name = main}
> 2018-03-14 11:29:52.494553+0800 GCDDemo1[2108:98613] 3---<NSThread: 0x604000078a00>{number = 1, name = main}

在`异步执行 + 主队列`可以看到：

   - 所有任务都是在当前线程（主线程）中执行的，并没有开启新的线程（虽然`异步执行`具备开启线程的能力，但因为是主队列，所以所有任务都在主线程中）。
   - 所有任务是在打印的 `syncConcurrent—begin` 和 `syncConcurrent—end` 之后才开始执行的（异步执行不会做任何等待，可以继续执行任务）。
   - 任务是按顺序执行的（因为主队列是`串行队列`，每次只有一个任务被执行，任务一个接一个按顺序执行）。
  
## 五、GCD 线程间的通信

在iOS开发过程中，我们一般在主线程里边进行UI刷新，例如：点击、滚动、拖拽等事件。我们通常把一些耗时的操作放在其他线程，比如说图片下载、文件上传等耗时操作。而当我们有时候在其他线程完成了耗时操作时，需要回到主线程，那么就用到了线程之间的通讯。

``` objectivec
/**
 * 线程间通信
 */
- (void)communication {
    // 获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0); 
    // 获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue(); 
    
    dispatch_async(queue, ^{
        // 异步追加任务
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
        
        // 回到主线程
        dispatch_async(mainQueue, ^{
            // 追加在主线程中执行的任务
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        });
    });
}

```

> 输出结果：
> 
> 2018-03-14 13:50:07.799131+0800 GCDDemo1[2571:160671] 1---<NSThread: 0x604000079900>{number = 3, name = (null)}
> 2018-03-14 13:50:09.800005+0800 GCDDemo1[2571:160671] 1---<NSThread: 0x604000079900>{number = 3, name = (null)}
> 2018-03-14 13:50:11.801108+0800 GCDDemo1[2571:160469] 2---<NSThread: 0x6000000660c0>{number = 1, name = main}

- 可以看到在其他线程中先执行任务，执行完了之后回到主线程执行主线程的相应操作。

## 六、GCD 的其他方法

### 1. GCD 栅栏方法：dispatch_barrier_async

- 我们有时需要异步执行两组操作，而且第一组操作执行完之后，才能开始执行第二组操作。这样我们就需要一个相当于栅栏一样的一个方法将两组异步执行的操作组给分割起来，当然这里的操作组里可以包含一个或多个任务。这就需要用到 `dispatch_barrier_async` 方法在两个操作组间形成栅栏。
- `dispatch_barrier_async` 函数会等待前边追加到并发队列中的任务全部执行完毕之后，再将指定的任务追加到该异步队列中。然后在 `dispatch_barrier_async` 函数追加的任务执行完毕之后，异步队列才恢复为一般动作，接着追加任务到该异步队列并开始执行。

``` objectivec
/**
 * 栅栏方法 dispatch_barrier_async
 */
- (void)barrier {
    dispatch_queue_t queue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_barrier_async(queue, ^{
        // 追加任务 barrier
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"barrier---%@",[NSThread currentThread]);// 打印当前线程
        }
    });
    
    dispatch_async(queue, ^{
        // 追加任务3
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_async(queue, ^{
        // 追加任务4
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"4---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
}

```

> 输出结果：
> 
> 2018-03-14 14:08:13.366011+0800 GCDDemo1[2727:170441] 2---<NSThread: 0x604000260b40>{number = 4, name = (null)}
2018-03-14 14:08:13.366011+0800 GCDDemo1[2727:170442] 1---<NSThread: 0x60400007b7c0>{number = 3, name = (null)}
2018-03-14 14:08:15.370119+0800 GCDDemo1[2727:170441] 2---<NSThread: 0x604000260b40>{number = 4, name = (null)}
2018-03-14 14:08:15.370119+0800 GCDDemo1[2727:170442] 1---<NSThread: 0x60400007b7c0>{number = 3, name = (null)}
2018-03-14 14:08:17.374574+0800 GCDDemo1[2727:170442] barrier---<NSThread: 0x60400007b7c0>{number = 3, name = (null)}
2018-03-14 14:08:19.375400+0800 GCDDemo1[2727:170442] barrier---<NSThread: 0x60400007b7c0>{number = 3, name = (null)}
2018-03-14 14:08:21.376229+0800 GCDDemo1[2727:170441] 4---<NSThread: 0x604000260b40>{number = 4, name = (null)}
2018-03-14 14:08:21.376229+0800 GCDDemo1[2727:170442] 3---<NSThread: 0x60400007b7c0>{number = 3, name = (null)}
2018-03-14 14:08:23.377080+0800 GCDDemo1[2727:170442] 3---<NSThread: 0x60400007b7c0>{number = 3, name = (null)}
2018-03-14 14:08:23.377080+0800 GCDDemo1[2727:170441] 4---<NSThread: 0x604000260b40>{number = 4, name = (null)}

在 `dispatch_barrier_async` 执行结果中可以看出：

   - 在执行完栅栏前面的操作之后，才执行栅栏操作，最后再执行栅栏后边的操作。
  
### 2. GCD 延时执行方法：dispatch_after

我们经常会遇到这样的需求：在指定时间（例如3秒）之后执行某个任务。可以用 GCD 的 `dispatch_after` 函数来实现。
需要注意的是：`dispatch_after` 函数并不是在指定时间之后才开始执行处理，而是在指定时间之后将任务追加到主队列中。严格来说，这个时间并不是绝对准确的，但想要大致延迟执行任务，`dispatch_after` 函数是很有效的。

``` objectivec
/**
 * 延时执行方法 dispatch_after
 */
- (void)after {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncMain---begin");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 2.0秒后异步追加任务代码到主队列，并开始执行
        NSLog(@"after---%@",[NSThread currentThread]);  // 打印当前线程
    });
}

``` 

> 输出结果：

> 2018-03-14 14:12:45.078709+0800 GCDDemo1[2783:173596] currentThread---<NSThread: 0x60400006c840>{number = 1, name = main}
2018-03-14 14:12:45.078902+0800 GCDDemo1[2783:173596] asyncMain---begin
2018-03-14 14:12:47.261070+0800 GCDDemo1[2783:173596] after---<NSThread: 0x60400006c840>{number = 1, name = main}

可以看出：在打印 `asyncMain---begin` 之后大约 2.0 秒的时间，打印了 `after---<NSThread: 0x60000006ee00>{number = 1, name = main}`

### 3. GCD 一次性代码（只执行一次）：dispatch_once

- 我们在创建单例、或者有整个程序运行过程中只执行一次的代码时，我们就用到了 GCD 的 `dispatch_once` 函数。使用
`dispatch_once` 函数能保证某段代码在程序运行过程中只被执行1次，并且即使在多线程的环境下，`dispatch_once` 也可以保证线程安全。

``` objectivec
/**
 * 一次性代码（只执行一次）dispatch_once
 */
- (void)once {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 只执行1次的代码(这里面默认是线程安全的)
    });
}

```

### 4. GCD 快速迭代方法：dispatch_apply

- 通常我们会用 for 循环遍历，但是 GCD 给我们提供了快速迭代的函数 dispatch_apply。dispatch_apply 按照指定的次数将指定的任务追加到指定的队列中，并等待全部队列执行结束。

如果是在串行队列中使用 `dispatch_apply`，那么就和 for 循环一样，按顺序同步执行。可这样就体现不出快速迭代的意义了。
我们可以利用并发队列进行异步执行。比如说遍历 0~5 这6个数字，for 循环的做法是每次取出一个元素，逐个遍历。`dispatch_apply` 可以 在多个线程中同时（异步）遍历多个数字。
还有一点，无论是在串行队列，还是异步队列中，`dispatch_apply` 都会等待全部任务执行完毕，这点就像是同步操作，也像是队列组中的 `dispatch_group_wait`方法。

``` objectivec
/**
 * 快速迭代方法 dispatch_apply
 */
- (void)apply {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSLog(@"apply---begin");
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"%zd---%@",index, [NSThread currentThread]);
    });
    NSLog(@"apply---end");
}

```
> 输出结果：
> 
> 2018-03-14 14:24:35.502250+0800 GCDDemo1[2885:180445] apply---begin
2018-03-14 14:24:35.503352+0800 GCDDemo1[2885:180445] 0---<NSThread: 0x6000000726c0>{number = 1, name = main}
2018-03-14 14:24:35.503375+0800 GCDDemo1[2885:180520] 3---<NSThread: 0x60000026f980>{number = 5, name = (null)}
2018-03-14 14:24:35.503353+0800 GCDDemo1[2885:180524] 1---<NSThread: 0x60000026fb00>{number = 3, name = (null)}
2018-03-14 14:24:35.503394+0800 GCDDemo1[2885:180523] 2---<NSThread: 0x60000026fc00>{number = 4, name = (null)}
2018-03-14 14:24:35.503600+0800 GCDDemo1[2885:180524] 4---<NSThread: 0x60000026fb00>{number = 3, name = (null)}
2018-03-14 14:24:35.503606+0800 GCDDemo1[2885:180520] 5---<NSThread: 0x60000026f980>{number = 5, name = (null)}
2018-03-14 14:24:35.503725+0800 GCDDemo1[2885:180445] apply---end

因为是在并发队列中异步队执行任务，所以各个任务的执行时间长短不定，最后结束顺序也不定。但是 `apply---end一` 定在最后执行。这是因为 `dispatch_apply` 函数会等待全部任务执行完毕。

### 5. GCD 的队列组：dispatch_group

有时候我们会有这样的需求：分别异步执行2个耗时任务，然后当2个耗时任务都执行完毕后再回到主线程执行任务。这时候我们可以用到 GCD 的队列组。

- 调用队列组的 `dispatch_group_async` 先把任务放到队列中，然后将队列放入队列组中。或者使用队列组的 `dispatch_group_enter`、`dispatch_group_leave` 组合 来实现 `dispatch_group_async`。
- 调用队列组的 `dispatch_group_notify` 回到指定线程执行任务。或者使用 `dispatch_group_wait` 回到当前线程继续向下执行（会阻塞当前线程）。

#### 5.1 dispatch_group_notify

- 监听 group 中任务的完成状态，当所有的任务都执行完成后，追加任务到 group 中，并执行任务。

``` objectivec
/**
 * 队列组 dispatch_group_notify
 */
- (void)groupNotify {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    dispatch_group_t group =  dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步任务1、任务2都执行完毕后，回到主线程执行下边任务
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
        NSLog(@"group---end");
    });
}

```

> 输出结果：
> 
> 2018-03-14 15:14:56.708549+0800 GCDDemo1[3363:210384] currentThread---<NSThread: 0x600000262600>{number = 1, name = main}
2018-03-14 15:14:56.708977+0800 GCDDemo1[3363:210384] group---begin
2018-03-14 15:14:58.713556+0800 GCDDemo1[3363:210541] 2---<NSThread: 0x604000460ec0>{number = 4, name = (null)}
2018-03-14 15:14:58.713556+0800 GCDDemo1[3363:210543] 1---<NSThread: 0x604000461740>{number = 3, name = (null)}
2018-03-14 15:15:00.718094+0800 GCDDemo1[3363:210541] 2---<NSThread: 0x604000460ec0>{number = 4, name = (null)}
2018-03-14 15:15:00.718094+0800 GCDDemo1[3363:210543] 1---<NSThread: 0x604000461740>{number = 3, name = (null)}
2018-03-14 15:15:02.719004+0800 GCDDemo1[3363:210384] 3---<NSThread: 0x600000262600>{number = 1, name = main}
2018-03-14 15:15:04.720260+0800 GCDDemo1[3363:210384] 3---<NSThread: 0x600000262600>{number = 1, name = main}
2018-03-14 15:15:04.720453+0800 GCDDemo1[3363:210384] group---end

从 `dispatch_group_notify` 相关代码运行输出结果可以看出：
当所有任务都执行完成之后，才执行 `dispatch_group_notify` block 中的任务。

#### 5.2 dispatch_group_wait

- 暂停当前线程（阻塞当前线程），等待指定的 group 中的任务执行完成后，才会往下继续执行。

``` objectivec
/**
 * 队列组 dispatch_group_wait
 */
- (void)groupWait {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    dispatch_group_t group =  dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    // 等待上面的任务全部完成后，会往下继续执行（会阻塞当前线程）
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"group---end");
}

```

> 输出结果：
> 
> 2018-03-14 15:19:06.067937+0800 GCDDemo1[3413:213407] currentThread---<NSThread: 0x600000262000>{number = 1, name = main}
2018-03-14 15:19:06.068098+0800 GCDDemo1[3413:213407] group---begin
2018-03-14 15:19:08.072494+0800 GCDDemo1[3413:213491] 1---<NSThread: 0x600000471640>{number = 3, name = (null)}
2018-03-14 15:19:08.072494+0800 GCDDemo1[3413:213490] 2---<NSThread: 0x60400027b2c0>{number = 4, name = (null)}
2018-03-14 15:19:10.077314+0800 GCDDemo1[3413:213490] 2---<NSThread: 0x60400027b2c0>{number = 4, name = (null)}
2018-03-14 15:19:10.077314+0800 GCDDemo1[3413:213491] 1---<NSThread: 0x600000471640>{number = 3, name = (null)}
2018-03-14 15:19:10.077544+0800 GCDDemo1[3413:213407] group---end

从 `dispatch_group_wait` 相关代码运行输出结果可以看出：
当所有任务执行完成之后，才执行 `dispatch_group_wait` 之后的操作。但是，使用 `dispatch_group_wait` 会阻塞当前线程。

#### 5.3 dispatch_group_enter、dispatch_group_leave

- `dispatch_group_enter` 标志着一个任务追加到 group，执行一次，相当于 group 中未执行完毕任务数+1
- `dispatch_group_leave` 标志着一个任务离开了 group，执行一次，相当于 group 中未执行完毕任务数-1。
- 当 group 中未执行完毕任务数为0的时候，才会使 `dispatch_group_wait` 解除阻塞，以及执行追加到 `dispatch_group_notify` 中的任务。

``` objectivec

/**
 * 队列组 dispatch_group_enter、dispatch_group_leave
 */
- (void)groupEnterAndLeave
{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步操作都执行完毕后，回到主线程.
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        }
        NSLog(@"group---end");
    });
    
//    // 等待上面的任务全部完成后，会往下继续执行（会阻塞当前线程）
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//
//    NSLog(@"group---end");
}

```

> 输出结果：
> 
> 2018-03-14 15:36:54.609837+0800 GCDDemo1[3574:223779] currentThread---<NSThread: 0x600000073880>{number = 1, name = main}
2018-03-14 15:36:54.610131+0800 GCDDemo1[3574:223779] group---begin
2018-03-14 15:36:56.615708+0800 GCDDemo1[3574:223890] 2---<NSThread: 0x6040004611c0>{number = 3, name = (null)}
2018-03-14 15:36:56.615711+0800 GCDDemo1[3574:223894] 1---<NSThread: 0x600000269a80>{number = 4, name = (null)}
2018-03-14 15:36:58.620700+0800 GCDDemo1[3574:223890] 2---<NSThread: 0x6040004611c0>{number = 3, name = (null)}
2018-03-14 15:36:58.620703+0800 GCDDemo1[3574:223894] 1---<NSThread: 0x600000269a80>{number = 4, name = (null)}
2018-03-14 15:37:00.621517+0800 GCDDemo1[3574:223779] 3---<NSThread: 0x600000073880>{number = 1, name = main}
2018-03-14 15:37:02.621943+0800 GCDDemo1[3574:223779] 3---<NSThread: 0x600000073880>{number = 1, name = main}
2018-03-14 15:37:02.622138+0800 GCDDemo1[3574:223779] group---end

从 `dispatch_group_enter、dispatch_group_leave` 相关代码运行结果中可以看出：当所有任务执行完成之后，才执行  `dispatch_group_notify` 中的任务。这里的 `dispatch_group_enter、dispatch_group_leave` 组合，其实等同于 `dispatch_group_async`。

### 6. GCD 信号量：dispatch_semaphore

GCD 中的信号量是指 **Dispatch Semaphore**，是持有计数的信号。类似于过高速路收费站的栏杆。可以通过时，打开栏杆，不可以通过时，关闭栏杆。在 **Dispatch Semaphore** 中，使用计数来完成这个功能，计数为0时等待，不可通过。计数为1或大于1时，计数减1且不等待，可通过。

**Dispatch Semaphore** 提供了三个函数：

   - `dispatch_semaphore_create `: 创建一个Semaphore并初始化信号的总量
   - `dispatch_semaphore_signal `: 发送一个信号，让信号总量加1
   - `dispatch_semaphore_wait `: 可以使总信号量减1，当信号总量为0时就会一直等待（阻塞所在线程），否则就可以正常执行。

> 注意：信号量的使用前提是：想清楚你需要处理哪个线程等待（阻塞），又要哪个线程继续执行，然后使用信号量。

Dispatch Semaphore 在实际开发中主要用于：

   - 保持线程同步，将异步执行任务转换为同步执行任务
   - 保证线程安全，为线程加锁

#### 6.1 Dispatch Semaphore 线程同步


我们在开发中，会遇到这样的需求：异步执行耗时任务，并使用异步执行的结果进行一些额外的操作。换句话说，相当于，将将异步执行任务转换为同步执行任务。比如说：AFNetworking 中 AFURLSessionManager.m 里面的 tasksForKeyPath: 方法。通过引入信号量的方式，等待异步执行任务结果，获取到 tasks，然后再返回该 tasks。

``` objectivec
- (NSArray *)tasksForKeyPath:(NSString *)keyPath {
    __block NSArray *tasks = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(dataTasks))]) {
            tasks = dataTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(uploadTasks))]) {
            tasks = uploadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(downloadTasks))]) {
            tasks = downloadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(tasks))]) {
            tasks = [@[dataTasks, uploadTasks, downloadTasks] valueForKeyPath:@"@unionOfArrays.self"];
        }

        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    return tasks;
}

```

下面，我们来利用 Dispatch Semaphore 实现线程同步，将异步执行任务转换为同步执行任务。

``` objectivec
/**
 * semaphore 线程同步
 */
- (void)semaphoreSync {
    
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block int number = 0;
    dispatch_async(queue, ^{
        // 追加任务1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        
        number = 100;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"semaphore---end,number = %zd",number);
}

```

> 输出结果：
> 
> 2018-03-14 16:02:54.230308+0800 GCDDemo1[3783:239611] currentThread---<NSThread: 0x604000066500>{number = 1, name = main}
2018-03-14 16:02:54.230478+0800 GCDDemo1[3783:239611] semaphore---begin
2018-03-14 16:02:56.235662+0800 GCDDemo1[3783:239848] 1---<NSThread: 0x604000270980>{number = 3, name = (null)}
2018-03-14 16:02:56.236054+0800 GCDDemo1[3783:239611] semaphore---end,number = 100

从 Dispatch Semaphore 实现线程同步的代码可以看到：

   - `semaphore---end` 是在执行完 `number = 100`; 之后才打印的。而且输出结果 number 为 100。
这是因为`异步执行`不会做任何等待，可以继续执行任务。`异步执行`将任务1追加到队列之后，不做等待，接着执行`dispatch_semaphore_wait方法`。此时 semaphore == 0，当前线程进入等待状态。然后，异步任务1开始执行。任务1执行到`dispatch_semaphore_signal`之后，总信号量，此时 semaphore == 1，`dispatch_semaphore_wait`方法使总信号量减1，正在被阻塞的线程（主线程）恢复继续执行。最后打印`semaphore---end,number = 100`。这样就实现了线程同步，将异步执行任务转换为同步执行任务。

#### 6.2 Dispatch Semaphore 线程安全和线程同步（为线程加锁）

**线程安全**：如果你的代码所在的进程中有多个线程在同时运行，而这些线程可能会同时运行这段代码。如果每次运行结果和单线程运行的结果是一样的，而且其他的变量的值也和预期的是一样的，就是线程安全的。

若每个线程中对全局变量、静态变量只有读操作，而无写操作，一般来说，这个全局变量是线程安全的；若有多个线程同时执行写操作（更改变量），一般都需要考虑线程同步，否则的话就可能影响线程安全。

**线程同步**：可理解为线程 A 和 线程 B 一块配合，A 执行到一定程度时要依靠线程 B 的某个结果，于是停下来，示意 B 运行；B 依言执行，再将结果给 A；A 再继续操作。

举个简单例子就是：两个人在一起聊天。两个人不能同时说话，避免听不清(操作冲突)。等一个人说完(一个线程结束操作)，另一个再说(另一个线程再开始操作)。

下面，我们模拟火车票售卖的方式，实现 NSThread 线程安全和解决线程同步问题。

场景：总共有50张火车票，有两个售卖火车票的窗口，一个是北京火车票售卖窗口，另一个是上海火车票售卖窗口。两个窗口同时售卖火车票，卖完为止。

#### 6.2.1 非线程安全（不使用 semaphore）

先来看看不考虑线程安全的代码：

``` objectivec
/**
 * 非线程安全：不使用 semaphore
 * 初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
 */
- (void)initTicketStatusNotSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    self.ticketSurplusCount = 50;
    
    // queue1 代表北京火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("net.bujige.testQueue1", DISPATCH_QUEUE_SERIAL);
    // queue2 代表上海火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("net.bujige.testQueue2", DISPATCH_QUEUE_SERIAL);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue1, ^{
        [weakSelf saleTicketNotSafe];
    });
    
    dispatch_async(queue2, ^{
        [weakSelf saleTicketNotSafe];
    });
}

/**
 * 售卖火车票(非线程安全)
 */
- (void)saleTicketNotSafe {
    while (1) {
        
        if (self.ticketSurplusCount > 0) {  //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else { //如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完");
            break;
        }
        
    }
}

```

> 输出结果（部分）：
> 
> 2018-03-14 16:13:29.568246+0800 GCDDemo1[3911:246879] currentThread---<NSThread: 0x60400007f480>{number = 1, name = main}
2018-03-14 16:13:29.568413+0800 GCDDemo1[3911:246879] semaphore---begin
2018-03-14 16:13:29.568747+0800 GCDDemo1[3911:246935] 剩余票数：48 窗口：<NSThread: 0x600000477100>{number = 3, name = (null)}
2018-03-14 16:13:29.568802+0800 GCDDemo1[3911:246938] 剩余票数：49 窗口：<NSThread: 0x60400026f880>{number = 4, name = (null)}
2018-03-14 16:13:29.770884+0800 GCDDemo1[3911:246938] 剩余票数：47 窗口：<NSThread: 0x60400026f880>{number = 4, name = (null)}
2018-03-14 16:13:29.770884+0800 GCDDemo1[3911:246935] 剩余票数：46 窗口：<NSThread: 0x600000477100>{number = 3, name = (null)}
2018-03-14 16:13:29.975337+0800 GCDDemo1[3911:246938] 剩余票数：44 窗口：<NSThread: 0x60400026f880>{number = 4, name = (null)}
>
> ...

可以看到在不考虑线程安全，不使用 semaphore 的情况下，得到票数是错乱的，这样显然不符合我们的需求，所以我们需要考虑线程安全问题。

#### 6.2.2 线程安全（使用 semaphore 加锁）

考虑线程安全的代码：

``` objectivec

/**
 * 线程安全：使用 semaphore 加锁
 * 初始化火车票数量、卖票窗口(线程安全)、并开始卖票
 */
- (void)initTicketStatusSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    semaphoreLock = dispatch_semaphore_create(1);
    
    self.ticketSurplusCount = 50;
    
    // queue1 代表北京火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("net.bujige.testQueue1", DISPATCH_QUEUE_SERIAL);
    // queue2 代表上海火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("net.bujige.testQueue2", DISPATCH_QUEUE_SERIAL);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue1, ^{
        [weakSelf saleTicketSafe];
    });
    
    dispatch_async(queue2, ^{
        [weakSelf saleTicketSafe];
    });
}

/**
 * 售卖火车票(线程安全)
 */
- (void)saleTicketSafe {
    while (1) {
        // 相当于加锁
        dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);
        
        if (self.ticketSurplusCount > 0) {  //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else { //如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完");
            
            // 相当于解锁
            dispatch_semaphore_signal(semaphoreLock);
            break;
        }
        
        // 相当于解锁
        dispatch_semaphore_signal(semaphoreLock);
    }
}

```

> 输出结果为：
> 
> 2018-03-14 16:19:17.386440+0800 GCDDemo1[4000:251186] currentThread---<NSThread: 0x604000074980>{number = 1, name = main}
2018-03-14 16:19:17.386660+0800 GCDDemo1[4000:251186] semaphore---begin
2018-03-14 16:19:17.387039+0800 GCDDemo1[4000:251241] 剩余票数：49 窗口：<NSThread: 0x604000467280>{number = 3, name = (null)}
2018-03-14 16:19:17.596014+0800 GCDDemo1[4000:251240] 剩余票数：48 窗口：<NSThread: 0x604000467fc0>{number = 4, name = (null)}
2018-03-14 16:19:17.796497+0800 GCDDemo1[4000:251241] 剩余票数：47 窗口：<NSThread: 0x604000467280>{number = 3, name = (null)}
2018-03-14 16:19:18.000761+0800 GCDDemo1[4000:251240] 剩余票数：46 窗口：<NSThread: 0x604000467fc0>{number = 4, name = (null)}
2018-03-14 16:19:18.203361+0800 GCDDemo1[4000:251241] 剩余票数：45 窗口：<NSThread: 0x604000467280>{number = 3, name = (null)}
> 
> ...
> 
> 2018-03-14 16:19:26.745496+0800 GCDDemo1[4000:251241] 剩余票数：3 窗口：<NSThread: 0x604000467280>{number = 3, name = (null)}
2018-03-14 16:19:26.949711+0800 GCDDemo1[4000:251240] 剩余票数：2 窗口：<NSThread: 0x604000467fc0>{number = 4, name = (null)}
2018-03-14 16:19:27.150306+0800 GCDDemo1[4000:251241] 剩余票数：1 窗口：<NSThread: 0x604000467280>{number = 3, name = (null)}
2018-03-14 16:19:27.353673+0800 GCDDemo1[4000:251240] 剩余票数：0 窗口：<NSThread: 0x604000467fc0>{number = 4, name = (null)}
2018-03-14 16:19:27.556782+0800 GCDDemo1[4000:251241] 所有火车票均已售完
2018-03-14 16:19:27.557369+0800 GCDDemo1[4000:251240] 所有火车票均已售完

可以看出，在考虑了线程安全的情况下，使用 dispatch_semaphore
机制之后，得到的票数是正确的，没有出现混乱的情况。我们也就解决了多个线程同步的问题。