//
//  LinkModel.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/17/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "JSONObject.h"

@interface LinkObject : JSONObject

@property(strong) NSString *url;
@property(strong) NSString *title;

-(instancetype)initWithUrl:(NSString*)url title:(NSString*)title;

+(LinkObject*)testModel;

@end
