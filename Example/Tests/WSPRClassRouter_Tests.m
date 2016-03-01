//
//  WSPRClassRouter_Tests.m
//  Wisper
//
//  Created by Patrik Nyblad on 11/02/16.
//  Copyright © 2016 Patrik Nyblad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "WSPRTestObject.h"
#import "WSPRGatewayRouter.h"
#import "WSPRClassRouter.h"
#import "WSPRInstanceRegistry.h"


@interface WSPRClassRouter ()

@property (nonatomic, strong) NSMutableArray *ownedInstances;

@end

@interface WSPRClassRouter_Tests : XCTestCase

@property (nonatomic, strong) WSPRGatewayRouter *gatewayRouter;

@end

@implementation WSPRClassRouter_Tests

- (void)setUp
{
    [super setUp];
    self.gatewayRouter = [[WSPRGatewayRouter alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitSetsWisperClassModel
{
    WSPRClassRouter *classRouter = [[WSPRClassRouter alloc] initWithClass:[WSPRObject class]];
    XCTAssert([classRouter.classModel.mapName isEqualToString:@"WSPRClass"], @"Class model not set correctly on init!");
}

- (void)testAddInstance
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"n/a"];
    
    [_gatewayRouter exposeRoute:[WSPRClassRouter routerWithClass:[WSPRTestObject class]] onPath:@"wisp.test.TestObject"];
    
    WSPRTestObject *testObjectToBeAdded = [[WSPRTestObject alloc] init];
    WSPRClassRouter *classRouter = [_gatewayRouter routerAtPath:@"wisp.test.TestObject"];
    WSPRClassInstance *instance = [classRouter addInstance:testObjectToBeAdded];
    
    XCTAssertTrue([classRouter.ownedInstances containsObject:instance.instanceIdentifier], @"Did not add instance to owned instances");
    
    WSPRRequest *request = [[WSPRRequest alloc] init];
    request.method = @"wisp.test.TestObject:append";
    request.params = @[instance.instanceIdentifier, @"Hello ", @"world!"];
    request.requestIdentifier = @"req0";
    request.responseBlock = ^(WSPRResponse *response){
        if ([(NSString *)response.result isEqualToString:@"Hello world!"])
            [expectation fulfill];
    };
    
    [classRouter route:request toPath:@"TestObject.append"];
    
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testAddInstanceGeneratesCreateEvent
{
    id gatewayMock = OCMPartialMock(_gatewayRouter.gateway);
    
    //Expect creation event to be sent
    OCMExpect([gatewayMock sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRNotification *notification = (WSPRNotification *)obj;
        WSPREvent *event = [[WSPREvent alloc] initWithNotification:notification];
                
        if (![event.mapName isEqualToString:@"wisp.test.TestObject"])
            return NO;
        
        if (![event.name isEqualToString:@"~"])
            return NO;
        
        if (event.instanceIdentifier)
            return NO;
        
        if (!event.data)
            return NO;
        
        return YES;
    }]]);

    
    [_gatewayRouter exposeRoute:[WSPRClassRouter routerWithClass:[WSPRTestObject class]] onPath:@"wisp.test.TestObject"];
    
    WSPRTestObject *testObjectToBeAdded = [[WSPRTestObject alloc] init];
    WSPRClassRouter *classRouter = [_gatewayRouter routerAtPath:@"wisp.test.TestObject"];
    WSPRClassInstance *instance = [classRouter addInstance:testObjectToBeAdded];
    
    XCTAssertTrue([classRouter.ownedInstances containsObject:instance.instanceIdentifier], @"Did not add instance to owned instances");
    XCTAssertEqual([WSPRInstanceRegistry instanceWithId:instance.instanceIdentifier underRootRoute:_gatewayRouter], instance, @"Instance not added to registry");
    
    OCMVerifyAll(gatewayMock);
}

- (void)testRemoveInstance
{
    [_gatewayRouter exposeRoute:[WSPRClassRouter routerWithClass:[WSPRTestObject class]] onPath:@"wisp.test.TestObject"];
    
    WSPRTestObject *testObjectToBeAdded = [[WSPRTestObject alloc] init];
    WSPRClassRouter *classRouter = [_gatewayRouter routerAtPath:@"wisp.test.TestObject"];
    WSPRClassInstance *instance = [classRouter addInstance:testObjectToBeAdded];
    
    id gatewayMock = OCMPartialMock(_gatewayRouter.gateway);
    
    //Expect creation event to be sent
    OCMExpect([gatewayMock sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRNotification *notification = (WSPRNotification *)obj;
        WSPREvent *event = [[WSPREvent alloc] initWithNotification:notification];
        NSLog(@"%@", event);
        
        if (![event.mapName isEqualToString:@"wisp.test.TestObject"])
            return NO;
        
        if (![event.name isEqualToString:@"~"])
            return NO;
        
        if (![event.instanceIdentifier isEqualToString:instance.instanceIdentifier])
            return NO;
        
        if (event.data)
            return NO;
        
        return YES;
    }]]);
    
    //Expect rpc destructor to be run, no need to dealloc check the object since it is allowed to keep on living when it was created by someone else than wisper
    id instanceMock = OCMPartialMock(instance.instance);
    OCMExpect([instanceMock rpcDestructor]);
    
    //Remove the instance
    [classRouter removeInstance:instance];
    
    XCTAssertFalse([classRouter.ownedInstances containsObject:instance.instanceIdentifier], @"Did not remove instance from owned instances");
    XCTAssertNil([WSPRInstanceRegistry instanceWithId:instance.instanceIdentifier underRootRoute:_gatewayRouter], @"Instance not removed from registry");

    OCMVerifyAll(gatewayMock);
    OCMVerifyAll(instanceMock);
}

