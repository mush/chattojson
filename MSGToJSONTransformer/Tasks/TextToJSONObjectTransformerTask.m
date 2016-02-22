//
//  TextToJSONObjectTransformerTask.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/23/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "TextToJSONObjectTransformerTask.h"
#import "RegExMatcherTask.h"
#import "ParseHTMLPageTask.h"
#import "FetchHTMLPageContentTask.h"
#import "ParallelTask.h"
#import "LinkObject.h"

NSString *const KEY_MENTIONS = @"KEY_MENTIONS";
NSString *const KEY_EMOTICONs = @"KEY_EMOTICONs";

@interface TextToJSONObjectTransformerTask ()
@property(copy) NSString *text;
@end

@implementation TextToJSONObjectTransformerTask
-(instancetype)initWithText:(NSString*)text{
    
    if (self = [super init]) {
        self.text = text;
    }
    
    return self;
}

-(ChainableTask *)task{
    
    __block NSArray<LinkObject*> *links;
    __block NSArray *mentions;
    __block NSArray *emoticons;
    
    if(!self.text || self.text.length == 0){
        return [ChainableTask taskWithResult:[[ChatMsgObject alloc]initWithMentions:@[] emoticons:@[] links:@[]]];
    }
    
    //detect urls.
    return [[[[[[ChainableTask taskWithResult:nil] chainForSuccess:^id(ChainableTask *task) {

        return [TextToJSONObjectTransformerTask taskForDetectingUniqueURLsInText:self.text];
    }]  //then fetch title for all urls
        chainForSuccess:^id(ChainableTask *task) {

            NSMutableArray *tasks = [NSMutableArray array];
            for(NSURL *url in task.result){
                [tasks addObject:[TextToJSONObjectTransformerTask taskForPageTitleForURL:url]];
            }
            
            return [ParallelTask runAllTasks:tasks];
    }]  //then grab mentions
        chainForSuccess:^id(ChainableTask *task) {
            
            links = task.result;
            
            return [TextToJSONObjectTransformerTask taskForMentionsForText:self.text];
    }]  chain:^id(ChainableTask *task) {
            mentions = task.result;
            return [TextToJSONObjectTransformerTask taskForEmoticonsForText:self.text];
    }]  //finally perform json serialization
        chain:^id(ChainableTask *task) {
            emoticons = task.result;
            return [[ChatMsgObject alloc]initWithMentions:mentions emoticons:emoticons links:links];
    }];
}

@end


@implementation TextToJSONObjectTransformerTask (CompositeTask)
+(ChainableTask*)taskForDetectingUniqueURLsInText:(NSString*)text{
    
    return [[ChainableTask taskWithResult:nil] chainForSuccess:^id(ChainableTask *task) {
        NSError *error = nil;
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        
        NSMutableSet *urls = [NSMutableSet set];
        
        [linkDetector enumerateMatchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            
            if([result URL]){
                [urls addObject:[result URL]];
            }
            
        }];
        
        return urls;
    }];
    
}

+(ChainableTask*)taskForMentionsForText:(NSString*)text{
    
    static NSString * const keyMentions = @"mentions";
    
    //mentions always start with an '@' and ends when hitting a non-word character
    static NSString * const kRegExMentions = @"@(\\w+)";
    
    RegExMatcherTask *matcher = [[RegExMatcherTask alloc]initWithString:text];
    
    [matcher addCapturingGroup:kRegExMentions forKey:keyMentions];
    
    return [[matcher task] chain:^id(ChainableTask *task) {
        NSArray *mentions = [NSArray arrayWithArray:[[NSSet setWithArray:task.result[keyMentions]] allObjects]];
        return [ChainableTask taskWithResult:mentions];
    }];
}

+(ChainableTask*)taskForEmoticonsForText:(NSString*)text{
    
    static NSString * const keyEmoticons = @"emoticons";
    
    //emoticons which are alphanumeric strings, no longer than 15 characters, contained in parenthesis
    static NSString * const kRegExEmoticons = @"\\(([a-zA-Z0-9]{1,15})\\)";
    
    RegExMatcherTask *matcher = [[RegExMatcherTask alloc]initWithString:text];
    
    [matcher addCapturingGroup:kRegExEmoticons forKey:keyEmoticons];
    
    return [[matcher task] chain:^id(ChainableTask *task) {
        NSArray *emoticons = [NSArray arrayWithArray:[[NSSet setWithArray:task.result[keyEmoticons]] allObjects]];
        return [ChainableTask taskWithResult:emoticons];
    }];
}

+(ChainableTask*)taskForPageTitleForURL:(NSURL*)url{
    
    FetchHTMLPageContentTask *htmlTask = [[FetchHTMLPageContentTask alloc]initWithURL:url];
    
    return [[[[htmlTask task] chain:^id(ChainableTask *task) {
        ParseHTMLPageTask *parseHTMLTask = [[ParseHTMLPageTask alloc]initWithHTMLPageContent:task.result];
        return [parseHTMLTask task];
    }] chainForSuccess:^id(ChainableTask *task) {
        NSString *title = @"";
        ParsedHTMLObject *result = task.result;
        if (task.result && result.title) {
            title = result.title;
        }
        return [[LinkObject alloc]initWithUrl:url.absoluteString title:title];
    }] chain:^id(ChainableTask *task) {
        if(task.error){
            return [[LinkObject alloc]initWithUrl:url.absoluteString title:@""];
        }else{
            return task.result;
        }
    }];
}

@end