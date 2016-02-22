//
//  Task.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/21/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChainableTask.h"
#import "JSONObject.h"

/**
 *  Interface for task provider. The -(ChainableTask*)task method must be overriden by the subclasses.
 */
@protocol TaskProvider

@required
-(ChainableTask*)task;

@end

