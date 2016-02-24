//
//  DetectingURLsTask.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/24/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "URLDetectionTask.h"
#import "RegExMatcherTask.h"

@implementation DetectedUrlObject

-(instancetype)initWithUrls:(NSArray *)urls trimmedText:(NSString *)trimmedText{
    
    if (self = [super init]) {
        self.urls = urls;
        self.trimmedText = trimmedText;
    }
    
    return self;
}

-(id)copyWithZone:(NSZone *)zone{
    return [[DetectedUrlObject alloc]initWithUrls:self.urls trimmedText:self.trimmedText];
}

@end

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
    
    NSError *error = nil;
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    
    NSMutableSet *urls = [NSMutableSet set];
    
    [linkDetector enumerateMatchesInString:_text options:NSMatchingReportProgress range:NSMakeRange(0, _text.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        
        if([result URL]){
            [urls addObject:[result URL]];
        }
        
    }];
    
    __block NSString *trimmedString = _text;
    
    [urls enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *urlStr = [obj absoluteString];
        trimmedString = [trimmedString stringByReplacingOccurrencesOfString:urlStr withString:@""];
    }];
    
    return [ChainableTask taskWithResult:[[DetectedUrlObject alloc]initWithUrls:[urls allObjects] trimmedText:trimmedString]];
}

@end
