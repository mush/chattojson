//
//  FetchHTMLPageContentTask.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/23/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "FetchHTMLPageContentTask.h"

static NSOperationQueue * delegateQueue(){
    static NSOperationQueue *queue;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        queue = [[NSOperationQueue alloc]init];
        queue.name = @"com.http.delegate.queue";
        queue.maxConcurrentOperationCount = 5;
    });
    
    return queue;
}


@interface FetchHTMLPageContentTask ()
@property(strong) NSURL *url;
@property(strong) NSURLSessionConfiguration *sessionConfiguration;
@end

@implementation FetchHTMLPageContentTask

-(instancetype)initWithURL:(NSURL *)url{
    
    if (self = [self init]) {
        self.url = url;
    }
    
    return self;
}

-(instancetype)init{
    if (self = [super init]) {
        self.encoding = NSASCIIStringEncoding;
        self.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    return self;
}

-(ChainableTask *)task{
    ChainableTask *t = [ChainableTask new];
    
    NSURLSession *s = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:nil delegateQueue:delegateQueue()];

    [[s dataTaskWithURL:self.url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error){
            [t trySetError:error];
        }else{
            NSString *st = [[NSString alloc]initWithData:data encoding:self.encoding];
            [t trySetResult:st];
        }        
        
    }] resume];
    

    return t;
}
@end
