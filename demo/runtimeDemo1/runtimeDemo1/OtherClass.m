//
//  OtherClass.m
//  runtimeDemo1
//
//  Created by zjjk on 2018/3/16.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import "OtherClass.h"

@implementation OtherClass

- (NSArray *)arrayWithString:(NSString *)str {
    
    if (str && (str != NULL) && (![str isKindOfClass:[NSNull class]]) && str.length > 0) {
        
        NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:1];
        for (NSInteger index = 0; index < str.length; index++) {
            
            [mArr addObject:[str substringWithRange:NSMakeRange(index, 1)]];
            
        }
        
        return mArr;
        
    }
    
    return nil;
    
}

/**
 *  逆置字符串
 *
 *  @param str 需逆置的字符串
 *
 *  @return 置换后的字符串
 */
- (NSString *)inverseWithString:(NSString *)str {
    
    if (str && (str != NULL) && (![str isKindOfClass:[NSNull class]]) && str.length > 0) {
        
        NSMutableString *mStr = [NSMutableString stringWithCapacity:1];
        
        for (NSInteger index = str.length; index > 0; index--) {
            
            [mStr appendString:[str substringWithRange:NSMakeRange(index - 1, 1)]];
            
        }
        
        return mStr;
    }
    
    return nil;
    
}

@end
