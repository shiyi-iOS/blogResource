//
//  ViewController.m
//  runtimeDemo1
//
//  Created by zjjk on 2018/2/2.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "Person+associative.h"
#import "MyClass.h"
#import "Model1.h"
#import "UIButton+Custom.h"
#import "UIViewController+Logging.h"
#import "UIButton+Swiz.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    NSLog(@"self:%@ super:%@", self, super.class);

    [self test13];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)test0 {
    
    Person *p = [[Person alloc] init];
    p.name = @"John";
    
    size_t size = class_getInstanceSize(p.class);
    NSLog(@"classSize = %ld",size);
    
    for (NSString *propertyName in p.allPropertiesAndIvars[0]) {
        NSLog(@"propertyName == %@",propertyName);
    }
    
    for (NSString *ivarName in p.allPropertiesAndIvars[1]) {
        NSLog(@"ivarName == %@",ivarName);
    }
    
}

- (void)test1 {
    
    Person *p = [[Person alloc] init];
    p.name = @"John";
    
    size_t size = class_getInstanceSize(p.class);
    NSLog(@"classSize = %ld",size);
    
    for (NSString *propertyName in p.allProperties) {
        NSLog(@"propertyName == %@",propertyName);
    }
    
}

- (void)test2 {
    
    Person *p = [[Person alloc] init];
    p.name = @"John";
    p.age = 8;
    
    NSDictionary *dict = p.allPropertyNamesAndValues;
    
    for (NSString *propertyName in dict.allKeys) {
        NSLog(@"propertyName == %@ == propertyValue: %@ ",propertyName,dict[propertyName]);
    }
    
}

- (void)test3 {
    
    Person *p = [[Person alloc] init];
    [p allMethods];
    
}

- (void)test4 {
    
    Person *p = [[Person alloc] init];
    for (NSString *varName in p.allMemberVariables) {
        NSLog(@"varName == %@",varName);
    }
    
}

- (void)test5 {
    
    Person *p = [[Person alloc] init];
    p.name = @"John";
    p.age = 8;
    objc_msgSend(p, @selector(allMethods));
    
}

- (void)test6 {
    
    Person *p = [[Person alloc] init];
    p.name = @"John";
    p.sonName = @"Bird";
    NSLog(@"%@ === %@",p.name,p.sonName);
    
}

void testClass(id self, SEL _cmd) {
    
    NSObject *object = [[NSObject alloc] init];
    NSLog(@"1===NSObject实例：%@, 地址：%p", object, object);
    NSLog(@"1===NSObject类名：%@ 地址：%p,NSObject父类名：%@ 地址：%p", [object class], [object class], [object superclass], [object superclass]);
    
    NSLog(@"2===MyObject实例：%@,%p", self, self);
    NSLog(@"2===MyObject类名：%@ 地址：%p,MyObject父类名：%@ 地址：%p", [self class], [self class], [self superclass], [self superclass]);

    Class currentClass;
    Class superClass = [self class];
    do {
        currentClass = superClass;
        superClass = class_getSuperclass(currentClass);
        NSLog(@"3===当前类：%@ 地址：%p, 父类：%@ 地址：%p", currentClass, currentClass, superClass, superClass);

    } while (superClass != NULL);
    
    Class isaClass = [self class];
    currentClass = NULL;
    do {
        currentClass = isaClass;
        isaClass = object_getClass(currentClass);
        NSLog(@"4===当前类：%@ 地址：%p，isa指针指向的类：%@ 地址：%p", currentClass, currentClass, isaClass, isaClass);

    } while (!(currentClass == isaClass));
    
}

- (void)createClass {
    
    //创建一个类，注意名称一定不能是已经存在的类
    Class myObjectClass = objc_allocateClassPair([NSObject class], "MyObject", 0);
    //向类中添加一个方法
    class_addMethod(myObjectClass, @selector(testClass), (IMP)testClass, "v@:");
    //注册类，注册后方能使用该类
    objc_registerClassPair(myObjectClass);
    
    id myObject = [[myObjectClass alloc] init];
    [myObject performSelector:@selector(testClass)];
}

- (void)test7 {
    
    MyClass *myClass = [[MyClass alloc] init];
    NSLog(@"%@",[myClass performSelector:@selector(mergeString:andStr:) withObject:@"123" withObject:@"456"]);
    
}

- (void)test8 {
    
    MyClass *myClass = [[MyClass alloc] init];
    NSLog(@"%@",[myClass performSelector:@selector(arrayWithString:) withObject:@"123"]);
    
}

- (void)test9 {
    
    MyClass *myClass = [[MyClass alloc] init];
    NSLog(@"%@",[myClass performSelector:@selector(inverseWithString:) withObject:@"123"]);
    
}

- (void)test10 {
    
    Model1 *model = [[Model1 alloc] init];
    Ivar ivar = class_getInstanceVariable([Model1 class], "_content");
    NSString *str = object_getIvar(model, ivar);
    
    NSLog(@"str====:%@",str);
    
}

- (void)test11 {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.number = @"123";
    
    NSLog(@"str====:%@",button.number);
    
}

- (void)test12 {
    
    Model1 *model = [[Model1 alloc] init];
    
    NSLog(@"替换前：%@",model.description);

    unsigned int count;
    Ivar *ivars = class_copyIvarList([Model1 class], &count);
    for (int i = 0; i < count; i++) {
        
        Ivar ivar = ivars[i];
        const char *ivarname = ivar_getName(ivar);
        NSString *name = [NSString stringWithCString:ivarname encoding:NSUTF8StringEncoding];
        if ([name isEqualToString:@"_content"]) {
            object_setIvar(model, ivar, @"456");
            break;
        }
        
    }
    
    NSLog(@"替换后：%@",model.description);
    
}

- (void)test13 {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btn];
    
    btn.touchAreaInsets = UIEdgeInsetsMake(100, 100, 500, 300);
    btn.timeInterval = 3.;
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(100, 100, 100, 50);
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)btnClick {
    NSLog(@"点击了");
}

//-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event{
//
//    unsigned int count = 0;
//
//    Class *classes = objc_copyClassList(&count);
//
//    for (int i = 0 ; i < count; i++) {
//
//        const char *cname = class_getName(classes[i]);
//        NSLog(@"%s\n",cname);
//
//    }
//
//}

@end
