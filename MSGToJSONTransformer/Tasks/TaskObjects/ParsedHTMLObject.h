//
//  ParsedHTMLObject.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/18/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "JSONObject.h"

@interface ParsedHTMLObject : JSONObject
@property(strong) NSString *title;

-(instancetype)initWithTitle:(NSString*)title;

@end
