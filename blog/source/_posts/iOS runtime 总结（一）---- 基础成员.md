---
title: iOS runtime 总结（一）---- 基础成员
date: 2018-03-15 13:52:13
tags: [runtime]
categories: [技术]
password:
---

## runtime 简介

Runtime 又叫运行时，是一套底层的 C 语言 API，其为 iOS 内部的核心之一，我们平时编写的 OC 代码，底层都是基于它来实现的。比如：

`[receiver message];`

底层运行时会被编译器转化为：

`objc_msgSend(receiver, selector)`

如果其还有参数比如：

`[receiver message:(id)arg...];`

底层运行时会被编译器转化为：

`objc_msgSend(receiver, selector, arg1, arg2, ...)`

以上你可能看不出它的价值，但是我们需要了解的是 Objective-C 是一门动态语言，它会将一些工作放在代码运行时才处理而并非编译时。也就是说，有很多类和成员变量在我们编译的时是不知道的，而在运行时，我们所编写的代码会转换成完整的确定的代码运行。

因此，编译器是不够的，我们还需要一个运行时系统(Runtime system)来处理编译后的代码。

Runtime 基本是用 C 和汇编写的，由此可见苹果为了动态系统的高效而做出的努力。

在Objective-C代码中使用Runtime, 需要引入

`#import <objc/runtime.h>`

## runtime 作用及相关应用

### 1. runtime作用

runtime是属于OC的底层, 可以进行一些非常底层的操作(用OC是无法现实的, 不好实现)。

   - 在程序运行过程中, 动态创建一个类(比如KVO的底层实现)
   - 在程序运行过程中, 动态地为某个类添加属性\方法, 修改属性值\方法
   - 遍历一个类的所有成员变量(属性)\所有方法

### 2. runtime相关应用

   - NSCoding(归档和解档, 利用runtime遍历模型对象的所有属性)
   - 字典 --> 模型 (利用runtime遍历模型对象的所有属性, 根据属性名从字典中取出对应的值, 设置到模型的属性上)
   - KVO(利用runtime动态产生一个类)
   - 用于封装框架(想怎么改就怎么改)

## runtime 成员

### 1. Class - 类

Objective-C类是由Class类型来表示的，它实际上是一个指向objc_class结构体的指针。objc_class结构体的定义如下

``` objectivec
struct objc_class {

    Class isa  OBJC_ISA_AVAILABILITY; // 指向metaclass



#if !__OBJC2__

    Class super_class                       OBJC2_UNAVAILABLE;  // 指向父类的指针，如果该类是根类（如NSObject或NSProxy），那么super_class就为NULL

    const char *name                        OBJC2_UNAVAILABLE;  // 类名

    long version                            OBJC2_UNAVAILABLE;  // 类的版本信息，默认为0，可以通过runtime函数class_setVersion或者class_getVersion进行修改、读取

    long info                               OBJC2_UNAVAILABLE;  // 类信息，供运行期使用的一些位标识。如CLS_CLASS (0x1L) 表示该类为普通 class ，其中包含实例方法和变量;CLS_META (0x2L) 表示该类为 metaclass，其中包含类方法;

    long instance_size                      OBJC2_UNAVAILABLE;  // 该类的实例变量大小(包括从父类继承下来的实例变量)

    struct objc_ivar_list *ivars            OBJC2_UNAVAILABLE;  // 该类的成员变量链表，用于存储每个成员变量的地址

    struct objc_method_list **methodLists   OBJC2_UNAVAILABLE;  // 方法定义的链表，如CLS_CLASS (0x1L),则存储实例方法，如CLS_META (0x2L)，则存储类方法

    struct objc_cache *cache                OBJC2_UNAVAILABLE;  // 方法缓存，用于提升效率；

    struct objc_protocol_list *protocols    OBJC2_UNAVAILABLE;  // 存储该类声明遵守的协议

#endif



} OBJC2_UNAVAILABLE;

```

> - 对对象进行操作的方法一般以object_开头
> 
> - 对类进行操作的方法一般以class_开头
> 
> - 对类或对象的方法进行操作的方法一般以method_开头
> 
> - 对成员变量进行操作的方法一般以ivar_开头
> 
> - 对属性进行操作的方法一般以property_开头开头
> 
> - 对协议进行操作的方法一般以protocol_开头

### 2. 实例对象

即objc_object表示的一个类的实例的结构体，它的定义如下

``` objectivec
struct objc_object {

    Class isa  OBJC_ISA_AVAILABILITY;

};

typedef struct objc_object *id;
```
### 3. 元类(Meta Class)

