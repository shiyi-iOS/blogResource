---
title: iOS runtime 总结（二）---- 主要函数
date: 2018-03-16 09:36:50
tags: [runtime]
categories: [技术]
password:
---


----

> 这里注释了runtime中相关的方法释义
> 
> 后期遇到不认识的方法可在此查询其作用
> 

----



## 类相关操作函数


``` objectivec

// 获取类的类名
const char * class_getName ( Class cls );

// 获取类的父类
Class class_getSuperclass ( Class cls );

// 判断给定的Class是否是一个元类
BOOL class_isMetaClass ( Class cls );

// 获取实例大小
size_t class_getInstanceSize ( Class cls );

// 获取类中指定名称实例成员变量的信息
Ivar class_getInstanceVariable ( Class cls, const char *name );

// 获取类成员变量的信息
Ivar class_getClassVariable ( Class cls, const char *name );

// 添加成员变量
BOOL class_addIvar ( Class cls, const char *name, size_t size, uint8_t alignment, const char *types );

// 获取整个成员变量列表
Ivar * class_copyIvarList ( Class cls, unsigned int *outCount );

// 获取指定的属性
objc_property_t class_getProperty ( Class cls, const char *name );

// 获取属性列表
objc_property_t * class_copyPropertyList ( Class cls, unsigned int *outCount );

// 为类添加属性
BOOL class_addProperty ( Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount );

// 替换类的属性
void class_replaceProperty ( Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount );

// 添加方法
BOOL class_addMethod ( Class cls, SEL name, IMP imp, const char *types );

// 获取实例方法
Method class_getInstanceMethod ( Class cls, SEL name );

// 获取类方法
Method class_getClassMethod ( Class cls, SEL name );

// 获取所有方法的数组
Method * class_copyMethodList ( Class cls, unsigned int *outCount );

// 替代方法的实现
IMP class_replaceMethod ( Class cls, SEL name, IMP imp, const char *types );

// 返回方法的具体实现
IMP class_getMethodImplementation ( Class cls, SEL name );
IMP class_getMethodImplementation_stret ( Class cls, SEL name );

// 类实例是否响应指定的selector
BOOL class_respondsToSelector ( Class cls, SEL sel );

// 添加协议
BOOL class_addProtocol ( Class cls, Protocol *protocol );

// 返回类是否实现指定的协议
BOOL class_conformsToProtocol ( Class cls, Protocol *protocol );

// 返回类实现的协议列表
Protocol * class_copyProtocolList ( Class cls, unsigned int *outCount );

// 获取版本号
int class_getVersion ( Class cls );

// 设置版本号
void class_setVersion ( Class cls, int version );

```

## 实例相关操作函数

``` objectivec
// 返回指定对象的一份拷贝
id object_copy ( id obj, size_t size );

// 释放指定对象占用的内存
id object_dispose ( id obj );

// 修改类实例的实例变量的值
Ivar object_setInstanceVariable ( id obj, const char *name, void *value );

// 获取对象实例变量的值
Ivar object_getInstanceVariable ( id obj, const char *name, void **outValue );

// 返回指向给定对象分配的任何额外字节的指针
void * object_getIndexedIvars ( id obj );

// 返回对象中实例变量的值
id object_getIvar ( id obj, Ivar ivar );

// 设置对象中实例变量的值
void object_setIvar ( id obj, Ivar ivar, id value );

// 返回给定对象的类名
const char * object_getClassName ( id obj );
// 返回对象的类
Class object_getClass ( id obj );

// 设置对象的类
Class object_setClass ( id obj, Class cls );

// 获取已注册的类定义的列表
int objc_getClassList ( Class *buffer, int bufferCount );

// 创建并返回一个指向所有已注册类的指针列表
Class * objc_copyClassList ( unsigned int *outCount );

// 返回指定类的类定义
Class objc_lookUpClass ( const char *name );
Class objc_getClass ( const char *name );
Class objc_getRequiredClass ( const char *name );

// 返回指定类的元类
Class objc_getMetaClass ( const char *name );

// 设置关联对象
void objc_setAssociatedObject ( id object, const void *key, id value, objc_AssociationPolicy policy );

// 获取关联对象
id objc_getAssociatedObject ( id object, const void *key );

// 移除关联对象
void objc_removeAssociatedObjects ( id object );

// 获取所有加载的Objective-C框架和动态库的名称
const char ** objc_copyImageNames ( unsigned int *outCount );

// 获取指定类所在动态库
const char * class_getImageName ( Class cls );

// 获取指定库或框架中所有类的类名
const char ** objc_copyClassNamesForImage ( const char *image, unsigned int *outCount );

```

## 属性操作相关函数

``` objectivec
// 获取属性名
const char * property_getName ( objc_property_t property );

// 获取属性特性描述字符串
const char * property_getAttributes ( objc_property_t property );

// 获取属性中指定的特性
char * property_copyAttributeValue ( objc_property_t property, const char *attributeName );

// 获取属性的特性列表
objc_property_attribute_t * property_copyAttributeList ( objc_property_t property, unsigned int *outCount );

```

## 方法操作相关函数

