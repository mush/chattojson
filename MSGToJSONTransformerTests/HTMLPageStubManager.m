//
//  HTMLPageStub.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/24/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "HTMLPageStubManager.h"
#import <OHHTTPStubs.h>
#import "OHHTTPStubsResponse+HttpMessage.h"
#import "HelperUnitTest.h"

@implementation HTMLPageStubManager
+(HTMLPageStubManager *)sharedManager{

    static HTMLPageStubManager *instance = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        instance = [[HTMLPageStubManager alloc] init];
    });

    return instance;
}

-(void)setup{
    NSArray<NSString*> *urls = @[
                      @"http://www.titlewithspecialcharacter.com",
                      @"http://www.titlewithnewline.com",
                      @"http://www.nbcolympics.com",
                      @"https://twitter.com/jdorfman/status/430511497475670016",
                      @"https://www.google.com.au",
                      @"http://www.emptytitle.com",
                      @"http://www.notitletag.com",
                      @"http://www.titletagwithattribute.com",
                      @"http://www.invalidtitletag.com"
                      ];
    
    for (NSString *url in urls) {
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [url isEqualToString:request.URL.absoluteString];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            NSData *data = [HelperUnitTest stubFileContentForURL:url forBundleClass:[self class]];
            return [OHHTTPStubsResponse responseWithHTTPMessageData:data];
        }];
    }
}
-(void)tearDown{
    [OHHTTPStubs removeAllStubs];
}
@end
