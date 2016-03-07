//
//  TextToJSONObjectTransformerTaskTest.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/28/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPageStubManager.h"
#import "TextToJSONObjectTransformerTask.h"
#import "HelperUnitTest.h"
#import "TestDefines.h"
#import "ParallelTask.h"

@interface TextToJSONObjectTransformerTaskTest : XCTestCase

@end

@implementation TextToJSONObjectTransformerTaskTest

- (void)setUp {
    [super setUp];
    [[HTMLPageStubManager sharedManager] setup];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [[HTMLPageStubManager sharedManager] tearDown];
}
-(void)testIfResultIsChatMsgObjectType{
    EXP_START(@"testIfErrorIsProvided");
    [[[[TextToJSONObjectTransformerTask alloc] initWithText:@"hello @mush (smiley)"] task] chain:^id(ChainableTask *task) {
        XCTAssertTrue([task.result isKindOfClass:[ChatMsgObject class]]);
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
}
-(void)testMsgEmpty{
    EXP_START(@"testMsgEmpty");
    
    [[[[TextToJSONObjectTransformerTask alloc] initWithText:nil] task] chain:^id(ChainableTask *task) {
        XCTAssertNotNil(task.result);
        XCTAssertNil(task.error);
        
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
}

-(void)testTask{
    EXP_START(@"testTask");
    
    ChainableTask *taskSimple = [[[TextToJSONObjectTransformerTask alloc]initWithText:@"hello @mush (smiley). check this out http://www.google.com"] task];
    
    [taskSimple chainForSuccess:^id(ChainableTask *task) {
        XCTAssertTrue([task.result isKindOfClass:[ChatMsgObject class]], @"provided object is not ChatMsgObject");
        
        ChatMsgObject *expectObj = [[ChatMsgObject alloc]initWithMentions:@[@"mush"] emoticons:@[@"smiley"] links:@[[[LinkObject alloc]initWithUrl:@"http://www.google.com" title:@"Google"]]];
        ChatMsgObject *found = task.result;
        
        XCTAssertTrue([found isEqualToJSONObject:expectObj]);
        
        EXP_FULFILL();
        
        return nil;
    }];
    
    
    EXP_END();
}

- (void)testTaskForMentionsAndEmoticonsForText {
    EXP_START(@"testTaskForMentionsAndEmoticonsForText");

    NSArray<ChainableTask*> *testTasksEmoticon = @[[TextToJSONObjectTransformerTask taskForEmoticonsForText:@"alphanumeric (0123456789abc)"],
                                                [TextToJSONObjectTransformerTask taskForEmoticonsForText:@"invalid (non+char) (with space)"],
                                                [TextToJSONObjectTransformerTask taskForEmoticonsForText:@"look at this (nested(smiley))"],
                                                [TextToJSONObjectTransformerTask taskForEmoticonsForText:@"look at this (thisislongerthan15characterlong)"],
                                                [TextToJSONObjectTransformerTask taskForEmoticonsForText:@"look at this empty smile ()"],
                                                [TextToJSONObjectTransformerTask taskForEmoticonsForText:@"look at this smile (1)"],
                                                [TextToJSONObjectTransformerTask taskForEmoticonsForText:@"(multiple) (smiley) (smiley)"]];

    
    ChainableTask *tasksForEmoticons = [[ParallelTask runAllTasks:testTasksEmoticon] chainForSuccess:^id(ChainableTask *task) {
        //0
        NSSet *expected = [NSSet setWithObject:@"0123456789abc"];
        NSSet *result = task.result[0];
        XCTAssertTrue([expected isEqualToSet:result], @"alphanumeric failed");
        
        //1
        expected = [NSSet set];
        result = task.result[1];
        XCTAssertTrue([expected isEqualToSet:result], @"invalid char test failed");
        
        //2
        expected = [NSSet setWithObject:@"smiley"];
        result = task.result[2];
        XCTAssertTrue([expected isEqualToSet:result], @"nested test failed");
        
        //3
        expected = [NSSet set];
        result = task.result[3];
        XCTAssertTrue([expected isEqualToSet:result], @"long emoticon test failed");
        
        //4
        expected = [NSSet set];
        result = task.result[4];
        XCTAssertTrue([expected isEqualToSet:result], @"empty emoticon test failed");
        
        //5
        expected = [NSSet setWithObject:@"1"];
        result = task.result[5];
        XCTAssertTrue([expected isEqualToSet:result], @"min length emoticon test failed");
        
        //6
        NSSet *expectedSet = [NSSet setWithObjects:@"multiple", @"smiley", nil];
        NSSet *resultSet = task.result[6];
        XCTAssertTrue([expectedSet isEqualToSet:resultSet], @"mulitple emoticon test failed");
        
        return nil;
    }];
    
    
    NSArray<ChainableTask*> *testTasksMention = @[[TextToJSONObjectTransformerTask taskForMentionsForText:@"wordchars @Abc_0123 "],
                                                  [TextToJSONObjectTransformerTask taskForMentionsForText:@"invalid @mu*sh "],
                                                  [TextToJSONObjectTransformerTask taskForMentionsForText:@"not mentions"],
                                                  [TextToJSONObjectTransformerTask taskForMentionsForText:@"@back@to@back"],
                                                  [TextToJSONObjectTransformerTask taskForMentionsForText:@"@attached(withemo)"]];
    
    ChainableTask *tasksForMentions = [[ParallelTask runAllTasks:testTasksMention] chainForSuccess:^id(ChainableTask *task) {
        
        //0
        NSSet *expected = [NSSet setWithObject:@"Abc_0123"];
        NSSet *result = task.result[0];
        XCTAssertTrue([expected isEqualToSet:result], @"wordchars failed");
        
        //1
        expected = [NSSet setWithObject:@"mu"];
        result = task.result[1];
        XCTAssertTrue([expected isEqualToSet:result], @"invalid char test failed");
        
        //2
        expected = [NSSet set];
        result = task.result[2];
        XCTAssertTrue([expected isEqualToSet:result], @"no mentions test failed");
        
        //3
        expected = [NSSet setWithObjects:@"back", @"to", nil];
        result = task.result[3];
        XCTAssertTrue([expected isEqualToSet:result], @"no mentions test failed");
        
        //4
        expected = [NSSet setWithObject:@"attached"];
        result = task.result[4];
        XCTAssertTrue([expected isEqualToSet:result], @"no mentions test failed");
        
        return nil;
    }];
    
    
    ChainableTask *basic = [TextToJSONObjectTransformerTask taskForEmoticonsForText:@"hello @mush (smiley)"];
    
    [[[[basic chainForSuccess:^id(ChainableTask *task) {
        
        
        
        return tasksForEmoticons;
    }] chainForSuccess:^id(ChainableTask *task) {
        return tasksForMentions;
    }] chainForSuccess:^id(ChainableTask *task) {
        return nil;
    }] chainForSuccess:^id(ChainableTask *task) {
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
    
}
-(void)testTaskForPageTitleForURL{
    EXP_START(@"testTaskForPageTitleForURL");
    ChainableTask *aGenericPage = [TextToJSONObjectTransformerTask taskForPageTitleForURL:[NSURL URLWithString:@"https://www.google.com.au"]];
    ChainableTask *nonExistantPage = [TextToJSONObjectTransformerTask taskForPageTitleForURL:[NSURL URLWithString:@"http://www.weiru3kjkdfksjf9893kjfsd.com"]];
    
    [[aGenericPage chainForSuccess:^id(ChainableTask *task) {
        
        LinkObject *result = task.result;
        
        XCTAssertTrue([@"Google" isEqualToString:result.title]);
        XCTAssertTrue([@"https://www.google.com.au" isEqualToString:result.url]);
        return nonExistantPage;
    }] chainForSuccess:^id(ChainableTask *task) {
        
        LinkObject *result = task.result;
        
        XCTAssertTrue([@"" isEqualToString:result.title]);
        XCTAssertTrue([@"http://www.weiru3kjkdfksjf9893kjfsd.com" isEqualToString:result.url]);
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
}

-(void)testTaskForPageTitleForURLPart2{
    EXP_START(@"testTaskForPageTitleForURLPart2");
    
    ChainableTask *nbolympic = [TextToJSONObjectTransformerTask taskForPageTitleForURL:[NSURL URLWithString:@"http://www.nbcolympics.com"]];
    ChainableTask *urlWithQueryParam = [TextToJSONObjectTransformerTask taskForPageTitleForURL:[NSURL URLWithString:@"https://twitter.com/jdorfman/status/430511497475670016"]];
    
    [[nbolympic chainForSuccess:^id(ChainableTask *task) {
        LinkObject *result = task.result;
        XCTAssertTrue([@"NBC Olympics | Home of the 2016 Olympic Games in Rio" isEqualToString:result.title]);
        return urlWithQueryParam;
    }] chainForSuccess:^id(ChainableTask *task) {
        LinkObject *result = task.result;
        XCTAssertTrue([@"Justin Dorfman on Twitter: \"nice @littlebigdetail from @HipChat (shows hex colors when pasted in chat). http://t.co/7cI6Gjy5pq\"" isEqualToString:result.title]);
        EXP_FULFILL();
        return nil;
    }];
    
    EXP_END();
}

@end
