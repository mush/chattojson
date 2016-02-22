//
//  BaseModel.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/17/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ObjectTransformer

@required
-(NSDictionary*)toDict;
-(NSString*)toJSONString;

@end

/**
 *  This is the abstract class that the inheriting class can be used to hold JSON object as it's properties.
 *  Allowed property types are NSString, NSSDictionary, NSArray and NSNull. Values of NSArray and NSdictionary must
 *  also be of any of these types. It adopts ObjectTransformer protocol and provide dictionary presentation of 
 *  all the properties with method [ObjectTransformer toDict]. [ObjectTransformer toJSONString] is another method 
 *  that serializes the dictionary represtation into a JSON string (pretty formatted).
 */
@interface JSONObject : NSObject<ObjectTransformer, NSCopying>

/**
 *  This method is used for testing equality between two JSONObjects.
 *
 *  @param obj JSONObject to test the equality with.
 *
 *  @return TRUE if the type of obj is the same as the receiver and dictionary format of the reciever and param obj are equal.
 */
-(BOOL)isEqualToJSONObject:(JSONObject*)obj;
@end

@interface JSONObject (Helper)
/**
 *  Tests if the provided obj is of the class NSString, NSNumber or NSNull.
 *
 */
+(BOOL)isAPrimitiveClassObj:(id)obj;
/**
 *  Transforms obj into either NSString, NSNumber, NSDictionary, NSArray or NSNull, depending on the type of obj.
 *
 *  @param obj   object that is to transform
 *  @param error if any error occurs this is going to set with appropriate error domain.
 *
 *  @return returns transformed object.
 */
+(id)transformObj:(id)obj error:(NSError**)error;
@end


@interface NSArray (JSONObjectTransformer)
/**
 *  Transforms individual element of the array using [JSONObject transformObj] method.
 *
 *  @return returns an array having transformed values.
 */
-(NSArray*)transform;
@end

@interface NSDictionary (JSONObjectTransformer)
/**
 *  Transforms individual element of the dictionary using [JSONObject transformObj] method.
 *
 *  @return returns a dictionary having transformed values.
 */
-(NSDictionary*)transform;
@end
