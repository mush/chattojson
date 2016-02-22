//
//  ParallelTask.h
//  ChainableTask
//
//  Created by Ashiqur Rahman on 1/23/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChainableTask.h"

/**
 *  This class can perform tasks which are not dependent to each other and can be performed in parallel.
 */
@interface ParallelTask : NSObject


/**
 *  Method that takes an array of tasks and performs them in parallel. The returning task will be completed
 *  when all the tasks are completed or any of the task has an error.
 *
 *  @param tasks an array of ChainableTask
 *
 *  @return returns a ChainableTask having the result of all the tasks in the same order as the 'tasks'.
 *  if any one of the tasks triggers any error then the returning task will have that error set.
 */
+(ChainableTask*)runAllTasks:(NSArray <ChainableTask*> *)tasks;

@end
