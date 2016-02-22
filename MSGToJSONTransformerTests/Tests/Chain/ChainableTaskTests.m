//
//  ChainableTaskTests.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/9/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Chain.h"
#import "TestDefines.h"

@interface ChainableTaskTests : XCTestCase

@end

@implementation ChainableTaskTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testBasic{
    EXP_START(@"testBasic");
    
    ChainableTask *t = [ChainableTask taskWithResult:nil];
    
    [[t chain:^id(ChainableTask *task) {
        return @"hello";
    }] chain:^id(ChainableTask *task) {
        XCTAssertTrue([task.result isEqualToString:@"hello"]);
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
}

-(void)testError{
    EXP_START(@"testError");
    
    ChainableTask *t = [ChainableTask taskWithResult:nil];
    
    [[t chain:^id(ChainableTask *task) {
        return [ChainableTask taskWithError:[NSError errorWithDomain:@"an error" code:200 userInfo:nil]];
    }] chain:^id(ChainableTask *task) {
        XCTAssertTrue([task.error.domain isEqualToString:@"an error"]);
        XCTAssertTrue(task.error.code == 200);
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
}

-(void)testNestedTasks{
    EXP_START(@"testNestedTasks");

    [[[[[ChainableTask taskWithResult:@"task0"] chain:^id(ChainableTask *task) {
        return [task.result stringByAppendingString:@".task1"];
    }] chain:^id(ChainableTask *task) {

        return [ChainableTask taskWithResult:[task.result stringByAppendingString:@".task2"]];
    }] chain:^id(ChainableTask *task) {
        return [[ChainableTask taskWithResult:[task.result stringByAppendingString:@".task3"]] chain:^id(ChainableTask *task) {
            return [[ChainableTask taskWithResult:[task.result stringByAppendingString:@".task4"]] chain:^id(ChainableTask *task) {
                return [task.result stringByAppendingString:@".task5"];
            }];
        }];
    }] chain:^id(ChainableTask *task) {
        XCTAssertTrue([task.result isEqualToString:@"task0.task1.task2.task3.task4.task5"]);
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
}

-(void)testCallingChainForTheSameTask{
    ChainableTask *t = [ChainableTask taskWithResult:nil];
    
    
    [t chain:^id(ChainableTask *task) {
        return @"hello";
    }];
    
    XCTAssertThrows([t chain:^id(ChainableTask *task) {
        return @"should throw error";
    }], @"Exception should be thrown for calling chain for same task.");
    
}

-(void)testWithExceptionThrownFromATask{
    
    EXP_START(@"testWithExceptionThrownFromATask");
    
    ChainableTask *t = [ChainableTask taskWithResult:nil];
    
    [[[t chainForSuccess:^id(ChainableTask *task) {
        return @"first task";
    }]chain:^id(ChainableTask *task) {
        [NSException raise:NSInternalInconsistencyException format:@"an.exception"];
        return nil;
    }] chain:^id(ChainableTask *task) {
        XCTAssertNotNil(task.error);
        XCTAssertTrue([task.error.domain isEqualToString:@"an.exception"]);
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
    
}

-(void)testWithErrorInTheMiddleOfChains{
    
    EXP_START(@"testDictCreationFromMsg");
    ChainableTask *t = [ChainableTask taskWithResult:nil];
    
    [[[[[[t chainForSuccess:^id(ChainableTask *task) {
        return [ChainableTask taskWithResult:@"first task with a new task"];
    }] chainForSuccess:^id(ChainableTask *task) {
        return @"second task with direct result";
    }] chainForSuccess:^id(ChainableTask *task) {
        return [ChainableTask taskWithError:[NSError errorWithDomain:@"error1" code:100 userInfo:nil]];
    }] chainForSuccess:^id(ChainableTask *task) {
        XCTAssertTrue(false);
        return @"should not come here";
    }] chain:^id(ChainableTask *task) {
        if (task.error) {
            return @"new task";
        }
        
        return @"should not return this";
    }] chainForSuccess:^id(ChainableTask *task) {
        NSLog(@"finally = %@", task.result );
        XCTAssertTrue([@"new task" isEqualToString:task.result]);
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
    
    
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
