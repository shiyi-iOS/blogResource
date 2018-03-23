---
title: iOS runtime 总结（三）---- 方法调用示例
date: 2018-03-16 10:19:10
tags: [runtime]
categories: [技术]
password:
---

## 获取对象所有属性名

以创建一个Person类为例，进行示例，通过 `class_copyPropertyList` 方法获取所有的属性名称

> 创建个Person类 

![picture1](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog8pic/1.png)

> 获取类的所有属性名放到数组中

![picture2](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog8pic/2.png)

> 测试一下结果

![picture3](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog8pic/3.png)

> 打印结果：
> 
> 2018-03-16 10:56:45.165053+0800 runtimeDemo1[26762:7882820] classSize = 48
2018-03-16 10:56:45.165662+0800 runtimeDemo1[26762:7882820] propertyName == name
2018-03-16 10:56:45.165716+0800 runtimeDemo1[26762:7882820] propertyName == array
2018-03-16 10:56:45.165760+0800 runtimeDemo1[26762:7882820] propertyName == age
2018-03-16 10:56:45.165802+0800 runtimeDemo1[26762:7882820] propertyName == sex

----

> 注意：上面提到的 `objc_property_t` 是一个结构体指针 `objc_property *`，因此我们声明的 `properties` 就是二维指针。所以在使用完毕以后，一定要释放内存，否则会造成内存泄露。并且由于runtime使用的是C语言的API，所以我们也需要使用C语言释放内存的方法：`free`。

## 获取对象的所有属性名和属性值

对于获取对象的所有属性名，在上面的-allProperties方法已经可以拿到了，但是并没有处理获取属性值，下面的方法就是可以获取属性名和属性值，将属性名作为key，属性值作为value

获取类的所有属性名和属性值放到字典中

![picture4](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog8pic/4.png)

测试一下：

![picture5](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog8pic/5.png)

> 打印结果：
> 
> 2018-03-16 11:29:35.840436+0800 runtimeDemo1[26811:7896171] propertyName == name == propertyValue: John
2018-03-16 11:29:35.841046+0800 runtimeDemo1[26811:7896171] propertyName == age == propertyValue: 8
2018-03-16 11:29:35.841134+0800 runtimeDemo1[26811:7896171] propertyName == sex == propertyValue: 0

----

## 获取对象的所有方法名

> 通过class_copyMethodList方法就可以获取所有的方法。并且我们知道，每一个属性都会自动生成一个成员变量和setter以及getter方法

![picture6](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog8pic/6.png)

测试一下：

![picture7](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog8pic/7.png)

> 打印结果：
> 
> 2018-03-16 11:55:37.736846+0800 runtimeDemo1[26834:7903407] 方法名：allPropertyNamesAndValues,参数个数： 2
2018-03-16 11:55:37.736944+0800 runtimeDemo1[26834:7903407] 方法名：setAge:,参数个数： 3
2018-03-16 11:55:37.737014+0800 runtimeDemo1[26834:7903407] 方法名：age,参数个数： 2
2018-03-16 11:55:37.737096+0800 runtimeDemo1[26834:7903407] 方法名：allMethods,参数个数： 2
2018-03-16 11:55:37.737167+0800 runtimeDemo1[26834:7903407] 方法名：.cxx_destruct,参数个数： 2
2018-03-16 11:55:37.737239+0800 runtimeDemo1[26834:7903407] 方法名：setName:,参数个数： 3
2018-03-16 11:55:37.737305+0800 runtimeDemo1[26834:7903407] 方法名：name,参数个数： 2
2018-03-16 11:55:37.737370+0800 runtimeDemo1[26834:7903407] 方法名：array,参数个数： 2
2018-03-16 11:55:37.737442+0800 runtimeDemo1[26834:7903407] 方法名：setArray:,参数个数： 3
2018-03-16 11:55:37.737508+0800 runtimeDemo1[26834:7903407] 方法名：allProperties,参数个数： 2
2018-03-16 11:55:37.737727+0800 runtimeDemo1[26834:7903407] 方法名：setSex:,参数个数： 3
2018-03-16 11:55:37.737812+0800 runtimeDemo1[26834:7903407] 方法名：sex,参数个数： 2

我们发现参数个数不匹配，比如 `allPropertyNamesAndValues` 方法，参数个数应该为0，但实际打印结果为2。根据打印结果可知，无参数时，值就已经是2了。这个在后面会详细讲解。

## 获取对象的成员变量名称

要获取对象的成员变量，可以通过class_copyIvarList方法来获取，通过ivar_getName来获取成员变量的名称。并且我们知道，每一个属性都会自动生成一个成员变量和setter以及getter方法

![picture8](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog8pic/8.png)

测试一下：

![picture9](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog8pic/9.png)

> 打印结果：
>
> 2018-03-16 13:56:34.321855+0800 runtimeDemo1[26959:7944606] varName == _variableString
2018-03-16 13:56:34.322483+0800 runtimeDemo1[26959:7944606] varName == _sex
2018-03-16 13:56:34.322550+0800 runtimeDemo1[26959:7944606] varName == _name
2018-03-16 13:56:34.322596+0800 runtimeDemo1[26959:7944606] varName == _array
2018-03-16 13:56:34.322699+0800 runtimeDemo1[26959:7944606] varName == _age

----

## 运行时发消息

iOS中，可以在运行时发送消息，让接收消息者执行对应的动作。可以使用 `objc_msgSend` 方法，发送消息。因为 `objc_msgSend` 是因为只有对象才能发送消息，所以肯定是以objc开头的。

另外：使用运行时发送消息前，必须导入 `#import <objc/message.h>`

![picture10](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog8pic/10.png)

这样就等于把 `[p allMethods]` 这个方法用底层的方法表示出来，其实 `[p allMethods]` 也会转成这句代码。此时你会发现很尴尬的一个现象是：编译器会报错。

问题出在：期望的参数为空，但是实际上是有2个参数的。所以我们需要来关闭严格检查来解决这个问题。

![picture11](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog8pic/11.png)