- (void)testFlushInstances
{
    [_gatewayRouter exposeRoute:[WSPRClassRouter routerWithClass:[WSPRTestObject class]] onPath:@"wisp.test.TestObject"];
    
    WSPRTestObject *testObjectToBeAdded1 = [[WSPRTestObject alloc] init];
    WSPRTestObject *testObjectToBeAdded2 = [[WSPRTestObject alloc] init];
    WSPRClassRouter *classRouter = [_gatewayRouter routerAtPath:@"wisp.test.TestObject"];
    WSPRClassInstance *instance1 = [classRouter addInstance:testObjectToBeAdded1];
    WSPRClassInstance *instance2 = [classRouter addInstance:testObjectToBeAdded2];
    
    id gatewayMock = OCMPartialMock(_gatewayRouter.gateway);
    
    //Expect creation event to be sent
    OCMExpect([gatewayMock sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRNotification *notification = (WSPRNotification *)obj;
        WSPREvent *event = [[WSPREvent alloc] initWithNotification:notification];
        NSLog(@"%@", event);
        
        if (![event.mapName isEqualToString:@"wisp.test.TestObject"])
            return NO;
        
        if (![event.name isEqualToString:@"~"])
            return NO;
        
        if (![event.instanceIdentifier isEqualToString:instance1.instanceIdentifier])
            return NO;
        
        if (event.data)
            return NO;
        
        return YES;
    }]]);
    
    OCMExpect([gatewayMock sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRNotification *notification = (WSPRNotification *)obj;
        WSPREvent *event = [[WSPREvent alloc] initWithNotification:notification];
        NSLog(@"%@", event);
        
        if (![event.mapName isEqualToString:@"wisp.test.TestObject"])
            return NO;
        
        if (![event.name isEqualToString:@"~"])
            return NO;
        
        if (![event.instanceIdentifier isEqualToString:instance2.instanceIdentifier])
            return NO;
        
        if (event.data)
            return NO;
        
        return YES;
    }]]);
    
    //Expect rpc destructor to be run, no need to dealloc check the object since it is allowed to keep on living when it was created by someone else than wisper
    id instanceMock1 = OCMPartialMock(instance1.instance);
    OCMExpect([instanceMock1 rpcDestructor]);
    
    id instanceMock2 = OCMPartialMock(instance2.instance);
    OCMExpect([instanceMock2 rpcDestructor]);
    
    //Remove the instance
    [classRouter flushInstances];
    
    XCTAssertFalse([classRouter.ownedInstances containsObject:instance1.instanceIdentifier], @"Did not remove instance from owned instances");
    XCTAssertNil([WSPRInstanceRegistry instanceWithId:instance1.instanceIdentifier underRootRoute:_gatewayRouter], @"Instance not removed from registry");

    XCTAssertFalse([classRouter.ownedInstances containsObject:instance2.instanceIdentifier], @"Did not remove instance from owned instances");
    XCTAssertNil([WSPRInstanceRegistry instanceWithId:instance2.instanceIdentifier underRootRoute:_gatewayRouter], @"Instance not removed from registry");

    OCMVerifyAll(gatewayMock);
    OCMVerifyAll(instanceMock1);
    OCMVerifyAll(instanceMock2);
}

// Reference deallocation of WSPRClassRouter using normal init method
- (void)testDeallocWSPRClassRouteras
{
    WSPRClassRouter *object = [[WSPRClassRouter alloc] initWithClass:[WSPRTestObject class]];
    __weak WSPRClassRouter *weakObject = object;
    object = nil;
    XCTAssertNil(weakObject);
}

// Reference deallocation of WSPRClassRouter using `autoreleased` instance pattern
- (void)testDeallocWSPRClassRouter
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"n/a"];
    
    WSPRClassRouter *object = [WSPRClassRouter routerWithClass:[WSPRTestObject class]];
    __weak WSPRClassRouter *weakObject = object;
    object = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!weakObject)
            [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testDeallocFlushesAllInstances
{
    WSPRTestObject *testObjectToBeAdded = [[WSPRTestObject alloc] init];
    WSPRClassRouter *classRouter = [[WSPRClassRouter alloc] initWithClass:[WSPRTestObject class]];
    __weak WSPRClassRouter *weakClassRouter = classRouter;
    WSPRClassInstance *instance = [classRouter addInstance:testObjectToBeAdded];
    
    id instanceMock = OCMPartialMock(instance.instance);
    
    //Expect instance to be destroyed
    OCMExpect([instanceMock rpcDestructor]);

    //Deallocate instance
    classRouter = nil;
    
    //Verify that added instance is destroyed as a result of the dealloc
    OCMVerifyAll(instanceMock);
    
    //Verify that the router was deallocated
    XCTAssertNil(weakClassRouter);
}


@end
