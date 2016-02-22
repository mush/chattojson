//
//  HTMLPageStub.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/24/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLPageStubManager : NSObject
+(HTMLPageStubManager*)sharedManager;
-(void)setup;
-(void)tearDown;
@end
