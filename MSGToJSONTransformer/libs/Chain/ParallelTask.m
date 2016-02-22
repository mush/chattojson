//
//  ParallelTask.m
//  ChainableTask
//
//  Created by Ashiqur Rahman on 1/23/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "ParallelTask.h"
#import <libkern/OSAtomic.h>

@interface ParallelTask (Private)
-(instancetype)initWithTasks:(NSArray <ChainableTask*> * ) tasks;
-(ChainableTask*)run;
@end

@implementation ParallelTask{
    NSArray<ChainableTask*> *_tasks;
}

+(ChainableTask*)runAllTasks:(NSArray <ChainableTask*> *)tasks{

    return [[[ParallelTask alloc]initWithTasks:tasks] run];
}

#pragma mark - Private
-(instancetype)initWithTasks:(NSArray <ChainableTask*> * ) tasks{
    
    if(self = [super init]){
        _tasks = tasks;
    }
    
    return self;
}

-(ChainableTask*)run{

    if(_tasks.count == 0){
        return [ChainableTask taskWithResult:@[]];
    }
    
    ChainableTask *returningTask = [ChainableTask new];
    NSObject *lock = [NSObject new];
    
    __block NSError *occurred_error = nil;
    __block int32_t taskCount = (int32_t)_tasks.count;
    for(ChainableTask *task in _tasks){
        [task chain:^id(ChainableTask *task) {
            
            //synchronization is vital in here otherwise the outer block variable accessed
            //by multiple threads potentially lead to out-of-sync which in turn would
            //try to set result/error in returninTask object.
            if(task.error){
                @synchronized(lock) {
                    occurred_error = task.error;
                }
            }
            
            //another synchronized block can be used. but since it's just
            //modifying a number it's much efficient to use osatomic.
            if(OSAtomicDecrement32(&taskCount) == 0){
                if(occurred_error){
                    [returningTask trySetError:occurred_error];
                }else{
                    [returningTask trySetResult:nil];
                }
            }
            
            return nil;
        }];
    }
    
    return [returningTask chainForSuccess:^id(ChainableTask *task) {

        //return the array or results of all the tasks in _tasks.
        return [_tasks valueForKey:@"result"];
    }];
}
@end
