//
//  ChatMsgModel.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/17/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "ChatMsgObject.h"

@implementation ChatMsgObject

-(instancetype)initWithMentions:(NSArray *)mentions emoticons:(NSArray *)emoticons links:(NSArray *)links{
    
    if (self = [super init]) {
        self.mentions = mentions;
        self.emoticons = emoticons;
        self.links = links;
    }
    
    return self;
}

+(ChatMsgObject*)testModel{

    ChatMsgObject *m = [ChatMsgObject new];
    m.mentions = @[@"mush", @"bush"];
    m.emoticons = @[@"smiley", @"anger"];
    m.links = @[[LinkObject testModel], [LinkObject testModel], [LinkObject testModel]];
    
    return m;
}
@end
