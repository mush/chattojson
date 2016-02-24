//
//  DetectingURLsTask.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/24/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskProvider.h"
#import "JSONObject.h"

@interface DetectedUrlObject : NSObject<NSCopying>
@property(strong) NSArray *urls;
@property(strong) NSString *trimmedText;

-(instancetype)initWithUrls:(NSArray*)urls trimmedText:(NSString*)trimmedText;
@end

@interface URLDetectionTask : NSObject<TaskProvider>

-(instancetype)initWithText:(NSString*)text;

@end
