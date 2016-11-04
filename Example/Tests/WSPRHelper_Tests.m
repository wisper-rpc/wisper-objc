//
//  WSPRHelper_Tests.m
//  Wisper
//
//  Created by Patrik Nyblad on 2016-11-04.
//  Copyright © 2016 Patrik Nyblad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Wisper/WSPRHelper.h>
@interface WSPRHelper_Tests : XCTestCase

@end

@implementation WSPRHelper_Tests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}


#pragma mark - -jsonSafeObjectFromObject:

-(void)testJSONSafeObjectNilBecomesNSNull
{
    NSNull *null = [WSPRHelper jsonSafeObjectFromObject:nil];
    XCTAssertNotNil(null, @"Nil was not converted to NSNull!");
}

-(void)testJSONSafeObjectNSURLBecomesNSString
{
    NSURL *url = [NSURL URLWithString:@"https://example.com"];
    NSString *urlString = [WSPRHelper jsonSafeObjectFromObject:url];
    XCTAssert([urlString isKindOfClass:[NSString class]], @"NSURL not converted to NSString!");
    XCTAssert([urlString isEqualToString:@"https://example.com"], @"NSURL not converted correctly!");
}

-(void)testJSONSafeObjectWithInvalidJSONObject
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:123123123];
    NSNumber *jsonSafeEpoch = [WSPRHelper jsonSafeObjectFromObject:date];
    XCTAssertEqual(@(123123123000), jsonSafeEpoch, @"Date was not converted to epoch!");
}

-(void)testJSONSafeObjectNSSetBecomesArray
{
    NSSet *set = [NSSet setWithObjects:[NSDate date], nil];
    NSArray *array = [WSPRHelper jsonSafeObjectFromObject:set];
    XCTAssert([array isKindOfClass:[NSArray class]], @"NSSet not converted to array!");
    XCTAssert([[array firstObject] isKindOfClass:[NSNumber class]], @"Nested items where excluded! Should run recursively through collections!");
}

-(void)testJSONSafeObjectNSDictionaryRecursion
{
    NSDictionary *dict = @{@"date" : [NSDate date]};
    NSDictionary *safeDict = [WSPRHelper jsonSafeObjectFromObject:dict];
    XCTAssert([safeDict[@"date"] isKindOfClass:[NSNumber class]], @"Nested items where excluded! Should run recursively through collections!");
}

-(void)testJSONSafeObjectNSArrayRecursion
{
    NSArray *array = @[[NSDate date]];
    NSArray *safeArray = [WSPRHelper jsonSafeObjectFromObject:array];
    XCTAssert([[safeArray firstObject] isKindOfClass:[NSNumber class]], @"Nested items where excluded! Should run recursively through collections!");
}


#pragma mark - -JSONStringFromObject:completion:

-(void)testJSONStringFromObjectNilResultsInError
{
    __block BOOL didComplete = NO;
    [WSPRHelper jsonStringFromObject:nil completion:^(NSString *jsonString, NSError *error) {
        didComplete = YES;
        XCTAssertNotNil(error, @"Should fail from nil object!");
    }];
    
    XCTAssertTrue(didComplete, @"Completion block not run!");
}

-(void)testJSONStringFromObjectNonArrayOrDictResultsInError
{
    __block BOOL didComplete = NO;
    [WSPRHelper jsonStringFromObject:[NSDate date] completion:^(NSString *jsonString, NSError *error) {
        didComplete = YES;
        XCTAssertNotNil(error, @"Should fail from non collection object!");
    }];
    
    XCTAssertTrue(didComplete, @"Completion block not run!");
}

-(void)testJSONStringFromObjectWithCompatibleDictionary
{
    __block BOOL didComplete = NO;
    [WSPRHelper jsonStringFromObject:@{@"key":@"value"} completion:^(NSString *jsonString, NSError *error) {
        [WSPRHelper objectFromJSONString:jsonString completion:^(NSDictionary *jsonDict, NSArray *jsonArray, NSError *error) {
            didComplete = YES;
            XCTAssertNil(jsonArray, @"jsonArray should not be set!");
            XCTAssertNil(error, @"Unexpected error!");
            XCTAssert([jsonDict[@"key"] isEqualToString:@"value"], @"Failed to serialize object!");
        }];
    }];
    
    XCTAssertTrue(didComplete, @"Completion block not run!");
}

