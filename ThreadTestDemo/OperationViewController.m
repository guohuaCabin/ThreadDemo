//
//  OperationViewController.m
//  ThreadTestDemo
//
//  Created by guohua on 2021/5/15.
//

#import "OperationViewController.h"
#import "CustomOperation.h"
#import "CustomOperation_Start.h"
@interface OperationViewController()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *dataSoure;

@property (nonatomic,assign) NSInteger safeCount;
@end

@implementation OperationViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataSoure = @[@"invocationOperation",@"invocationOperation_queue",@"blockOperation",@"blockOperation_queue",@"custom_operation_main",@"custom_operation_main_queue",@"custom_operation_start",@"custom_operation_start_queue",@"opertaionQueue_main",@"operationQueue_custom",@"maxConcurrentOperationCount_1",@"maxConcurrentOperationCount",@"operation_depend",@"operation_queuePriority",@"communication",@"async_unlock",@"async_lock"];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

//NSInvocationOperation 未加入queue
- (void)invocationOperation {
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(test) object:nil];
    [operation start];
}
//NSInvocationOperation 加入queue
- (void)invocationOperation_queue {
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(test) object:nil];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [queue addOperation:operation];
    
}

//NSBlockOperation 未加入queue
- (void)blockOperation {
    __weak typeof(self)weakss = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [weakss test];
    }];
    [operation start];
}
//NSBlockOperation 加入queue
- (void)blockOperation_queue {
    __weak typeof(self)weakss = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [weakss test];
    }];
    
    NSInteger count = 5;
    for (NSInteger i = 0; i< count; i++) {
        [operation addExecutionBlock:^{
            [weakss test];
        }];
    }
    
    [operation start];
}

//自定义 NSOperation
//重写main函数
- (void)custom_operation_main {
    CustomOperation *op = [[CustomOperation alloc]init];
    [op start];
}
//重写main函数,加入 NSOperationQueue
- (void)custom_operation_main_queue {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    CustomOperation *op = [[CustomOperation alloc]init];
    
    [queue addOperation:op];
}
//重写start函数
- (void)custom_operation_start {
    CustomOperation_Start *operation = [[CustomOperation_Start alloc]init];
    [operation start];
}
//重写start函数,加入NSOperationQueue
- (void)custom_operation_start_queue {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    CustomOperation_Start *op = [[CustomOperation_Start alloc]init];
    [queue addOperation:op];
    NSLog(@"---------再添加一次-------------");
    /**
     NSOperation 的 ready = NO 时，不能调用 -start；
     
     NSOperation 只能添加到一个NSOperationQueue，不能再次添加到另一个NSOperationQueue；
     
     NSOperation 的 executing = YES 时，不能加入队列 NSOperationQueue；
     
     NSOperation 的 finished = YES 时，不能加入队列 NSOperationQueue；
     */
//    [queue addOperation:operation];//这里会崩溃，提示 "operation is executing and cannot be enqueued",大致意思是操作在执行中，不能添加到队列
    
    CustomOperation_Start *op1 = [[CustomOperation_Start alloc]init];
    [queue addOperation:op1];
}

//主队列
- (void)opertaionQueue_main {
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    NSLog(@"打印主队列----> %@",queue);
}

//自定义队列
- (void)operationQueue_custom {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    NSLog(@"打印自定义队列 ----> %@",queue);
}


//最大并发数为 1
- (void)maxConcurrentOperationCount_1 {
    //最大并发数设置为 1，串行执行
    [self operationQueueWithMaxConcurrentOperationCount:1];
}
//最大并发数 大于 1
- (void)maxConcurrentOperationCount {
    [self operationQueueWithMaxConcurrentOperationCount:8];
}
- (void)operationQueueWithMaxConcurrentOperationCount:(NSInteger)count {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = count;
    
    __weak typeof(self) weakss = self;
    [queue addOperationWithBlock:^{
        [weakss taskWithName:@"任务一"];
    }];
    
    [queue addOperationWithBlock:^{
        [weakss taskWithName:@"任务二"];
    }];
    
    [queue addOperationWithBlock:^{
        [weakss taskWithName:@"任务三"];
    }];
    
    NSLog(@"最大并发数：%li",queue.maxConcurrentOperationCount);
}

