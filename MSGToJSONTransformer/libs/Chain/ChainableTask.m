//
//  ChainableTask.m
//  ChainableTask
//
//  Created by Ashiqur Rahman on 1/18/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "ChainableTask.h"
#import <libkern/OSAtomic.h>

static NSString *kAlreadyChainedError = @"com.task.error.alreadychained";
static const NSInteger kTaskSpecificErrorCode = 20001;

static dispatch_queue_t task_runner_queue(){
    static dispatch_queue_t _task_runner_queue;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        _task_runner_queue = dispatch_queue_create("com.task.runner.concurrentqueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return _task_runner_queue;
}

typedef void(^callback)();

@implementation ChainableTask{
    dispatch_queue_t task_data_concurrent_queue, task_runner_concurrent_queue;
    id _result;
    BOOL _completed;
    BOOL _errorOccured;
    NSError *_error;
    void(^_pendingTask)();
    int32_t _alreadyChained;
}
#pragma mark - Class method
+(ChainableTask*)taskWithResult:(id)result{
    return [[ChainableTask alloc]initWithResult:result];
}
+(ChainableTask*)taskWithError:(NSError*)error{
    return [[ChainableTask alloc]initWithError:error];
}
#pragma mark - constructors
-(instancetype)initWithResult:(id)result{
    
    if (self = [self init]) {
        _result = [result copy];
        _completed = true;
    }
    
    return self;;
}
-(instancetype)initWithError:(NSError*)error{
    
    if(self = [self init]){
        _error = [error copy];
        _errorOccured = YES;
        _completed = YES;
        _alreadyChained = 0;
    }
    
    return self;
}

-(instancetype)init{
    if(self = [super init]){

        //TODO: there is no need to be this queue a concurrent queue and all the sync and barrier
        //function to be used for the properties to be mutually exclusive if this queue is just
        //a serial queue. need to investigate.
        const char *queue_name = [[NSString stringWithFormat:@"com.task.data.sychronous.concurrentqueue.%lu", [self hash]] UTF8String];
        task_data_concurrent_queue = dispatch_queue_create(queue_name, DISPATCH_QUEUE_CONCURRENT);
        
        //TODO: there should be an interface of passing user defined queue and use it for task runner
        //as this queue may soon become too crowded if there are too many tasks running at the same time.
        //this queue is shared among all the tasks since the tasks are mutually exclusive.
        task_runner_concurrent_queue = task_runner_queue();
    }
    return self;
}

#pragma mark - Synchronized property accessors
-(id)getResult{
    __block id r = nil;
    dispatch_sync(task_data_concurrent_queue, ^{
        r = _result;
    });
    return r;
}

-(NSError*)getError{
    __block NSError *e = nil;
    dispatch_sync(task_data_concurrent_queue, ^{
        e = _error;
    });
    return e;
}

-(BOOL)getIfErrorOccured{
    __block BOOL b = NO;
    dispatch_sync(task_data_concurrent_queue, ^{
        b = _errorOccured;
    });
    
    return b;
}

-(BOOL)getIfCompleted{
    __block BOOL b = NO;
    dispatch_sync(task_data_concurrent_queue, ^{
        b = _completed;
    });
    
    return b;
}

#pragma mark - Internal
-(ChainableTask*)_chainInternal:(ChainableBlock)block inQueue:(dispatch_queue_t)queue{
    
    if (OSAtomicIncrement32(&_alreadyChained) >= 2) {
        [NSException raise:kAlreadyChainedError format:@"the task has already been chained."];
        return nil;
    }
    
    ChainableTask *returningTask = [ChainableTask new];

    void(^submittingBlock)() = ^{
        dispatch_async(queue, ^{
            id result = nil;
            //if the block causes any exception we treat it as a regular error.
            @try {                
                result = block(self);
            }
            @catch (NSException *exception) {
                [returningTask trySetError:[NSError errorWithDomain:exception.reason code:kTaskSpecificErrorCode userInfo:nil]];
                return;
            }
            
            //if the result is a task then if it's completed set the returning task's result with it
            //if the result is a task and it's not completed then chain it up.
            //if the result is not a task then just set the returning task's result to the result of retruning task.
            if([result isKindOfClass:[ChainableTask class]]){
                
                id(^wrappedTask)(ChainableTask*) = ^id(ChainableTask *task){
                    if(task.error){
                        [returningTask trySetError:task.error];
                    }else{
                        [returningTask trySetResult:task.result];
                    }
                    return nil;
                };
                
                ChainableTask *nextTask = (ChainableTask*)result;
                if([nextTask getIfCompleted]){
                    wrappedTask(nextTask);
                }else{
                    [nextTask chain:wrappedTask];
                }
                
            }else{
                [returningTask trySetResult:result];
            }
            
        });
        
    };
    
    //if the task is already completed we submit the block(i.e. the pending task) immidiately.
    //else store the block to be completed when the pending task is completed.
    if([self getIfCompleted]){
        submittingBlock();
    }else{
        _pendingTask = [submittingBlock copy];
    }
    
    return returningTask;
}

#pragma mark - Public

-(ChainableTask *)chain:(ChainableBlock)block{
    return [self _chainInternal:block inQueue:task_runner_concurrent_queue];
}

-(ChainableTask *)chainInMainThread:(ChainableBlock)block{
    return [self _chainInternal:block inQueue:dispatch_get_main_queue()];
}

-(ChainableTask*)chainForSuccess:(ChainableBlock)block{
    return [self chain:^id(ChainableTask *task) {
        if([task getIfErrorOccured]){
            return task;
        }else{
            return block(task);
        }
    }];
}
-(void)trySetResult:(id)result{
    
    dispatch_barrier_async(task_data_concurrent_queue, ^{
        
        if(_completed == YES){
            [NSException raise:NSInternalInconsistencyException format:@"cant set already completed task."];
            return;
        }
        _result = result;
        _completed = true;
        
        //perform the next task.
        if(_pendingTask != nil)
            _pendingTask();
        
        //there is no need for keeping these callback after they are being invoked.
        _pendingTask = nil;
    });
    
}

-(void)trySetError:(NSError*)error{
    dispatch_barrier_async(task_data_concurrent_queue, ^{
        if(_errorOccured == YES){
            [NSException raise:NSInternalInconsistencyException format:@"cant set task which is already set as error."];
            return;
        }
        _error = error;
        _errorOccured = true;
        _completed = true;

        if(_pendingTask != nil)
            _pendingTask();
        
        //there is no need for keeping these callback after they are being invoked
        _pendingTask = nil;
    });
}


@end