-(void)testJSONStringFromObjectWithCompatibleArray
{
    __block BOOL didComplete = NO;
    [WSPRHelper jsonStringFromObject:@[@"value"] completion:^(NSString *jsonString, NSError *error) {
        [WSPRHelper objectFromJSONString:jsonString completion:^(NSDictionary *jsonDict, NSArray *jsonArray, NSError *error) {
            didComplete = YES;
            XCTAssertNil(jsonDict, @"jsonDict should not be set!");
            XCTAssertNil(error, @"Unexpected error!");
            XCTAssert([[jsonArray firstObject] isEqualToString:@"value"], @"Failed to serialize object!");
        }];
    }];
    
    XCTAssertTrue(didComplete, @"Completion block not run!");
}

-(void)testJSONStringFromObjectWithIncompatibleSubObject
{
    __block BOOL didComplete = NO;
    [WSPRHelper jsonStringFromObject:@{@"date": [NSDate dateWithTimeIntervalSince1970:123]} completion:^(NSString *jsonString, NSError *error) {
        [WSPRHelper objectFromJSONString:jsonString completion:^(NSDictionary *jsonDict, NSArray *jsonArray, NSError *error) {
            didComplete = YES;
            XCTAssertNil(jsonArray, @"jsonArray should not be set!");
            XCTAssertNil(error, @"Unexpected error!");
            XCTAssert([jsonDict[@"date"] isKindOfClass:[NSNumber class]], @"Failed to create json safe object!");
            XCTAssert([jsonDict[@"date"] isEqualToNumber:@(123000)], @"Failed to serialize object!");
        }];
    }];
    
    XCTAssertTrue(didComplete, @"Completion block not run!");
}


#pragma mark - -objectFromJSONString:completion:

-(void)testobjectFromJSONStringWithIncompatibleString
{
    NSString *jsonString = @"helloworld";
    
    __block BOOL didComplete = NO;
    [WSPRHelper objectFromJSONString:jsonString completion:^(NSDictionary *jsonDict, NSArray *jsonArray, NSError *error) {
        didComplete = YES;
        XCTAssertNil(jsonArray, @"jsonArray should not be set!");
        XCTAssertNil(jsonDict, @"jsonDict should not be set!");
        XCTAssertNotNil(error, @"Should have resulted in error!");
    }];
    
    XCTAssertTrue(didComplete, @"Completion block not run!");
}

-(void)testobjectFromJSONStringWithMalformedJSON
{
    NSString *jsonString = @"{'test': test}";
    
    __block BOOL didComplete = NO;
    [WSPRHelper objectFromJSONString:jsonString completion:^(NSDictionary *jsonDict, NSArray *jsonArray, NSError *error) {
        didComplete = YES;
        XCTAssertNil(jsonArray, @"jsonArray should not be set!");
        XCTAssertNil(jsonDict, @"jsonDict should not be set!");
        XCTAssertNotNil(error, @"Should have resulted in error!");
    }];
    
    XCTAssertTrue(didComplete, @"Completion block not run!");
}

-(void)testobjectFromJSONStringWithValidJSONObject
{
    NSString *jsonString = @"{\"key\":\"value\"}";
    
    __block BOOL didComplete = NO;
    [WSPRHelper objectFromJSONString:jsonString completion:^(NSDictionary *jsonDict, NSArray *jsonArray, NSError *error) {
        didComplete = YES;
        XCTAssertNil(jsonArray, @"jsonArray should not be set!");
        XCTAssertNil(error, @"Unexpected error!");
        XCTAssertTrue([jsonDict[@"key"] isEqualToString:@"value"], @"Not parsed correctly!");
    }];
    
    XCTAssertTrue(didComplete, @"Completion block not run!");
}

-(void)testobjectFromJSONStringWithValidJSONArray
{
    NSString *jsonString = @"[\"test\"]";
    
    __block BOOL didComplete = NO;
    [WSPRHelper objectFromJSONString:jsonString completion:^(NSDictionary *jsonDict, NSArray *jsonArray, NSError *error) {
        didComplete = YES;
        XCTAssertNil(jsonDict, @"jsonDict should not be set!");
        XCTAssertNil(error, @"Unexpected error!");
        XCTAssertTrue([[jsonArray firstObject] isEqualToString:@"test"], @"Not parsed correctly!");
    }];
    
    XCTAssertTrue(didComplete, @"Completion block not run!");
}


@end
