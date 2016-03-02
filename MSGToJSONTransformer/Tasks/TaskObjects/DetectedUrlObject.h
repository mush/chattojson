//
//  DetectedUrlObject.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 3/2/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "JSONObject.h"

@interface DetectedUrlObject : JSONObject
@property(strong) NSArray *urls;
@property(strong) NSString *trimmedText;

-(instancetype)initWithUrls:(NSArray*)urls trimmedText:(NSString*)trimmedText;
@end

