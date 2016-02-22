//
//  HelperUnitTest.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/7/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HelperUnitTest : NSObject
+(NSString*)convertURLToStubFileName:(NSString*)url;
+(NSData*)stubFileContentForURL:(NSString*)url forBundleClass:(Class)cls;
+(NSSet*)urlSetFromStringUrl:(NSString*)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
@end
