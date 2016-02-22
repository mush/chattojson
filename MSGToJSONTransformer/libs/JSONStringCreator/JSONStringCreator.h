//
//  TextToJSONResultCreator.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/23/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A JSONCreator for given all key-value pair.
 */
@interface JSONStringCreator : NSObject
@property(readwrite) NSJSONWritingOptions jsonWriteOption;
@property(readonly) NSDictionary *values;
/**
 *  interface for providing key/value pair.
 *
 *  @param value value as JSON serializable object.
 *  @param key   key as string
 */
-(void)addValue:(id)value forKey:(NSString*)key;

/**
 *
 *  @return NSUTF8StringEncoding encoded string with option NSJSONWritingPrettyPrinted used in NSJSONSerialization.
 *  @throws exception thrown in NSJSONSerialization.
 */
-(NSString*)toJSONString;
@end
