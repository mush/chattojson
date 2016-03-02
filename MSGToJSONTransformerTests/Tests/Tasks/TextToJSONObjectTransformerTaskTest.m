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

//-(void)testTaskForDetectingUniqueURLsInText{
//    EXP_START(@"testTaskForDetectingUniqueURLsInText");
//    ChainableTask *taskPlainURL = [TextToJSONObjectTransformerTask taskForDetectingUniqueURLsInText:@"plain url http://www.google.com.au"];
//    ChainableTask *taskMulipleURLs = [TextToJSONObjectTransformerTask taskForDetectingUniqueURLsInText:@"muliple urls http://www.google.com.au and http://www.twitter.com"];
//    ChainableTask *taskMultipleSameURLs = [TextToJSONObjectTransformerTask taskForDetectingUniqueURLsInText:@"same urls http://www.google.com.au and http://www.google.com.au"];
//    ChainableTask *taskNoUrl = [TextToJSONObjectTransformerTask taskForDetectingUniqueURLsInText:@"no url"];
//    ChainableTask *taskUrlWithQueryParams = [TextToJSONObjectTransformerTask taskForDetectingUniqueURLsInText:@"url with query params https://www.google.com.au/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=query+parameters"];
//    
//    [[ParallelTask runAllTasks:@[taskPlainURL, taskMulipleURLs, taskMultipleSameURLs, taskNoUrl, taskUrlWithQueryParams]] chainForSuccess:^id(ChainableTask *task) {
//        
//        //0
//        NSSet *expected = [HelperUnitTest urlSetFromStringUrl:@"http://www.google.com.au", nil];
//        NSSet *result = task.result[0];
//        XCTAssertTrue([expected isEqualToSet:result], @"failed for plain url type");
//        
//        //1
//        expected = [HelperUnitTest urlSetFromStringUrl:@"http://www.google.com.au", @"http://www.twitter.com", nil];
//        result = task.result[1];
//        XCTAssertTrue([expected isEqualToSet:result], @"multiple urls detection failed");
//        
//        //2
//        result = task.result[2];
//        XCTAssertTrue(result.count == 1, @"multiple same url detection failed. count didnt match");
//        expected = [HelperUnitTest urlSetFromStringUrl:@"http://www.google.com.au", nil];
//        XCTAssertTrue([expected isEqualToSet:result], @"multiple same url detection failed");
//        
//        //3
//        result = task.result[3];
//        XCTAssertTrue(result.count == 0, @"count should be 0");
//        expected = [HelperUnitTest urlSetFromStringUrl:nil];
//        XCTAssertTrue([expected isEqualToSet:result], @"no url case failed");
//        
//        //4
//        result = task.result[4];
//        expected = [HelperUnitTest urlSetFromStringUrl:@"https://www.google.com.au/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=query+parameters", nil];
//        XCTAssertTrue([expected isEqualToSet:result], @"failed for url with query params");
//
//        EXP_FULFILL();
//        return nil;
//    }];
//    
//    
//    EXP_END();
//    
//}

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
                                                  [TextToJSONObjectTransformerTask taskForMentionsForText:@"not mentions"]];
    
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
        
        return nil;
    }];
    
    
//    NSArray<ChainableTask*> *testTaskOther = @[[TextToJSONObjectTransformerTask taskForMentionsAndEmoticonsForText:@"@back@to@back"],
//                                               [TextToJSONObjectTransformerTask taskForMentionsAndEmoticonsForText:@"@attached(withemo)"],
//                                               [TextToJSONObjectTransformerTask taskForMentionsAndEmoticonsForText:@"a @general msg (smiley)."]];
//    
//    ChainableTask *tasksOthers = [[ParallelTask runAllTasks:testTaskOther] chainForSuccess:^id(ChainableTask *task) {
//        //0
//        NSSet *expectedSet = [NSSet setWithArray:@[@"back", @"to"]];
//        NSSet *resultSet = [NSSet setWithArray:task.result[0][@"mentions"]];
//        XCTAssertTrue([task.result[0] count] == expectedSet.count, @"back to back mentions count didnt' match");
//        XCTAssertTrue([expectedSet isEqualToSet:resultSet], @"back to back mentions failed");
//        
//        
//        //1
//        NSArray *expected = @[@"attached"];
//        NSArray *result = task.result[1][@"mentions"];
//        XCTAssertTrue([expected isEqualToArray:result], @"attached with emoticons test failed");
//        expected = @[@"withemo"];
//        result = task.result[1][@"emoticons"];
//        XCTAssertTrue([expected isEqualToArray:result], @"attached with emoticons test failed");
//        
//        //2
//        expected = @[@"general"];
//        result = task.result[2][@"mentions"];
//        XCTAssertTrue([expected isEqualToArray:result], @"general test failed");
//        expected = @[@"smiley"];
//        result = task.result[2][@"emoticons"];
//        XCTAssertTrue([expected isEqualToArray:result], @"general test failed");
//        
//        
//        return nil;
//    }];

    ChainableTask *basic = [TextToJSONObjectTransformerTask taskForEmoticonsForText:@"hello @mush (smiley)"];
    
    [[[[basic chainForSuccess:^id(ChainableTask *task) {
        //XCTAssertNotNil(task.result[@"mentions"], @"mentions key doesnt exist");
        //XCTAssertNotNil(task.result[@"emoticons"], @"emoticons key doesn't exist");
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
