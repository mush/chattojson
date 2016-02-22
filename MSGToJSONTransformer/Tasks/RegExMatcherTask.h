//
//  StringParser.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/14/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskProvider.h"
#import "ChainableTask.h"

typedef void(^ParseResultBlock)(id result, NSError *error);

/**
 Caseinsensitive regex parsing. final result of the returned task object contains a dictionary. Each item is key/[capturing groups] pair.
 For matching option it uses options=NSMatchingReportCompletion. Chainabletasks's error contains the exception thrown by NSRegularExpresson class.
 */
@interface RegExMatcherTask : NSObject<TaskProvider>

/**
 *  constructor for instantiating regex parsing.
 *
 *  @param str string to parse.
 *
 */
-(instancetype)initWithString:(NSString*)str;

/**
 *  key/group pair for applying regex parsing. The num of capturing group must be one. this funciton is not thread safe.
 *
 *  @param group  capturing group in regex.
 *  @param key    key to identify groups for <code>group</code>.
 */
-(void)addCapturingGroup:(NSString*)group forKey:(NSString*)key;

@end
