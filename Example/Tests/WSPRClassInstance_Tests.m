//
//  WSRPCUTClassInstance.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 22/08/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WSPRClassInstance.h"
#import "WSPRClassProperty.h"
#import "WSPRTestObject.h"

@interface WSPRClassInstance_Tests : XCTestCase

@end

@implementation WSPRClassInstance_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**
 Add class and instance in different orders.
 */
- (void)testPropertyKVOClassAndInstance
{
    WSPRClass *rpcClass = [WSPRTestObject rpcRegisterClass];
    WSPRTestObject *testObject = [[WSPRTestObject alloc] init];
    WSPRClassInstance *classInstance = [[WSPRClassInstance alloc] init];
    classInstance.rpcClass = rpcClass;
    classInstance.instance = testObject;
    XCTAssertNotNil([classInstance.instance observationInfo], @"Missing KVO observers!");
    
    classInstance.instance = nil;
    XCTAssertNil([testObject observationInfo], @"Did not remove KVO!");
}

- (void)testPropertyKVOInstanceAndClass
{
    WSPRClass *rpcClass = [WSPRTestObject rpcRegisterClass];
    WSPRTestObject *testObject = [[WSPRTestObject alloc] init];
    WSPRClassInstance *classInstance = [[WSPRClassInstance alloc] init];
    classInstance.instance = testObject;
    classInstance.rpcClass = rpcClass;
    XCTAssertNotNil([classInstance.instance observationInfo], @"Missing KVO observers!");
    
    classInstance.instance = nil;
    XCTAssertNil([testObject observationInfo], @"Did not remove KVO!");
}

- (void)testPropertyKVOClassAndInstanceRemoveClass
{
    WSPRClass *rpcClass = [WSPRTestObject rpcRegisterClass];
    WSPRTestObject *testObject = [[WSPRTestObject alloc] init];
    WSPRClassInstance *classInstance = [[WSPRClassInstance alloc] init];
    classInstance.rpcClass = rpcClass;
    classInstance.instance = testObject;
    XCTAssertNotNil([classInstance.instance observationInfo], @"Missing KVO observers!");
    
    classInstance.rpcClass = nil;
    XCTAssertNil([testObject observationInfo], @"Did not remove KVO!");
}

- (void)testPropertyKVOClassAndInstanceRemoveClassAndAddClass
{
    WSPRClass *rpcClass = [WSPRTestObject rpcRegisterClass];
    WSPRTestObject *testObject = [[WSPRTestObject alloc] init];
    WSPRClassInstance *classInstance = [[WSPRClassInstance alloc] init];
    classInstance.rpcClass = rpcClass;
    classInstance.instance = testObject;
    XCTAssertNotNil([classInstance.instance observationInfo], @"Missing KVO observers!");
    
    classInstance.rpcClass = nil;
    XCTAssertNil([testObject observationInfo], @"Did not remove KVO!");
    
    classInstance.rpcClass = rpcClass;
    XCTAssertNotNil([classInstance.instance observationInfo], @"Missing KVO observers!");
}

- (void)testPropertyKVOClassAndInstanceRemoveInstance
{
    WSPRClass *rpcClass = [WSPRTestObject rpcRegisterClass];
    WSPRTestObject *testObject = [[WSPRTestObject alloc] init];
    WSPRClassInstance *classInstance = [[WSPRClassInstance alloc] init];
    classInstance.rpcClass = rpcClass;
    classInstance.instance = testObject;
    XCTAssertNotNil([classInstance.instance observationInfo], @"Missing KVO observers!");
    
    classInstance.instance = nil;
    XCTAssertNil([testObject observationInfo], @"Did not remove KVO!");
}


- (void)testPropertyKVOClassAndInstanceRemoveInstanceAndAddInstance
{
    WSPRClass *rpcClass = [WSPRTestObject rpcRegisterClass];
    WSPRTestObject *testObject = [[WSPRTestObject alloc] init];
    WSPRClassInstance *classInstance = [[WSPRClassInstance alloc] init];
    classInstance.rpcClass = rpcClass;
    classInstance.instance = testObject;
    XCTAssertNotNil([classInstance.instance observationInfo], @"Missing KVO observers!");
    
    classInstance.instance = nil;
    XCTAssertNil([testObject observationInfo], @"Did not remove KVO!");
    
    classInstance.instance = testObject;
    XCTAssertNotNil([classInstance.instance observationInfo], @"Missing KVO observers!");
}


@end
