//
//  LinkModel.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/17/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "LinkObject.h"

@implementation LinkObject

-(instancetype)initWithUrl:(NSString *)url title:(NSString *)title{
    
    if (self = [super init]) {
        self.url = url;
        self.title = title;
    }
    
    return self;
}

+(LinkObject*)testModel{
    
    LinkObject *m = [LinkObject new];
    m.url = [NSString stringWithFormat:@"http://www.%ld.com", [m hash]];
    m.title = [NSString stringWithFormat:@"title-%ld", [m hash]];
    
    return m;
}
@end
