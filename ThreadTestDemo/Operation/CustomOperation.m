//
//  CustomOperation.m
//  ThreadTestDemo
//
//  Created by guohua on 2021/5/17.
//

#import "CustomOperation.h"

@implementation CustomOperation

- (void)main {
    if (!self.cancelled) {
        [self task];
    }
}
- (void)task {
    NSInteger count = 5;
    for (NSInteger i = 0; i < count; i++) {
        [self test];
    }
}
- (void)test {
    NSLog(@"custom operation ---: %s ---------> %@",__func__,[NSThread mainThread]);
}

@end
