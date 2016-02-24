//
//  JSONObject+HipChat.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/22/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "JSONObject+HipChat.h"

@implementation JSONObject (HipChat)
-(NSDictionary *)toDict2{
    NSMutableDictionary *output = [NSMutableDictionary dictionary];

    NSDictionary *dict = [self toDict];
    for (NSString *key in dict) {
        if([dict[key] isKindOfClass:[NSNull class]]){
            continue;
        }
        if([dict[key] isKindOfClass:[NSArray class]] && [dict[key] count] > 0){
            output[key] = dict[key];
        }else if ([dict[key] isKindOfClass:[NSDictionary class]] && [[dict[key] allKeys] count] > 0){
            output[key] = dict[key];
        }
    }
    
    return output;
}

-(NSString *)toJSONString2{
    NSData *data = [NSJSONSerialization dataWithJSONObject:[self toDict2] options:NSJSONWritingPrettyPrinted error:NULL];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
