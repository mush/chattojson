//
//  ChainableTask.h
//  ChainableTask
//
//  Created by Ashiqur Rahman on 1/18/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ChainableTask;

typedef id(^ChainableBlock)(ChainableTask *task);

/**
 *  The main class that can perform tasks in series. It provides convenient methods for 
 *  running various tasks having a linear dependecy. Each task has a private concurrent queue
 *  for synchronization and there is a global concurrent queue for each task to be run on it.
 */
@interface ChainableTask : NSObject

@property(readonly, getter=getResult) id result;
@property(readonly, getter=getError) NSError *error;

/**
 *  Convenient method for getting a completed task with result.
 *
 *  @param result any type of object. This object must implement NSCopying protocol.
 *
 *  @return returns a completed task with result.
 */
+(ChainableTask*)taskWithResult:(id)result;

/**
 *  Convenient method for getting a completed task with error.
 *
 *  @param error an NSError
 *
 *  @return returns a completed task with error.
 */
+(ChainableTask*)taskWithError:(NSError*)error;

/**
 *  The current task can't be set completed until the task that is going to be returned from the give block is completed.
 *  The given method gets called with the result of this task's result and/or error. Calling this method more than once
 *  for a task will throw an exception.
 *
 *  @param block a ChainableBlock block
 *
 *  @return returns a new ChainableTask. This task will be completed when the task return by 'block' is completed.
 */
-(ChainableTask*)chain:(ChainableBlock)block;

/**
 *  Same as method chain:. Only difference is that the block will only be called if this task is successfully completed.
 *
 */
-(ChainableTask*)chainForSuccess:(ChainableBlock)block;

/**
 *  Same as methond chain: except that the given block will be running in main queue.
 *
 */
-(ChainableTask*)chainInMainThread:(ChainableBlock)block;

/**
 *  will try to set the result of the task with 'result'. setting an already completed task will throw an exception.
 *
 */
-(void)trySetResult:(id)result;

/**
 *  will try to set the error of the task with 'error'. setting an already completed task will throw an exception.
 *
 */
-(void)trySetError:(NSError*)error;
@end

