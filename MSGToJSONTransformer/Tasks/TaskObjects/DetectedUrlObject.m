//
//  DetectedUrlObject.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 3/2/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "DetectedUrlObject.h"

@implementation DetectedUrlObject

-(instancetype)initWithUrls:(NSArray *)urls trimmedText:(NSString *)trimmedText{
    
    if (self = [super init]) {
        self.urls = urls;
        self.trimmedText = trimmedText;
    }
    
    return self;
}

@end
