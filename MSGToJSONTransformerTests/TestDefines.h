//
//  TestDefines.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/24/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#ifndef TestDefines_h
#define TestDefines_h

#define WAIT_TIME_OUT_FOR_EXPECTATION 60.0

#define EXP_START(desc) XCTestExpectation *expt = [self expectationWithDescription:desc]
#define EXP_FULFILL() [expt fulfill]
#define EXP_END() [self waitForExpectationsWithTimeout:WAIT_TIME_OUT_FOR_EXPECTATION handler:^(NSError * _Nullable error) {\
XCTAssertNil(error, "error");\
}]

#endif /* TestDefines_h */
