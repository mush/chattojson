//
//  ParsedHTMLObject.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/18/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "ParsedHTMLObject.h"

@implementation ParsedHTMLObject
-(instancetype)initWithTitle:(NSString *)title{
    
    if (self = [super init]) {
        self.title = title;
    }
    return self;
}
@end
