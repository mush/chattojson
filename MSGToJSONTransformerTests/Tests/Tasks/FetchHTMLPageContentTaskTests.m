//
//  FetchHTMLPageContentTaskTests.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/24/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FetchHTMLPageContentTask.h"
#import "TestDefines.h"

@interface FetchHTMLPageContentTaskTests : XCTestCase

@end

@implementation FetchHTMLPageContentTaskTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.

    [super tearDown];
}

- (void)testAValidURL {
    EXP_START(@"testAValidURL");
    
    FetchHTMLPageContentTask *task = [[FetchHTMLPageContentTask alloc]initWithURL:[NSURL URLWithString:@"https://www.google.com.au"]];
    
    [[task task] chain:^id(ChainableTask *task) {
        
        XCTAssertNotNil(task.result);
        
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
}

-(void)testAURLWithRedirection{
    EXP_START(@"testAURLWithRedirection");
    
    FetchHTMLPageContentTask *task = [[FetchHTMLPageContentTask alloc]initWithURL:[NSURL URLWithString:@"https://www.google.com"]];
    
    [[task task] chain:^id(ChainableTask *task) {
        
        XCTAssertNotNil(task.result, @"basic failed");
        
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
}

-(void)testAnNonStandardATSCompliantURL{
    EXP_START(@"testAnNonStandardATSCompliantURL");
    
    FetchHTMLPageContentTask *task = [[FetchHTMLPageContentTask alloc]initWithURL:[NSURL URLWithString:@"http://www.google.com"]];
    
    [[task task] chain:^id(ChainableTask *task) {
        
        XCTAssertNotNil(task.result, @"ATS key is not set in info.plist.");
        
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
}

-(void)testANonExistantURL{
    EXP_START(@"testANoExistantURL");
    
    FetchHTMLPageContentTask *task = [[FetchHTMLPageContentTask alloc]initWithURL:[NSURL URLWithString:@"http://anonexistanturl"]];
    
    [[task task] chain:^id(ChainableTask *task) {
        
        XCTAssertNil(task.result);
        XCTAssertNotNil(task.error);
        
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
}

@end