``` objectivec
// 调用指定方法的实现
id method_invoke ( id receiver, Method m, ... );

// 调用返回一个数据结构的方法的实现
void method_invoke_stret ( id receiver, Method m, ... );

// 获取方法名
SEL method_getName ( Method m );

// 返回方法的实现
IMP method_getImplementation ( Method m );

// 获取描述方法参数和返回值类型的字符串
const char * method_getTypeEncoding ( Method m );

// 获取方法的返回值类型的字符串
char * method_copyReturnType ( Method m );

// 获取方法的指定位置参数的类型字符串
char * method_copyArgumentType ( Method m, unsigned int index );

// 通过引用返回方法的返回值类型字符串
void method_getReturnType ( Method m, char *dst, size_t dst_len );

// 返回方法的参数的个数
unsigned int method_getNumberOfArguments ( Method m );

// 通过引用返回方法指定位置参数的类型字符串
void method_getArgumentType ( Method m, unsigned int index, char *dst, size_t dst_len );

// 返回指定方法的方法描述结构体
struct objc_method_description * method_getDescription ( Method m );

// 设置方法的实现
IMP method_setImplementation ( Method m, IMP imp );

// 交换两个方法的实现
void method_exchangeImplementations ( Method m1, Method m2 );

```

## 选择器相关的操作函数

``` objectivec
// 返回给定选择器指定的方法的名称
const char * sel_getName ( SEL sel );

// 在Objective-C Runtime系统中注册一个方法，将方法名映射到一个选择器，并返回这个选择器
SEL sel_registerName ( const char *str );

// 在Objective-C Runtime系统中注册一个方法
SEL sel_getUid ( const char *str );

// 比较两个选择器
BOOL sel_isEqual ( SEL lhs, SEL rhs );

```

## 协议相关的操作函数

``` objectivec
// 返回指定的协议
Protocol * objc_getProtocol ( const char *name );

// 获取运行时所知道的所有协议的数组
Protocol ** objc_copyProtocolList ( unsigned int *outCount );

// 创建新的协议实例
Protocol * objc_allocateProtocol ( const char *name );

// 在运行时中注册新创建的协议
void objc_registerProtocol ( Protocol *proto );

// 为协议添加方法
void protocol_addMethodDescription ( Protocol *proto, SEL name, const char *types, BOOL isRequiredMethod, BOOL isInstanceMethod );

// 添加一个已注册的协议到协议中
void protocol_addProtocol ( Protocol *proto, Protocol *addition );

// 为协议添加属性
void protocol_addProperty ( Protocol *proto, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount, BOOL isRequiredProperty, BOOL isInstanceProperty );

// 返回协议名
const char * protocol_getName ( Protocol *p );

// 测试两个协议是否相等
BOOL protocol_isEqual ( Protocol *proto, Protocol *other );

// 获取协议中指定条件的方法的方法描述数组
struct objc_method_description * protocol_copyMethodDescriptionList ( Protocol *p, BOOL isRequiredMethod, BOOL isInstanceMethod, unsigned int *outCount );

// 获取协议中指定方法的方法描述
struct objc_method_description protocol_getMethodDescription ( Protocol *p, SEL aSel, BOOL isRequiredMethod, BOOL isInstanceMethod );

// 获取协议中的属性列表
objc_property_t * protocol_copyPropertyList ( Protocol *proto, unsigned int *outCount );

// 获取协议的指定属性
objc_property_t protocol_getProperty ( Protocol *proto, const char *name, BOOL isRequiredProperty, BOOL isInstanceProperty );

// 获取协议采用的协议
Protocol ** protocol_copyProtocolList ( Protocol *proto, unsigned int *outCount );

// 查看协议是否采用了另一个协议
BOOL protocol_conformsToProtocol ( Protocol *proto, Protocol *other );

```

## block块相关的操作函数

``` objectivec
// 创建一个指针函数的指针，该函数调用时会调用特定的block
IMP imp_implementationWithBlock ( id block );

// 返回与IMP(使用imp_implementationWithBlock创建的)相关的block
id imp_getBlock ( IMP anImp );

// 解除block与IMP(使用imp_implementationWithBlock创建的)的关联关系，并释放block的拷贝
BOOL imp_removeBlock ( IMP anImp );

```
## 拦截调用函数

拦截调用就是在找不到调用的方法程序崩溃之前，有机会通过重写NSObject的四个方法来处理：

``` objectivec
+ (BOOL)resolveClassMethod:(SEL)sel OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);
```
> 调用一个不存在的类方法的时候，会调用这个方法，默认返回NO，可以加上自己的处理后返回YES

----

``` objectivec
+ (BOOL)resolveInstanceMethod:(SEL)sel OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);

```
> 和上一个方法类似，处理的是实例方法

----

``` objectivec
- (id)forwardingTargetForSelector:(SEL)aSelector OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);

```
> 将你调用的不存在的方法重定向到一个其他声明了这个方法的类，只需要返回一个有这个方法的target

----

``` objectivec
- (void)forwardInvocation:(NSInvocation *)anInvocation OBJC_SWIFT_UNAVAILABLE("");

```

> 将你调用的不存在的方法打包成NSInvocation传给你。做完你自己的处理后，调用invokeWithTarget:方法让某个target触发这个方法

----