//操作依赖
- (void)operation_depend {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [self taskWithName:@"任务一"];
    }];
                    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [self taskWithName:@"任务二"];
    }];
    
    [op1 addDependency:op2];//op1 依赖于 op2 ，先执行完op2 才会执行 op1
    [queue addOperation:op1];
    [queue addOperation:op2];
}

- (void)operation_queuePriority {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"任务一");
    }];
                    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"任务二");
    }];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"任务三");
    }];
    
    NSBlockOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"任务四");
    }];
    
    //op3 依赖 op2   op2 依赖 op1
    [op3 addDependency:op2];
    [op2 addDependency:op1];
    
    // op1 和 op4 都没有依赖关系，所以执行之前，就是处于准备就绪状态的操作
    // op2 和 op3 都有依赖关系，所以 op2 和 op3 都不是准备就绪状态下的操作
    [queue addOperations:@[op1,op2,op3,op4] waitUntilFinished:NO];
    
    [op3 setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [op2 setQueuePriority:NSOperationQueuePriorityHigh];
    [op4 setQueuePriority:NSOperationQueuePriorityHigh];
    [op1 setQueuePriority:NSOperationQueuePriorityVeryLow];
}

//线程间通信
- (void)communication {
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    __weak typeof(self) weakss = self;
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        [weakss test];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
           //主线程操作
            NSLog(@"主线程刷新了UI");
            [weakss test];
        }];
    }];
    
    [queue addOperation:op];
}

//线程不安全
- (void)async_unlock {
    __weak typeof(self) weakss = self;
    self.safeCount = 60;
    NSOperationQueue *queue1 = [[NSOperationQueue alloc]init];
    queue1.maxConcurrentOperationCount = 2;
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [weakss unsafeTask];
    }];
    
    NSOperationQueue *queue2 = [[NSOperationQueue alloc]init];
    queue2.maxConcurrentOperationCount = 2;
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [weakss unsafeTask];
    }];
    
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
}
- (void)unsafeTask {
    while (1) {
        if (self.safeCount > 0) {
            self.safeCount --;
            NSLog(@"还有%li次结束循环",self.safeCount);
            [NSThread sleepForTimeInterval:0.05];
        }else{
            NSLog(@"结束循环");
            break;
            
        }
    }
}
//线程安全
- (void)async_lock {
    __weak typeof(self) weakss = self;
    self.safeCount = 60;
    NSOperationQueue *queue1 = [[NSOperationQueue alloc]init];
    queue1.maxConcurrentOperationCount = 2;
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [weakss safeTask];
    }];
    
    NSOperationQueue *queue2 = [[NSOperationQueue alloc]init];
    queue2.maxConcurrentOperationCount = 2;
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [weakss safeTask];
    }];
    
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
}
- (void)safeTask {
    while (1) {
        
        @synchronized ([self class]) {
            if (self.safeCount > 0) {
                self.safeCount --;
                NSLog(@"还有%li次结束循环",self.safeCount);
                [NSThread sleepForTimeInterval:0.05];
            }else{
                NSLog(@"结束循环");
                break;
            }
        }
    }
}

- (void)taskWithName:(NSString *)name {
    NSInteger count = 3;
    for (NSInteger i = 0; i < count; i++) {
        [self test];
        NSLog(@"%@: 执行------ 次数: %li",name,i+1);
    }
}

- (void)test {
    NSLog(@"%s ---->  %@",__func__, [NSThread currentThread]);
}

@end



@implementation OperationViewController (TableView)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSoure.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"tableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSString *title = self.dataSoure[indexPath.row];
    cell.textLabel.text = title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = self.dataSoure[indexPath.row];
    SEL sel = NSSelectorFromString(title);
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel];
    }
    
}

@end
