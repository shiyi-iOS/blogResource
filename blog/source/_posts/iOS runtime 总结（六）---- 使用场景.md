---
title: iOS runtime 总结（六）---- 使用场景
date: 2018-03-21 10:49:48
tags: [runtime]
categories: [技术]
password:
photos:
---

## 利用KVC进行赋值实现json转model

原理描述：用runtime提供的函数遍历Model自身所有属性，如果属性在json中有对应的值，则将其赋值。
核心方法：在NSObject的分类中添加方法

![picture1](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog11pic/1.png)

## 一键序列化

原理描述：用runtime提供的函数遍历Model自身所有属性，并对属性进行encode和decode操作。
核心方法：在Model的基类中重写方法：

![picture2](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog11pic/2.png)

## 访问私有变量

我们知道，OC中没有真正意义上的私有变量和方法，要让成员变量私有，要放在m文件中声明，不对外暴露。如果我们知道这个成员变量的名称，可以通过runtime获取成员变量，再通过getIvar来获取它的值。方法：

![picture13](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog11pic/13.png)

![picture12](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog11pic/12.png)


## 修改私有变量的值

![picture10](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog11pic/10.png)

![picture11](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog11pic/11.png)


## 给分类添加公共属性

这是最常用的一个模式，通常我们会在类声明里面添加属性，但是出于某些需求（如前言描述的情况），我们需要在分类里添加一个或多个属性的话，编译器就会报错，这个问题的解决方案就是使用runtime的关联对象

![picture5](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog11pic/5.png)

![picture6](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog11pic/6.png)

这样就可以使用这个属性了

![picture7](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog11pic/7.png)


## 「方法替换」常规写法


![picture9](https://raw.githubusercontent.com/lishibo-iOS/pictures/master/blog11pic/9.png)

上边 demo 中写了一大堆 runtime 的 api 在代码里，即不好阅读，也不便于维护。

> 这里有现成的方案：一个基于 swizzling method 的开源框架 [Aspects](https://github.com/steipete/Aspects) 。
