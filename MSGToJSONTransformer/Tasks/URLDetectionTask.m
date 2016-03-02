//
//  DetectingURLsTask.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/24/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "URLDetectionTask.h"
#import "RegExMatcherTask.h"

@implementation URLDetectionTask{
    NSString *_text;
}
-(instancetype)initWithText:(NSString *)text{
    if (self = [super init]) {
        _text = [text copy];
    }
    return self;
}

-(ChainableTask *)task{
    
    if(_text == nil || _text.length == 0){
        return [ChainableTask taskWithResult:[[DetectedUrlObject alloc]initWithUrls:@[] trimmedText:@""]];
    }
    
    return [[ChainableTask taskWithResult:nil] chainForSuccess:^id(ChainableTask *task) {
        NSError *error = nil;
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        
        NSMutableSet *urls = [NSMutableSet set];
        

        NSMutableString *trimmedString = [NSMutableString string];
        __block NSInteger startIndex = 0, lastIndex;

        [linkDetector enumerateMatchesInString:_text options:NSMatchingReportProgress range:NSMakeRange(0, _text.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            
            if([result URL]){
                
                [urls addObject:[result URL]];
                
                lastIndex = result.range.location - 1;
                [trimmedString appendString:[_text substringWithRange:NSMakeRange(startIndex, lastIndex - startIndex + 1)]];
                startIndex = lastIndex + result.range.length + 1;
            }
            
        }];
        
        [trimmedString appendString:[_text substringWithRange:NSMakeRange(startIndex, _text.length - startIndex)]];
        
        return [[DetectedUrlObject alloc]initWithUrls:[urls allObjects] trimmedText:trimmedString];
    }];
        
}

@end
