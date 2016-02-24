//
//  URLDetectionTaskTest.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/24/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "URLDetectionTask.h"
#import "TestDefines.h"

@interface URLDetectionTaskTest : XCTestCase

@end

@implementation URLDetectionTaskTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBasic {
    EXP_START(@"testBasic");
    
    [[[[URLDetectionTask alloc]initWithText:@"@bob https://www.google.com.au. this is cool."] task] chain:^id(ChainableTask *task) {
        DetectedUrlObject *obj = task.result;

        EXP_FULFILL();
        return nil;
    }];
    
    
    EXP_END();
}


@end
