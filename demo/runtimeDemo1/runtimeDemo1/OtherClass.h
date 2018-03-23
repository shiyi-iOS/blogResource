//
//  OtherClass.h
//  runtimeDemo1
//
//  Created by zjjk on 2018/3/16.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherClass : NSObject

- (NSArray *)arrayWithString:(NSString *)str;
/**
 *  逆置字符串
 *
 *  @param str 需逆置的字符串
 *
 *  @return 置换后的字符串
 */
- (NSString *)inverseWithString:(NSString *)str;

@end
