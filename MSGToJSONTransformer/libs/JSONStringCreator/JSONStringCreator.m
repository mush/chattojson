//
//  TextToJSONResultCreator.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/23/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "JSONStringCreator.h"

@implementation JSONStringCreator{
    NSMutableDictionary *_values;
    dispatch_queue_t _synchronization_queue;
}

-(instancetype)init{
    if (self = [super init]) {
        _values = [NSMutableDictionary dictionary];
        
        NSString *qName = [NSString stringWithFormat:@"com.jsoncreator.sync.concurrent.%lu", [self hash]];
        _synchronization_queue = dispatch_queue_create([qName UTF8String], DISPATCH_QUEUE_CONCURRENT);
        self.jsonWriteOption = NSJSONWritingPrettyPrinted;
    }
    return self;
}

-(void)addValue:(id)value forKey:(NSString const*)key{
    dispatch_barrier_async(_synchronization_queue, ^{
        if(key && value){
            _values[key] = value;
        }
    });
}

-(NSDictionary *)values{
    __block NSDictionary *v = nil;
    dispatch_sync(_synchronization_queue, ^{
        v = _values;
    });
    
    return v;
}

-(NSString *)toJSONString{
    __block NSString *output = nil;

    dispatch_sync(_synchronization_queue, ^{
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:_values options:self.jsonWriteOption error:&error];
        if(!error){
            output = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        }else{
            [NSException raise:error.domain format:@"for data = %@", [_values description]];
        }
    });
    
    return output;
}
@end
