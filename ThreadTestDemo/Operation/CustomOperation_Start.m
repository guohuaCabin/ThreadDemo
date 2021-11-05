//
//  CustomOperation_Start.m
//  ThreadTestDemo
//
//  Created by guohua on 2021/5/17.
//

/**
 
 
 */
#import "CustomOperation_Start.h"
@interface CustomOperation_Start()
@property (nonatomic,assign,readwrite,getter=isExecuting) BOOL executing;
@property (nonatomic,assign,readwrite,getter=isFinished) BOOL finished;
@end

@implementation CustomOperation_Start

@synthesize executing = _executing;
@synthesize finished = _finished;


- (void)start {
    self.executing = YES;
    self.finished = NO;
    //开始处理
    if (!self.cancelled) {
        [self task];
    }
    //结束处理，更新状态
    [self finishStatus];
}

- (void)task {
    NSInteger count = 5;
    for (NSInteger i = 0; i < count; i++) {
        [self test];
    }
}

- (void)test {
    NSLog(@"CustomOperation_Start --: %s --> %@",__func__,[NSThread mainThread]);
}

- (void)finishStatus {
    self.executing = NO;
    self.finished = YES;
}


-(BOOL)isExecuting {
    return _executing;
}
-(void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

-(BOOL)isFinished {
    return _finished;
}
-(void)setFinished:(BOOL)finished {
    if (_finished != finished) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = finished;
        [self didChangeValueForKey:@"isFinished"];
    }
}

//是否并发Operation
- (BOOL)isAsynchronous {
    return YES;
}

@end
