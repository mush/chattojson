//
//  ChatMsgModel.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/17/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "JSONObject.h"
#import "LinkObject.h"

@interface ChatMsgObject : JSONObject
@property(strong) NSArray *mentions;
@property(strong) NSArray *emoticons;
@property(strong) NSArray<LinkObject *> *links;

-(instancetype)initWithMentions:(NSArray*)mentions emoticons:(NSArray*)emoticons links:(NSArray*)links;

+(ChatMsgObject*)testModel;

@end
