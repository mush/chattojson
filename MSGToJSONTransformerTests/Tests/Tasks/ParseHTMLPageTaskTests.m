//
//  ParseHTMLPageTaskTests.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/7/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HelperUnitTest.h"
#import "TestDefines.h"
#import "ParseHTMLPageTask.h"

#define URL_CONTENT(url, cls) [[NSString alloc] initWithData:[HelperUnitTest stubFileContentForURL:url forBundleClass:cls] encoding:NSUTF8StringEncoding]

@interface ParseHTMLPageTaskTests : XCTestCase

@end

@implementation ParseHTMLPageTaskTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testIfParsedHTMLObjectIsTheResult{
    EXP_START(@"testIfParsedHTMLObjectIsTheResult");
    [[[[ParseHTMLPageTask alloc] initWithHTMLPageContent:nil] task] chain:^id(ChainableTask *task) {
        XCTAssertTrue([task.result isKindOfClass:[ParsedHTMLObject class]]);
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
}

-(void)testIfErrorIsProvided{
    
    EXP_START(@"testIfErrorIsProvided");
    
    [[[[ParseHTMLPageTask alloc] initWithHTMLPageContent:@"<html><title>hello</html>"] task] chain:^id(ChainableTask *task) {
        XCTAssertNil(task.result);
        
        NSError *error = task.error;
        XCTAssertNotNil(error);

        XCTAssertEqual(error.code, kTitleParseErrorCode);
        XCTAssertTrue([error.domain isEqualToString:kTitleParseError]);
        EXP_FULFILL();
        return nil;
    }];
    EXP_END();
    
}

- (void)testParseHTMLPageTask {
    
    EXP_START(@"testParseHTMLPageTask");
    
    NSString *content = URL_CONTENT(@"http://www.titlewithnewline.com", [self class]);
    
    [[[[[[[[[[ParseHTMLPageTask alloc] initWithHTMLPageContent:content] task] chain:^id(ChainableTask *task) {
        ParsedHTMLObject *result = task.result;
        XCTAssertTrue([@"title with new line" isEqualToString:result.title]);

        return [[[ParseHTMLPageTask alloc] initWithHTMLPageContent:URL_CONTENT(@"http://www.invalidtitletag.com", [self class])] task];
    }] chain:^id(ChainableTask *task) {
        ParsedHTMLObject *result = task.result;
        XCTAssertNil(result.title);
        XCTAssertNotNil(task.error);
        
        return [[[ParseHTMLPageTask alloc] initWithHTMLPageContent:URL_CONTENT(@"http://www.titlewithspecialcharacter.com", [self class])] task];
    }] chain:^id(ChainableTask *task) {
        ParsedHTMLObject *result = task.result;
        XCTAssertTrue([@"!@#$%^&*()_+=-.,<>?/:;\"'{}[]|\\`~" isEqualToString:result.title]);
        return [[[ParseHTMLPageTask alloc] initWithHTMLPageContent:URL_CONTENT(@"http://www.emptytitle.com", [self class])] task];
    }] chain:^id(ChainableTask *task) {
        ParsedHTMLObject *result = task.result;
        XCTAssertTrue([@"" isEqualToString:result.title]);
        return [[[ParseHTMLPageTask alloc] initWithHTMLPageContent:URL_CONTENT(@"http://www.notitletag.com", [self class])] task];
    }] chain:^id(ChainableTask *task) {
        ParsedHTMLObject *result = task.result;
        XCTAssertNil(result.title);
        XCTAssertNotNil(task.error);
        
        return [[[ParseHTMLPageTask alloc] initWithHTMLPageContent:URL_CONTENT(@"http://www.titletagwithattribute.com", [self class])] task];
    }] chain:^id(ChainableTask *task) {
        ParsedHTMLObject *result = task.result;
        XCTAssertTrue([@"attributted title" isEqualToString:result.title]);
        return [[[ParseHTMLPageTask alloc] initWithHTMLPageContent:URL_CONTENT(@"https://twitter.com/jdorfman/status/430511497475670016", [self class])] task];;
    }] chain:^id(ChainableTask *task) {
        ParsedHTMLObject *result = task.result;
        XCTAssertTrue([@"Justin Dorfman on Twitter: \"nice @littlebigdetail from @HipChat (shows hex colors when pasted in chat). http://t.co/7cI6Gjy5pq\"" isEqualToString:result.title]);
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
    
}

@end
