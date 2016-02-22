//
//  RegExMatcherTaskTest.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/28/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestDefines.h"
#import "RegExMatcherTask.h"

@interface RegExMatcherTaskTest : XCTestCase

@end

@implementation RegExMatcherTaskTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testIfErrorIsHandled{
    EXP_START(@"testIfErrorIsHandled");
    RegExMatcherTask *regex = [[RegExMatcherTask alloc] initWithString:nil];
    [regex addCapturingGroup:@".*" forKey:@"all"];
    
    [[regex task] chain:^id(ChainableTask *task) {
        XCTAssertNil(task.result);
        XCTAssertNotNil(task.error);
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
}

- (void)testBasic {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    EXP_START(@"testBasic");
    
    RegExMatcherTask *regex = [[RegExMatcherTask alloc] initWithString:@"aaa bbb (aa) @cc@cc @dd(bb)"];
    [regex addCapturingGroup:@"\\((\\w{2,15})\\)" forKey:@"emoticons"];
    [regex addCapturingGroup:@"@(\\w+)" forKey:@"mentions"];
    
    [[regex task] chain:^id(ChainableTask *task) {

        NSSet *response = [NSSet setWithArray:task.result[@"emoticons"]];
        NSSet *expected = [NSSet setWithArray:@[@"aa",@"bb"]];
        XCTAssertTrue([response isEqualToSet:expected]);
        
        response = [NSSet setWithArray:task.result[@"mentions"]];
        expected = [NSSet setWithArray:@[@"cc",@"cc", @"dd"]];
        XCTAssertTrue([response isEqualToSet:expected]);
        
        EXP_FULFILL();
        return nil;
    }];
    EXP_END();
}

- (void)testForEmoticons {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    EXP_START(@"testForEmoticons");
    
    RegExMatcherTask *regex = [[RegExMatcherTask alloc] initWithString:@"aaa (ad)(jacent) (should not capture) (nes(ted))"];
    [regex addCapturingGroup:@"\\(([a-zA-Z0-9]{1,15})\\)" forKey:@"emoticons"];
    
    [[regex task] chain:^id(ChainableTask *task) {
        
        NSSet *response = [NSSet setWithArray:task.result[@"emoticons"]];
        NSSet *expected = [NSSet setWithArray:@[@"ad",@"jacent",@"ted"]];
        XCTAssertTrue([response isEqualToSet:expected]);
        EXP_FULFILL();
        return nil;
    }];
    EXP_END();
}

-(void)testForMentions{

    EXP_START(@"testForMentions");
    
    RegExMatcherTask *regex = [[RegExMatcherTask alloc] initWithString:@"@aa @@bb @cc@dd @12ab @a_b @ab_12 @xx-yy "];
    [regex addCapturingGroup:@"@(\\w+)" forKey:@"mentions"];
    
    [[regex task] chain:^id(ChainableTask *task) {
        
        NSSet *response = [NSSet setWithArray:task.result[@"mentions"]];
        NSSet *expected = [NSSet setWithArray:@[@"aa",@"bb",@"cc",@"dd",@"12ab",@"a_b",@"ab_12",@"xx"]];
        XCTAssertTrue([response isEqualToSet:expected]);
        EXP_FULFILL();
        return nil;
    }];
    EXP_END();

}

@end
