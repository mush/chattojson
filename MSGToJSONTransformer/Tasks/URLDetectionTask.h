//
//  DetectingURLsTask.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/24/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskProvider.h"
#import "DetectedUrlObject.h"

/**
 *  Task that takes a text and provides an object of DetectedUrlObject. DetectedUrlObject contains detected urls in the given text
 *  and a trimmed text without all the found urls.
 *
 */
@interface URLDetectionTask : NSObject<TaskProvider>

-(instancetype)initWithText:(NSString*)text;

@end
