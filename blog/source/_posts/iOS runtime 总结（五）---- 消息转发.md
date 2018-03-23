---
title: iOS runtime 总结（五）---- 消息转发
date: 2018-03-16 16:01:00
tags: [runtime]
categories: [技术]
password:
---

## 方法调用流程

> 在Objective-C中，消息直到运行时才绑定到方法实现上。编译器会将消息表达式 `[receiver message]` 转化为一个消息函数的调用，即 `objc_msgSend`。

> 当消息发送给一个对象时，`objc_msgSend` 通过对象的 `isa` 指针获取到类的结构体，然后在方法分发表里面查找方法的`selector`。如果没有找到 `selector` ，则通过`objc_msgSend` 结构体中的指向父类的指针找到其父类，并在父类的分发表里面查找方法的 `selector`。依此，会一直沿着类的继承体系到达 `NSObject` 类。一旦定位到 `selector` ，函数会就获取到了实现的入口点，并传入相应的参数来执行方法的具体实现。如果最后没有定位到 `selector`，则会走**消息转发**流程。

## 消息转发

默认情况下，如果是以 `[object message]` 的方式调用方法，如果 `object` 无法响应 `message` 消息时，编译器会报错。但如果是以 `perform…` 的形式来调用，则需要等到运行时才能确定 `object` 是否能接收 `message` 消息。如果不能，则程序崩溃。不过，我们可以采取一些措施，让我们的程序执行特定的逻辑，而避免程序的崩溃。

**消息转发机制的步骤：**

### 1. 动态方法解析 

对象在接收到未知的消息时，首先会调用所属类的类方法 `+resolveInstanceMethod:` (实例方法)或者 `+resolveClassMethod:` (类方法)。在这个方法中，我们有机会为该未知消息新增一个”处理方法”“。不过使用该方法的前提是我们已经实现了该”处理方法”，只需要在运行时通过 `class_addMethod` 函数动态添加到类里面就可以了。

![picture1](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog10pic/1.png)

![picture2](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog10pic/2.png)

测试一下：

![picture3](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog10pic/3.png)

> 打印结果：
> 
> 2018-03-16 16:14:04.104890+0800 runtimeDemo1[27033:7983789] 123456

### 2. 备用接收者 

如果在上一步动态方法解析没有处理或无法处理消息，则Runtime会继续调方法：`- (id)forwardingTargetForSelector:(SEL)aSelector` ，如果一个对象实现了这个方法，并返回一个非nil的结果，则这个对象会作为消息的新接收者，且消息会被分发到这个对象。当然这个对象不能是self自身，否则就是出现无限循环。当然，如果我们没有指定相应的对象来处理aSelector，则应该调用父类的实现来返回结果。

![picture4](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog10pic/4.png)

![picture5](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog10pic/5.png)

在MyClass.m中添加如下方法：

![picture6](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog10pic/6.png)

测试一下：

![picture7](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog10pic/7.png)

打印结果：

![picture8](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog10pic/8.png)


### 3. 完整消息转发 

如果在上一步备用接收者还不能处理未知消息，则唯一能做的就是启用完整的消息转发机制了。此时会调用方法：`- (void)forwardInvocation:(NSInvocation *)anInvocation` ，对象会创建一个表示消息的 `NSInvocation` 对象，把与尚未处理的消息有关的全部细节都封装在 `anInvocation` 中，包括selector，目标(target)和参数。我们可以在 `forwardInvocation` 方法中选择将消息转发给其它对象。

forwardInvocation:方法的实现有两个任务： 

 - 定位可以响应封装在anInvocation中的消息的对象。这个对象不需要能处理所有未知消息。 
 - 使用anInvocation作为参数，将消息发送到选中的对象。anInvocation将会保留调用结果，运行时系统会提取这一结果并将其发送到消息的原始发送者。

还有一个很重要的问题，我们必须重写以下方法：`- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector` ,消息转发机制使用从这个方法中获取的信息来创建 `NSInvocation` 对象。因此我们必须重写这个方法，为给定的 `selector` 提供一个合适的方法签名。

向OtherClass.m中添加如下方法：

![picture9](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog10pic/9.png)

向MyClass.m中添加如下方法：

![picture10](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog10pic/10.png)

测试一下：

![picture11](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog10pic/11.png)

> 打印结果：
> 
> 2018-03-16 16:40:38.493453+0800 runtimeDemo1[27044:7993120] 321



