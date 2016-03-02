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
#import "HelperUnitTest.h"

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

-(void)testBasics{
    EXP_START(@"test");
    ChainableTask *taskMultipleURL = [[[URLDetectionTask alloc] initWithText:@"muliple urls http://www.google.com.au and http://www.twitter.com@mush or bla"] task];
    ChainableTask *taskOnlyURL = [[[URLDetectionTask alloc] initWithText:@"http://www.google.com.au"] task];
    ChainableTask *taskNoURL = [[[URLDetectionTask alloc] initWithText:@"hello"] task];
    ChainableTask *taskEmptyString = [[[URLDetectionTask alloc] initWithText:@""] task];
    ChainableTask *taskNilString = [[[URLDetectionTask alloc] initWithText:nil] task];
    ChainableTask *taskURLSideBySide = [[[URLDetectionTask alloc] initWithText:@"http://www.google.com.auhttp://www.twitter.com@mush"] task];
    ChainableTask *taskSameURL = [[[URLDetectionTask alloc] initWithText:@"http://www.google.com.au and http://www.google.com.au"] task];
    
    [[[[[[[taskMultipleURL chainForSuccess:^id(ChainableTask *task) {
        DetectedUrlObject *result = task.result;
        XCTAssertTrue([@"muliple urls  and  or bla" isEqualToString:result.trimmedText]);
        NSSet *expected = [HelperUnitTest urlSetFromStringUrl:@"http://www.google.com.au", @"http://www.twitter.com@mush", nil];
        NSSet *found = [NSSet setWithArray:result.urls];
        XCTAssertTrue([expected isEqualToSet:found]);
        
        return taskOnlyURL;
    }] chainForSuccess:^id(ChainableTask *task) {
        DetectedUrlObject *result = task.result;
        XCTAssertTrue([@"" isEqualToString:result.trimmedText]);
        NSSet *expected = [HelperUnitTest urlSetFromStringUrl:@"http://www.google.com.au", nil];
        NSSet *found = [NSSet setWithArray:result.urls];
        XCTAssertTrue([expected isEqualToSet:found]);
        return taskNoURL;
    }] chainForSuccess:^id(ChainableTask *task) {
        DetectedUrlObject *result = task.result;
        XCTAssertTrue([@"hello" isEqualToString:result.trimmedText]);
        NSSet *expected = [NSSet set];
        NSSet *found = [NSSet setWithArray:result.urls];
        XCTAssertTrue([expected isEqualToSet:found]);
        return taskEmptyString;
    }] chainForSuccess:^id(ChainableTask *task) {
        DetectedUrlObject *result = task.result;
        XCTAssertTrue([@"" isEqualToString:result.trimmedText]);
        NSSet *expected = [NSSet set];
        NSSet *found = [NSSet setWithArray:result.urls];
        XCTAssertTrue([expected isEqualToSet:found]);
        return taskNilString;
    }] chainForSuccess:^id(ChainableTask *task) {
        DetectedUrlObject *result = task.result;
        XCTAssertTrue([@"" isEqualToString:result.trimmedText]);
        NSSet *expected = [NSSet set];
        NSSet *found = [NSSet setWithArray:result.urls];
        XCTAssertTrue([expected isEqualToSet:found]);
        return taskURLSideBySide;
    }] chainForSuccess:^id(ChainableTask *task) {
        DetectedUrlObject *result = task.result;
        XCTAssertTrue([@"" isEqualToString:result.trimmedText]);
        NSSet *expected = [HelperUnitTest urlSetFromStringUrl:@"http://www.google.com.au", @"http://www.twitter.com@mush", nil];
        NSSet *found = [NSSet setWithArray:result.urls];
        XCTAssertTrue([expected isEqualToSet:found],@"attaching urls case failed. NSDataDetector needs to be replaced by regex.");
        
        return taskSameURL;
    }] chainForSuccess:^id(ChainableTask *task) {
        DetectedUrlObject *result = task.result;
        XCTAssertTrue([@" and " isEqualToString:result.trimmedText]);
        NSSet *expected = [HelperUnitTest urlSetFromStringUrl:@"http://www.google.com.au", nil];
        NSSet *found = [NSSet setWithArray:result.urls];
        XCTAssertTrue([expected isEqualToSet:found]);
        
        EXP_FULFILL();
        return taskURLSideBySide;
    }];
    
    EXP_END();
}

-(void)testWithMentionsAndEmoticons{
    EXP_START(@"testWithMentionsAndEmoticons");
    
    ChainableTask *taskWithMentionsInQueryParam = [[[URLDetectionTask alloc] initWithText:@"url is http://www.google.com.au?q=@mush"] task];
    ChainableTask *taskWithMentions = [[[URLDetectionTask alloc] initWithText:@"check this http://www.google.com.au. @mush"] task];
    
    ChainableTask *taskWithEmoticonsInQueryParam = [[[URLDetectionTask alloc] initWithText:@"url is http://www.google.com.au?q=(smiley)"] task];
    ChainableTask *taskWithEmoticonsAndMentionsInQueryParam = [[[URLDetectionTask alloc] initWithText:@"url is http://www.google.com.au?q=(smiley)+@mush"] task];
    
    
    [[[[taskWithMentionsInQueryParam chainForSuccess:^id(ChainableTask *task) {
        DetectedUrlObject *result = task.result;
        XCTAssertTrue([@"url is " isEqualToString:result.trimmedText]);
        NSSet *expected = [HelperUnitTest urlSetFromStringUrl:@"http://www.google.com.au?q=@mush", nil];
        NSSet *found = [NSSet setWithArray:result.urls];
        XCTAssertTrue([expected isEqualToSet:found]);
        
        return taskWithMentions;
    }] chainForSuccess:^id(ChainableTask *task) {
        DetectedUrlObject *result = task.result;
        XCTAssertTrue([@"check this . @mush" isEqualToString:result.trimmedText]);
        NSSet *expected = [HelperUnitTest urlSetFromStringUrl:@"http://www.google.com.au", nil];
        NSSet *found = [NSSet setWithArray:result.urls];
        XCTAssertTrue([expected isEqualToSet:found]);
        
        return taskWithEmoticonsInQueryParam;
    }] chainForSuccess:^id(ChainableTask *task) {
        DetectedUrlObject *result = task.result;
        XCTAssertTrue([@"url is " isEqualToString:result.trimmedText]);
        NSSet *expected = [HelperUnitTest urlSetFromStringUrl:@"http://www.google.com.au?q=(smiley)", nil];
        NSSet *found = [NSSet setWithArray:result.urls];
        XCTAssertTrue([expected isEqualToSet:found]);
        
        return taskWithEmoticonsAndMentionsInQueryParam;
    }] chainForSuccess:^id(ChainableTask *task) {
        DetectedUrlObject *result = task.result;
        XCTAssertTrue([@"url is " isEqualToString:result.trimmedText]);
        NSSet *expected = [HelperUnitTest urlSetFromStringUrl:@"http://www.google.com.au?q=(smiley)+@mush", nil];
        NSSet *found = [NSSet setWithArray:result.urls];
        XCTAssertTrue([expected isEqualToSet:found]);
        
        EXP_FULFILL();
        
        return nil;
    }];
    
    EXP_END();
}

@end
