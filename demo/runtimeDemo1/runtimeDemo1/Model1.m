//
//  Model1.m
//  runtimeDemo1
//
//  Created by zjjk on 2018/3/21.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import "Model1.h"

@interface Model1()
{
    NSString *_content;
}


@end

@implementation Model1

- (instancetype)init
{
    self = [super init];
    if (self) {
        _content = @"123";
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"_content==%@",_content];
}

@end
