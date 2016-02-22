//
//  ParallelTaskTests.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/9/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Chain.h"
#import "TestDefines.h"

@interface ParallelTaskTests : XCTestCase

@end

@implementation ParallelTaskTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testParallel{
    EXP_START(@"testDictCreationFromMsg");
    ChainableTask *t1 = [ChainableTask taskWithResult:@100];
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:t1];
    for(int i = 0; i < 10; i++){
        //[array addObject:[ChainableTask taskWithError:[NSError errorWithDomain:@"asdfasdf" code:100 userInfo:nil]]];
        [array addObject:[[ChainableTask taskWithResult:[NSNumber numberWithInt:i]] chain:^id(ChainableTask *task) {
            [NSThread sleepForTimeInterval:0.5*i];
            return @(10203+i);
        }]];
    }
    
    for(int i = 0; i < 10; i++){
        //[array addObject:[ChainableTask taskWithError:[NSError errorWithDomain:@"asdfasdf" code:100 userInfo:nil]]];
        [array addObject:[ChainableTask taskWithResult:[NSNumber numberWithInt:i]]];
    }
    
    
    
    [[ParallelTask runAllTasks:array] chain:^id(ChainableTask *task) {
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
}
-(void)testError{
    
    EXP_START(@"test");
    
    ChainableTask *taskWithError = [ChainableTask taskWithError:[NSError errorWithDomain:@"an.error" code:100 userInfo:nil]];
    ChainableTask *longTask = [[ChainableTask taskWithResult:nil] chain:^id(ChainableTask *task) {
        [NSThread sleepForTimeInterval:5.0];
        return @"long task";
    }];
    [[ParallelTask runAllTasks:@[[ChainableTask taskWithResult:@"task1"],
                                [ChainableTask taskWithResult:@"task2"],
                                taskWithError,
                                [ChainableTask taskWithError:[NSError errorWithDomain:@"another.error" code:200 userInfo:nil]],
                                [ChainableTask taskWithResult:@"task4"],
                                longTask
                                ]] chain:^id(ChainableTask *task) {
        
        XCTAssertNotNil(task.error);
        XCTAssertTrue([task.error.domain isEqualToString:@"an.error"] ||
                      [task.error.domain isEqualToString:@"another.error"]);
        XCTAssertNil(task.result);
        
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
    
}
-(void)test{
    EXP_START(@"test");
    
    ChainableTask *t1 = [[ChainableTask taskWithResult:nil] chain:^id(ChainableTask *task) {
        NSLog(@"---1--start");
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"+++1--end");
        return @"t1";
    }];
    
    ChainableTask *t2 = [[ChainableTask taskWithResult:nil] chain:^id(ChainableTask *task) {
        NSLog(@"---2--start");
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"+++2--end");
        return @"t2";
    }];
    
    ChainableTask *t3 = [[ChainableTask taskWithResult:nil] chain:^id(ChainableTask *task) {
        NSLog(@"---3--start");
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"+++3--end");
        return @"t3";
    }];
    
    ChainableTask *t4 = [[ChainableTask taskWithResult:nil] chain:^id(ChainableTask *task) {
        NSLog(@"---4--start");
        NSLog(@"+++4--end");
        return @"t4";
    }];
    
    [[ParallelTask runAllTasks:@[t2, t1, t3, t4]] chain:^id(ChainableTask *task) {
        NSLog(@"%@", task.result);
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
}


@end
