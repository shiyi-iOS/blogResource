//
//  UIButton+Swiz.h
//  runtimeDemo1
//
//  Created by zjjk on 2018/3/23.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Swiz)

//点击间隔
@property (nonatomic, assign) NSTimeInterval timeInterval;

//用于设置单个按钮是否需要timeInterval 
@property (nonatomic, assign) BOOL isIgnore;

//设置超出自身范围的额外点击区域
@property (nonatomic, assign) UIEdgeInsets touchAreaInsets;

@end
