---
title: iOS runtime 总结（四）---- Associative介绍及使用
date: 2018-03-16 14:10:57
tags: [runtime]
categories: [技术]
password:
---

## 一、Associative概念

> 在日常的开发中，objective-c有两个扩展的机制：category和associative。而我们日常使用中百分之90都是使用的category作为日常的扩展方法，但是这个方法有很大的局限性：因为它并不能扩展属性。于是我们就需要借助于另外一个属性的扩展机制：associative

## 二、Associative介绍及使用

**associative**的原理就是把两个对象互相的捆绑、关联起来，使的其中的一个对象成为另外一个对象的一部分。并且我们可以不用使用修改类的定义而为其对象增加储存空间。这就有一个非常大的好处：在我们无法访问到类的源码的时候或者是考虑到二进制兼容性的时候是非常有用的。因为这允许开发者对已经存在的类在扩展中添加自定义的属性，这几乎弥补了Objective-C最大的缺点。

在使用上，associative是基于key的。所以，我们可以为任何的对象增加无数个不同key的associative，每个都使用上不同的key就好了。并且associative是可以保证能被关联的对象在关联对象的整个生命周期都是可用。

注意：由于正常的扩展是不可以扩展属性的，所以我们在使用associative的时候需要导入 `#import <objc/runtime.h>` 来实现

### 1. associative方法

其中有3个方法：

   - objc_setAssociatedObject
	
   - objc_getAssociatedObject

   - objc_removeAssociatedObjects

分别表示设置关联，取得关联，移除关联


### 2. 创建associative 

创建**associative**使用的是：`objc_setAssociatedObject` 。它把一个对象与另外一个对象进行关联。该函数需要四个参数：

   - object（源对象）: The source object for the association.
   - key（关键字）: The key for the association.
   - value（关联的对象） :The value to associate with the key key for object. Pass nil to clear an existing association.
   - policy（关联策略） :The policy for the association. For possible values, see “Associative Object Behaviors.”

#### 2.1 key关键字

关于前两个函数中的 **key** 值是我们需要重点关注的一个点，这个 **key** 值必须保证是一个对象级别（为什么是对象级别？看完下面的章节你就会明白了）的唯一常量。一般来说，有以下三种推荐的 **key** 值：

   - 声明 `static char kAssociatedObjectKey` ，使用 `&kAssociatedObjectKey` 作为 **key** 值。
   - 声明 `static void *kAssociatedObjectKey = &kAssociatedObjectKey` ，使用 `kAssociatedObjectKey` 作为 **key** 值。
   - 用 `selector` ，使用 `getter` 方法的名称作为 **key** 值。


关键字是一个`void`类型的指针。每一个关联的关键字必须是唯一的。通常都是会采用静态变量来作为关键字，但是其中3个方法中一般1，2基本可以忽略，只使用第三种就好了。因为这样可以优雅地解决了计算科学中的两大世界难题之一：命名（另一难题是缓存失效 ）。

#### 2.2 关联策略

关联策略表明了相关的对象是通过赋值，保留引用还是复制的方式进行关联的；还有这种关联是原子的还是非原子的。这里的关联策略和声明属性时的很类似。这种关联策略是通过使用预先定义好的常量来表示的。

根据上面引入的文档可以看出属性可以根据定义在枚举类型 objc_AssociationPolicy 上的行为被关联在对象上。 其中有5种枚举值:

| Behavior（枚举值）| @property Equivalent（等同于属性）| Description（解释）|
|:------------- |:---------------| :-------------|
| `OBJC_ASSOCIATION_ASSIGN`      | `@property (assign)` 或 `@property (unsafe_unretained)` |         指定一个关联对象的弱引用 |
| `OBJC_ASSOCIATION_RETAIN_NONATOMIC` | `@property (nonatomic, strong)` | 指定一个关联对象的强引用，不能被原子化使用 |
| `OBJC_ASSOCIATION_COPY_NONATOMIC` | `@property (nonatomic, copy)` | 指定一个关联对象的copy引用，不能被原子化使用 |
| `OBJC_ASSOCIATION_RETAIN` | `@property (atomic, strong)` | 指定一个关联对象的强引用，能被原子化使用 |
| `OBJC_ASSOCIATION_COPY` | `@property (atomic, copy)` | 指定一个关联对象的copy引用，能被原子化使用 |

以 `OBJC_ASSOCIATION_ASSIGN` 类型关联在对象上的弱引用不代表0 `retian` 的 `weak` 弱引用，行为上更像 `unsafe_unretained` 属性，所以当在你的视线中调用`weak` 的关联对象时要相当小心

> 根据WWDC 2011, Session 322发布的内存销毁时间表，被关联的对象在生命周期内要比对象本身释放的晚很多。它们会在被 NSObject -dealloc 调用的object_dispose() 方法中释放

下面以给Person的类别增加一个sonName的属性为例：

![picture1](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog9pic/1.png)

![picture2](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog9pic/2.png)

测试一下:

![picture3](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog9pic/3.png)

> 打印结果：
> 
> 2018-03-16 14:45:19.138287+0800 runtimeDemo1[26986:7959679] John === Bird

断开或者说是删除 `associative` 是 `associative` 中3个方法中最不常用的一个方法，可以说基本上都不会使用。因为它会断开所有的 `associative` 关联

> 此函数的主要目的是在“初试状态”时方便地返回一个对象。你不应该用这个函数来删除对象的属性，因为可能会导致其他客户对其添加的属性也被移除了。
>
> 规范的方法是：调用 objc_setAssociatedObject 方法并传入一个 nil 值来清除一个关联。

### 3. 消息（Message） 

在面向对象编程中，对象调用方法叫做发送消息。在编译时，应用的源代码就会被编将对象发送消息转换成runtime的 `objc_msgSend` 函数调用

`[receiver message];` 

在编译时会转换成类似这样的函数调用：

`id objc_msgSend(id self, SEL op, ...)`

我们是通过编译器来自动转换成运行时代码时，它会根据类型自动转换成下面的其它一个函数：

 - **objc_msgSend：** 其它普通的消息都会通过该函数来发送
 - **objc_msgSend_stret：** 消息中需要有数据结构作为返回值时，会通过该函数来发送消息并接收返回值
 - **objc_msgSendSuper：** 与objc_msgSend函数类似，只是它把消息发送给父类实例
 - **objc_msgSendSuper_stret：** 与objc_msgSend_stret函数类似，只是它把消息发送给父类实例并接收数组结构作为返回值


