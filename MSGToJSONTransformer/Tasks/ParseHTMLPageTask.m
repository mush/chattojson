//
//  FetchHTMLPageTitleTask.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/21/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "ParseHTMLPageTask.h"
#import "RegExMatcherTask.h"

@interface ParseHTMLPageTask ()
@property(copy) NSString *content;
@end

@implementation ParseHTMLPageTask

-(instancetype)initWithHTMLPageContent:(NSString*)content{
    
    if (self = [super init]) {
        self.content = content;
    }
    
    return self;
}

-(ChainableTask *)task{
    
    ChainableTask *task = [ChainableTask new];
    
    NSScanner *scanner = [NSScanner scannerWithString:self.content];
    NSString *test;
    NSInteger startOfTitle = 0;
    NSInteger endOfTitle = 0;
    BOOL valid = true;
    [scanner scanUpToString:@"<title" intoString:&test];
    valid = valid && scanner.scanLocation < (self.content.length - 1);
    [scanner scanUpToString:@">" intoString:&test];
    valid = valid && scanner.scanLocation < (self.content.length - 1);
    startOfTitle = scanner.scanLocation + 1;
    [scanner scanUpToString:@"</title>" intoString:&test];
    valid = valid && scanner.scanLocation < (self.content.length - 1);
    endOfTitle = scanner.scanLocation - 1;
    
    if(valid){
        NSString *title = [self.content substringWithRange:NSMakeRange(startOfTitle, endOfTitle - startOfTitle + 1)];
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [task trySetResult:[[ParsedHTMLObject alloc]initWithTitle:title]];
    }else{        
        [task trySetError:[NSError errorWithDomain:kTitleParseError code:kTitleParseErrorCode userInfo:nil]];
    }
    
    return task;
}

@end
