//
//  JSONObjectTest.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/20/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JSONObject.h"

@interface PlainObject : JSONObject
@property(strong) NSString *str;
@property(strong) NSNumber *num;
@property(strong) NSArray *arr;
@property(strong) NSDictionary *dict;

+(PlainObject*)newPlainObj;
+(NSDictionary*)expedtedPlainObj;
@end

@implementation PlainObject
+(PlainObject*)newPlainObj{
    PlainObject *p = [PlainObject new];
    p.str = @"strval";
    p.num = @(1);
    p.arr = @[@(1),@(2)];
    p.dict = @{@"p1":@"v1", @"p2":@"v2"};
    
    return p;
}

+(NSDictionary*)expedtedPlainObj{
    NSDictionary *expected = @{@"str":@"strval", @"num":@(1), @"arr":@[@(1),@(2)], @"dict":@{@"p1":@"v1", @"p2":@"v2"}};
    return expected;
}

@end
/**
 *  ////////////////////
 */
@interface NestedObject : PlainObject
@property(strong) NSString *str2;
@property(strong) NSNumber *num2;
@property(strong) NSArray *arr2;
@property(strong) NSDictionary *dict2;

+(NestedObject *)newNestedObj;
+(NSDictionary*)expectedNestedObj;
@end

@implementation NestedObject
+ (NestedObject *)newNestedObj {
    NestedObject *n1 = [NestedObject new];
    n1.str = @"s1";
    n1.str2 = @"s2";
    n1.num = @(1);
    n1.num2 = @(2);
    n1.arr = @[@(1), @(2)];
    n1.arr2 = @[@(3)];
    n1.dict = @{@"p1":@"v1",@"p2":@"v2"};
    n1.dict2 = @{@"p3":@"v3",@"p4":@"v4"};
    return n1;
}

+(NSDictionary*)expectedNestedObj{
    NSDictionary *expected = @{
                               @"str":@"s1",
                               @"num":@(1),
                               @"arr":@[@(1),@(2)],
                               @"dict":@{@"p1":@"v1", @"p2":@"v2"},
                               @"str2":@"s2",
                               @"num2":@(2),
                               @"arr2":@[@(3)],
                               @"dict2":@{@"p3":@"v3", @"p4":@"v4"},
                               };
    return expected;
}
@end

/**
 *  /////////////////////
 */
@interface CompoundObject : JSONObject
@property(strong) NSString *str;
@property(strong) NSArray<PlainObject*> *arr;
@property(strong) NSDictionary *dict;

+(CompoundObject*)newCompoundObj;
+(NSDictionary*)expedtedCompoundObj;
@end

@implementation CompoundObject

+(CompoundObject*)newCompoundObj{
    CompoundObject *obj = [CompoundObject new];
    obj.str = @"strval";
    obj.arr = @[[PlainObject newPlainObj], [NestedObject newNestedObj]];
    obj.dict = @{@"j1":[PlainObject newPlainObj], @"s1":@"strval1", @"n1":[NestedObject newNestedObj]};
    
    return obj;
}
+(NSDictionary*)expedtedCompoundObj{
    NSDictionary *expected = @{@"str":@"strval",
                               @"arr":@[[PlainObject expedtedPlainObj], [NestedObject expectedNestedObj]],
                               @"dict":@{@"j1":[PlainObject expedtedPlainObj], @"s1":@"strval1", @"n1":[NestedObject expectedNestedObj]}};
    return expected;
}

@end

/**
 *  ////////////////
 */
@interface UnsupportedObject : JSONObject
@property(strong) id obj;
@end
@implementation UnsupportedObject
@end

/**
 *  ////////
 */
@interface JSONObjectTest : XCTestCase

@end

@implementation JSONObjectTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testWithNilValues{
    PlainObject *p = [PlainObject new];
    p.str = nil;
    p.num = @(1);
    NSDictionary *expected = @{@"str":[NSNull null],
                               @"num":@(1),
                               @"arr":[NSNull null],
                               @"dict":[NSNull null]
                               };
    XCTAssertTrue([[p toDict] isEqualToDictionary:expected]);
}

- (void)testCopyAndEquality {
    
    PlainObject *p = [PlainObject newPlainObj];
    
    PlainObject *pc = [p copy];
    XCTAssertTrue([p isEqual:pc]);
    XCTAssertTrue([p.str isEqualToString:pc.str]);
    XCTAssertTrue([p.num isEqualToNumber:pc.num]);
    XCTAssertTrue([p.arr isEqualToArray:pc.arr]);
    XCTAssertTrue([p.dict isEqualToDictionary:pc.dict]);
    
    
    NestedObject *n1;
    n1 = [NestedObject newNestedObj];
    
    NestedObject *n2 = [n1 copy];
    XCTAssertTrue([n1 isEqual:n2]);
    XCTAssertTrue([n1.str isEqualToString:n2.str]);
    XCTAssertTrue([n1.str2 isEqualToString:n2.str2]);
    XCTAssertTrue([n1.num isEqualToNumber:n2.num]);
    XCTAssertTrue([n1.num2 isEqualToNumber:n2.num2]);
    XCTAssertTrue([n1.arr isEqualToArray:n2.arr]);
    XCTAssertTrue([n1.arr2 isEqualToArray:n2.arr2]);
    XCTAssertTrue([n1.dict isEqualToDictionary:n2.dict]);
    XCTAssertTrue([n1.dict2 isEqualToDictionary:n2.dict2]);
    
    
    CompoundObject *c1 = [CompoundObject newCompoundObj];
    CompoundObject *c2 = [c1 copy];
    
    XCTAssertTrue([c1 isEqual:c2]);
    XCTAssertTrue([c1.str isEqualToString:c2.str]);
    XCTAssertTrue([c1.arr isEqualToArray:c2.arr]);
    
}

-(void)testUnsupportedType{
    UnsupportedObject *obj = [UnsupportedObject new];
    obj.obj = [NSObject new];
    XCTAssertThrows([obj toDict]);
}

-(void)testToJSONString{
    //TODO:
}

-(void)testToDictWithPlainObj{
    PlainObject *p = [PlainObject newPlainObj];
    
    NSDictionary *expected = [PlainObject expedtedPlainObj];
    
    XCTAssertTrue([[p toDict] isEqualToDictionary:expected]);
}

-(void)testToDictWithCompoundObj{
    CompoundObject *c1 = [CompoundObject newCompoundObj];
    NSDictionary *expected = [CompoundObject expedtedCompoundObj];
    NSDictionary *with = [c1 toDict];
    XCTAssertTrue([with isEqualToDictionary:expected]);
}


@end
