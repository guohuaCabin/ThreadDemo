//
//  GCDViewController.m
//  ThreadTestDemo
//
//  Created by guohua on 2021/5/15.
//

#import "GCDViewController.h"

@interface GCDViewController()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) dispatch_group_t wait_group;
@property (nonatomic,strong) dispatch_semaphore_t semaphore;

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *dataSoure;

@end

@implementation GCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.dataSoure = @[@"sync_serial",@"sync_concurrent",@"async_serial",@"async_concurrent",@"async_main_queue",@"dispatch_communication",@"dispatch_communication_wrong",@"dispatch_communication_right",@"dispatch_semaphore",@"dispatch_communication_wait",@"dispatch_after",@"dispatch_oncee",@"dispatch_apply",@"maxConcurrentOperationCount"];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}
//同步+串行
- (void)sync_serial {
    NSLog(@"sync_serial---begin");
    dispatch_queue_t queue = dispatch_queue_create("sync_serialQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        NSLog(@"同步1---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"同步2---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"同步3---%@",[NSThread currentThread]);
    });
    
    NSLog(@"sync_serial---end");
}
//同步+并行
- (void)sync_concurrent {
    NSLog(@"sync_concurrent---begin");
    dispatch_queue_t queue = dispatch_queue_create("sync_concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_sync(queue, ^{
        NSLog(@"同步1---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"同步2---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"同步3---%@",[NSThread currentThread]);
    });
    
    NSLog(@"sync_concurrent---end");
}

//异步+串行
- (void)async_serial {
    NSLog(@"async_serial---begin");
    dispatch_queue_t queue = dispatch_queue_create("async_serialQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:3];
        NSLog(@"异步1---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"异步2---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"异步3---%@",[NSThread currentThread]);
    });
    
    NSLog(@"async_serial---end");
}
//异步+并行
- (void)async_concurrent {
    NSLog(@"async_concurrent---begin");
    dispatch_queue_t queue = dispatch_queue_create("async_concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:3];
        NSLog(@"异步1---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:3];
        NSLog(@"异步2---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:3];
        NSLog(@"异步3---%@",[NSThread currentThread]);
    });
    
    NSLog(@"async_concurrent---end");
}

//异步+主队列
- (void)async_main_queue {
    NSLog(@"async_main_queue---begin");
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    dispatch_async(queue, ^{
        NSLog(@"异步1---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"异步2---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"异步3---%@",[NSThread currentThread]);
    });
    
    NSLog(@"async_main_queue---end");
}
//通信
- (void)dispatch_communication {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务一");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务二");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务三");
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"所有任务执行完成");
    });
}
//通信-wrong
- (void)dispatch_communication_wrong {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_async(group, queue, ^{
        [self task1];
    });
    
    dispatch_group_async(group, queue, ^{
        [self task2];
    });
    
    dispatch_group_async(group, queue, ^{
        [self task3];
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"所有任务执行完成");
    });
}

- (void)task1{
    dispatch_queue_t queue = dispatch_queue_create("task1Queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 延迟执行
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"任务一");
        });
    });
}

- (void)task2{
    dispatch_queue_t queue = dispatch_queue_create("task2Queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 延迟执行
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"任务二");
        });
    });
}

- (void)task3 {
    dispatch_queue_t queue = dispatch_queue_create("task3Queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 延迟执行
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"任务三");
        });
    });
}

- (void)dispatch_communication_right {
    self.wait_group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_enter(self.wait_group);
    dispatch_group_async(self.wait_group, queue, ^{
        [self task_wait1];
    });
    
    dispatch_group_enter(self.wait_group);
    dispatch_group_async(self.wait_group, queue, ^{
        [self task_wait2];
    });
    
    dispatch_group_enter(self.wait_group);
    dispatch_group_async(self.wait_group, queue, ^{
        [self task_wait3];
    });
    
    dispatch_group_notify(self.wait_group, queue, ^{
        NSLog(@"所有任务执行完成");
    });
}
- (void)task_wait1{
    dispatch_queue_t queue = dispatch_queue_create("task1Queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 延迟执行
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"任务一");
            dispatch_group_leave(self.wait_group);
        });
    });
}