meta-class是一个类对象的类。它存储着一个类的所有类方法。每个类都会有一个单独的meta-class。

### 4. isa指针

isa是一个指向结构体的指针：

- **实例对象**中的isa指针指向对象所属类Class,这个Class中存储着成员变量和对象方法（“-”方法）
- **Class**中的isa指针指向元类，存储着static类型成员变量和类方法（“+”方法）。

### 5. 方法调用过程

- **调用对象的实例方法：** 

  - 先在自身isa指针指向的类（class）methodLists中查找该方法
  - 如果找不到则会通过class的super_class指针找到父类的类对象结构体，然后从methodLists中查找该方法
  - 如果仍然找不到，则继续通过super_class向上一级父类结构体中查找，直至根class
  - 最后响应该方法，最后把该方法添加到cache列表中，以后再调用该方法，直接从cache中取出相应的方法调用
  - 如果一直到根类还没有找到，转向拦截调用
  - 如果没有重写拦截调用的方法，程序报错

- **调用类方法：** 

   - 先通过自己的isa指针找到metaclass，并从其中methodLists中查找该类方法
   - 如果找不到则会通过metaclass的super_class指针找到父类的metaclass对象结构体，然后从methodLists中查找该方法
   - 如果仍然找不到，则继续通过super_class向上一级父类结构体中查找，直至根metaclass
   - 最后响应该方法，最后把该方法添加到cache列表中，以后再调用该方法，直接从cache中取出相应的方法调用
   - 如果一直到根类还没有找到，转向拦截调用
   - 如果没有重写拦截调用的方法，程序报错
   
### 6.super

super与self不同，self是类的一个隐藏参数，每个方法的实现的第一个参数即为self。而super并不是隐藏参数，它实际上只是一个”编译器标示符”，它负责告诉编译器，当调用viewDidLoad方法时，去调用父类的方法，而不是本类中的方法。而它实际上与self指向的是相同的消息接收者。 
super的定义：

``` objectivec
struct objc_super {
     id receiver;//即消息的实际接收者
     Class superClass;//指针当前类的父类
 };

```
例证：

``` objectivec
- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"self:%@ super:%@", self, super.class);
}

```
> 打印结果：
> 
> 2018-03-15 14:57:42.775938+0800 runtimeDemo1[4540:155849] self:<ViewController: 0x7fb039d07160> super:ViewController

### 7.SEL

SEL又叫选择器，是表示一个方法的selector的指针，本质上，SEL只是一个指向方法的指针（准确的说，只是一个根据方法名hash化了的KEY值，能唯一代表一个方法），它的存在只是为了加快方法的查询速度。其定义如下：

`typedef struct objc_selector *SEL;
`

### 8.IMP

IMP实际上是一个函数指针，指向方法实现的首地址。SEL就是为了查找方法的最终实现IMP的。由于每个方法对应唯一的SEL，因此我们可以通过SEL方便快速准确地获得它所对应的IMP，查找过程将在下面讨论。取得IMP后，我们就获得了执行这个方法代码的入口点，此时，我们就可以像调用普通的C语言函数一样来使用这个函数指针了。其定义如下：

`id (*IMP)(id, SEL, ...)`

### 9. Method

即objc_method表示的一个结构体，它存储了方法名(method_name)、方法类型(method_types)和方法实现(method_imp)等信息。它实际上相当于在SEL和IMP之间作了一个映射。有了SEL，我们便可以找到对应的IMP，从而调用方法的实现代码。Method用于表示类定义中的方法，定义如下：

``` objectivec
typedef struct objc_method *Method;



struct objc_method {

    SEL method_name                 OBJC2_UNAVAILABLE;  // 方法名

    char *method_types                  OBJC2_UNAVAILABLE;

    IMP method_imp                      OBJC2_UNAVAILABLE;  // 方法实现

}  

```

### 10. Cache

Cache主要用来缓存。Cache其实就是一个存储Method的链表，主要是为了优化方法调用的性能。当调用方法时，优先在Cache查找，如果没有找到，再到methodLists查找。

### 11. Ivar

Ivar表示类中的实例变量。Ivar其实就是一个指向objc_ivar结构体指针，它包含了变量名(ivar_name)、变量类型(ivar_type)等信息。

可以根据下面的这个例子，更好的理解class之间的关系：

![picture12](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog8pic/12.png)

> 注：关于“v@:”写法可参考[iOS学习之Objective-C 2.0 运行时系统编程-8类型编码](http://www.it610.com/article/4089444.htm)