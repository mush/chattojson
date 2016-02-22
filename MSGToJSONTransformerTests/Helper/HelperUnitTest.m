//
//  HelperUnitTest.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/7/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "HelperUnitTest.h"

@implementation HelperUnitTest
+(NSSet*)urlSetFromStringUrl:(NSString*)firstObj, ... NS_REQUIRES_NIL_TERMINATION{
    NSMutableSet *result = [NSMutableSet set];
    va_list args;
    va_start(args, firstObj);
    
    for(NSString *arg = firstObj; arg != nil; arg = va_arg(args, NSString*)){
        [result addObject:[NSURL URLWithString:arg]];
    }
    
    return result;
}
+(NSString*)convertURLToStubFileName:(NSString*)url{
    NSMutableString *str = [NSMutableString stringWithString:url];
    
    [str replaceOccurrencesOfString:@"://" withString:@"-" options:NSCaseInsensitiveSearch range:NSMakeRange(0, str.length)];
    [str replaceOccurrencesOfString:@"/" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, str.length)];
    
    return str;
}
+(NSData*)stubFileContentForURL:(NSString*)url forBundleClass:(Class)cls{
    return [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:cls] URLForResource:[HelperUnitTest convertURLToStubFileName:url] withExtension:@"stub"]];
}
@end
