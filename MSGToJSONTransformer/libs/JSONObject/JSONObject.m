//
//  BaseModel.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/17/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "JSONObject.h"
#import <objc/runtime.h>

NSString * const kErrorJSONObjectTransform = @"com.JSONObject.transformObj";
NSString * const kErrorArrayTransform = @"com.NSArray.transform";
NSString * const kErrorDictTransform = @"com.NSDictionary.transform";


@implementation JSONObject (Helper)
+(BOOL)isAPrimitiveClassObj:(id)obj{
    
    for(Class cls in @[[NSString class], [NSNumber class], [NSNull class]]){
        if([obj isKindOfClass:cls])
            return YES;
    }
    return NO;
}
+(id)transformObj:(id)obj error:(NSError**)error{

    if (obj == nil) {
        return [NSNull null];
    }
    
    if([obj isKindOfClass:[JSONObject class]]){
        return [((JSONObject*)obj) toDict];
    }else if([obj isKindOfClass:[NSArray class]]){
        return [((NSArray*)obj) transform];
    }else if ([obj isKindOfClass:[NSDictionary class]]){
        return [((NSDictionary*)obj) transform];
    }else if ([self isAPrimitiveClassObj:obj]){
        return obj;
    }else{
        *error = [NSError errorWithDomain:kErrorJSONObjectTransform code:40000 userInfo:nil];
        return nil;
    }
}

@end


@implementation NSArray (JSONObjectTransformer)

-(NSArray*)transform{
    
    NSMutableArray *result = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSError *error;
        id item = [JSONObject transformObj:obj error:&error];
        if(!error){
            [result addObject:item];
        }else{
            [NSException raise:kErrorArrayTransform format:@"unsupported type to transform"];
        }
    }];
    
    return result;
}

@end


@implementation NSDictionary (JSONObjectTransformer)

-(NSDictionary*)transform{
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for(NSString *key in self){
        NSError *error;
        id obj = [JSONObject transformObj:self[key] error:&error];
        if(!error){
            result[key] = obj;
        }else{
            [NSException raise:kErrorDictTransform format:@"unsupported type to transform"];
        }
    }
    
    return result;
}

@end


@implementation JSONObject

#pragma mark - NSCopying
-(id)copyWithZone:(NSZone *)zone{
    Class cls = [self class];
    JSONObject *copyObj = [[self class] new];

    while(cls != [JSONObject class]){
        unsigned int count;
        objc_property_t *props = class_copyPropertyList(cls, &count);
        
        for (int i = 0; i < count; i++) {
            objc_property_t prop_t = props[i];
            const char *name = property_getName(prop_t);
            NSString *propName = @(name);
            id value = [self valueForKey:propName];
            
            [copyObj setValue:value forKey:propName];
        }
        
        free(props);
        cls = [cls superclass];
    }
    
    return copyObj;
}

#pragma mark - NSObject
-(BOOL)isEqual:(id)object{
    return [self isEqualToJSONObject:object];
}
#pragma mark - Public
-(BOOL)isEqualToJSONObject:(JSONObject *)obj{
    if([self isMemberOfClass:[obj class]] == NO){
        return false;
    }
    
    return [[self toDict] isEqualToDictionary:[obj toDict]];
}
-(NSDictionary *)toDict{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    Class cls = [self class];
    while(cls != [JSONObject class]){
        
        unsigned int count;
        objc_property_t *props = class_copyPropertyList(cls, &count);
        
        for (int i = 0; i < count; i++) {
            objc_property_t prop_t = props[i];
            const char *name = property_getName(prop_t);
            NSString *propName = @(name);
            
            id value = [self valueForKey:propName];
            NSError *error = nil;
            id obj = [JSONObject transformObj:value error:&error];
            if(!error){
                dict[propName] = obj;
            }else{
                [NSException raise:error.domain format:@"unsupported type to transform"];
            }        
        }
        
        free(props);
        cls = [cls superclass];
    }
    
    return dict;
}
-(NSString *)toJSONString{

    NSData *data = [NSJSONSerialization dataWithJSONObject:[self toDict] options:NSJSONWritingPrettyPrinted error:NULL];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}
@end
