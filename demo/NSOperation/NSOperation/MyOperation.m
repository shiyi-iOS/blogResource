//
//  MyOperation.m
//  NSOperation
//
//  Created by zjjk on 2018/3/29.
//  Copyright © 2018年 zjjk. All rights reserved.
//

#import "MyOperation.h"

@implementation MyOperation

- (void)main {
    
    if (!self.isCancelled) {
        
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"1---%@", [NSThread currentThread]);
        }
        
    }
    
}

@end
