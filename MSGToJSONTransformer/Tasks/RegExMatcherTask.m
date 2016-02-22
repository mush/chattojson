//
//  StringParser.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/14/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "RegExMatcherTask.h"

static NSString* re_str_mention = @"@(\\w+)";
static NSString* re_str_emoticon = @"\\((\\w{1,15})\\)";

@interface RegExMatcherTask ()
@property(copy) NSString *sourceString;
@property(strong) NSMutableDictionary *groups;
@end

@implementation RegExMatcherTask{
    
}

#pragma mark - Private

-(NSArray*)matchesForReStr:(NSString*)reStr{
    
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:reStr options:NSRegularExpressionCaseInsensitive error:NULL];
    
    NSMutableArray *output = [NSMutableArray array];
    [re enumerateMatchesInString:self.sourceString options:0 range:NSMakeRange(0, self.sourceString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if(result){
            [output addObject:[self.sourceString substringWithRange:[result rangeAtIndex:1]]];
        }
    }];
    return output;
}


#pragma mark - NSObject

-(instancetype)initWithString:(NSString*)str{
    
    if(self = [super init]){
        self.sourceString = str;
        self.groups = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - Public
-(void)addCapturingGroup:(NSString*)group forKey:(NSString*)key{
    self.groups[key] = group;
}

-(ChainableTask *)task{
    return [[ChainableTask taskWithResult:nil] chainForSuccess:^id(ChainableTask *task) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        
        for(NSString *key in self.groups){
            result[key] = [self matchesForReStr:self.groups[key]];
        }
        
        return result;
        
    }];
}

@end