- (void)task_wait2{
    dispatch_queue_t queue = dispatch_queue_create("task2Queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 延迟执行
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"任务二");
            dispatch_group_leave(self.wait_group);
        });
    });
}

- (void)task_wait3 {
    dispatch_queue_t queue = dispatch_queue_create("task3Queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 延迟执行
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"任务三");
            dispatch_group_leave(self.wait_group);
        });
    });
}

//dispatch_semaphore
- (void)dispatch_semaphore {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.semaphore = dispatch_semaphore_create(0);
    dispatch_async(queue, ^{
        [self task_semaphore_wait1];
    });
//    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_async(queue, ^{
        [self task_semaphore_wait2];
    });
//    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_async(queue, ^{
        [self task_semaphore_wait3];
    });
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"dispatch_semaphore 执行完成");
}

- (void)task_semaphore_wait1{
    dispatch_queue_t queue = dispatch_queue_create("task1Queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 延迟执行
//        [NSThread sleepForTimeInterval:2];
//        NSLog(@"任务一");
//        dispatch_semaphore_signal(self.semaphore);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),queue, ^{
            NSLog(@"任务一");
            dispatch_semaphore_signal(self.semaphore);
        });
    });
}

- (void)task_semaphore_wait2{
    dispatch_queue_t queue = dispatch_queue_create("task2Queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 延迟执行
//        [NSThread sleepForTimeInterval:2];
//        NSLog(@"任务二");
//        dispatch_semaphore_signal(self.semaphore);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), queue, ^{
            NSLog(@"任务二");
            dispatch_semaphore_signal(self.semaphore);
        });
    });
}

- (void)task_semaphore_wait3 {
    dispatch_queue_t queue = dispatch_queue_create("task3Queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 延迟执行
//        [NSThread sleepForTimeInterval:2];
//        NSLog(@"任务三");
//        dispatch_semaphore_signal(self.semaphore);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), queue, ^{
            NSLog(@"任务三");
            dispatch_semaphore_signal(self.semaphore);
        });
    });
}


- (void)dispatch_communication_wait {
    dispatch_group_t group =  dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务一");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务二");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"任务三");
    });
    
    // 等待上面的任务全部完成后，会往下继续执行（会阻塞当前线程）
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"阻塞线程");
    NSLog(@"任务结束");
}

- (void)dispatch_after {
    // 延迟执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 需要延迟执行的代码
    });
}

//dispatch_once
- (void)dispatch_oncee {
    static dispatch_once_t onceToken;
    NSLog(@"开始********   %ld",onceToken);
    dispatch_once(&onceToken, ^{
        //只执行一次
        NSLog(@"执行中********   %ld",onceToken);
    });
    NSLog(@"结束********   %ld",onceToken);
    
    // onceToken 的值 在初始化 、执行中 和 执行后都会发生变化。
}

//dispatch_apply
- (void)dispatch_apply {
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(3, queue, ^(size_t i) {
        NSLog(@"执行-- %li",i);
    });
    NSLog(@"dispatch_apply 执行完成");
}
//使用信号量来实现最大并发数
- (void)maxConcurrentOperationCount {
    dispatch_group_t group = dispatch_group_create();
    dispatch_semaphore_t semapphore = dispatch_semaphore_create(6);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSInteger count = 100;
    for (NSInteger i = 0; i < count; i++) {
        //信号量为 0时，会一直等待，当信号量 >= 1 时，课=可通过一次，会将信号量减 1
        dispatch_semaphore_wait(semapphore, DISPATCH_TIME_FOREVER);
        dispatch_group_async(group, queue, ^{
            sleep(1);
            NSLog(@"当前执行线程：%@",[NSThread currentThread]);
            //当前线程执行完后，会将信号量+1 ，这样就会触发dispatch_semaphore_wait再执行一条。
            dispatch_semaphore_signal(semapphore);
        });
    }
    
    //监听任务是否全部执行完
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"执行完成-----");
}

@end

@implementation GCDViewController (TableView)

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
    NSString *title = self.dataSoure[indexPath.row];
    SEL sel = NSSelectorFromString(title);
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel];
    }
    
}

@end
