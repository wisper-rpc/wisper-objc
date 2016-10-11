//
//  WSPRRemoteObjectRouter_Tests.m
//  Wisper
//
//  Created by Patrik Nyblad on 29/03/16.
//  Copyright © 2016 Patrik Nyblad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Wisper/WSPRRemoteObjectRouter.h>

//Mock object
@interface TESTRemoteObject : WSPRRemoteObject
@end
@implementation TESTRemoteObject
@end

//Expose private
@interface WSPRRemoteObject ()
@property (nonatomic, strong) NSString *instanceIdentifier;
@end

//Expose private properties and methods for testing
@interface WSPRRemoteObjectRouter ()
@property (nonatomic, strong) NSMutableArray *remoteObjectInstances;
@end

//Expose model object for testing
@protocol EventInstanceModelProtocol <NSObject>
@property (nonatomic, assign) id<WSPRRemoteObjectEventProtocol> remoteObject;
-(instancetype)initWithRemoteObject:(WSPRRemoteObject *)remoteObject;
@end


@interface WSPRRemoteObjectRouter_Tests : XCTestCase

@property (nonatomic, strong) WSPRGatewayRouter *gatewayRouter;
@property (nonatomic, strong) TESTRemoteObject *testObject;
@property (nonatomic, strong) WSPRRemoteObjectRouter *eventRouter;

@end

@implementation WSPRRemoteObjectRouter_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.gatewayRouter = [[WSPRGatewayRouter alloc] init];
    self.testObject = [[TESTRemoteObject alloc] initWithMapName:@"test.TestObject" andGatewayRouter:self.gatewayRouter];
    self.eventRouter = [self.gatewayRouter routerAtPath:@"test.TestObject"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddInstanceAtInit
{
    XCTAssertTrue([self eventRouter:self.eventRouter containsInstance:self.testObject], @"Did not add object to list of objects");
}

- (void)testRemoveInstance
{
    [self.eventRouter unregisterRemoteObjectInstance:self.testObject];
    XCTAssertFalse([self eventRouter:self.eventRouter containsInstance:self.testObject], @"Did not remove object from list of objects");
}

- (void)testRoutesStaticEventsToClass
{
    WSPREvent *event = [[WSPREvent alloc] init];
    event.mapName = @"test.TestObject";
    event.name = @"testEvent";
    
    id testObjectClassMock = OCMClassMock([TESTRemoteObject class]);
    OCMExpect(ClassMethod([testObjectClassMock rpcHandleStaticEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPREvent *mockEvent = obj;
        return [mockEvent.mapName isEqualToString:event.mapName];
    }]]));
    
    [self.eventRouter route:[event createNotification] toPath:@""];
    
    OCMVerifyAll(testObjectClassMock);
}

- (void)testRoutesInstanceEventsToOnlySpecificInstance
{
    [(WSPRRemoteObject *)self.testObject setInstanceIdentifier:@"0x00"];

    WSPREvent *event = [[WSPREvent alloc] init];
    event.mapName = @"test.TestObject";
    event.name = @"testEvent";
    event.instanceIdentifier = self.testObject.instanceIdentifier;
    
    id testObjectMock = OCMPartialMock(self.testObject);
    OCMExpect([testObjectMock rpcHandleInstanceEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPREvent *mockEvent = obj;
        return [mockEvent.mapName isEqualToString:event.mapName];
    }]]);
    
    [self.eventRouter route:[event createNotification] toPath:@""];
    
    OCMVerifyAll(testObjectMock);
}

- (void)testValidEventRequestGetsResponse
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"n/a"];
    
    WSPRRequest *request = [[WSPRRequest alloc] init];
    request.method = @"test.TestObject!";
    request.params = @[@"testEvent", @"meh"];
    request.responseBlock = ^(WSPRResponse *response) {
        if (response)
            [expectation fulfill];
    };
    
    id testObjectClassMock = OCMClassMock([TESTRemoteObject class]);
    OCMExpect(ClassMethod([testObjectClassMock rpcHandleStaticEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPREvent *mockEvent = obj;
        return [mockEvent.name isEqualToString:@"testEvent"];
    }]]));
    
    [self.eventRouter route:request toPath:@""];
    
    OCMVerifyAll(testObjectClassMock);
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testThrowsIfNoInstance
{
    [(WSPRRemoteObject *)self.testObject setInstanceIdentifier:@"0x00"];
    
    WSPREvent *event = [[WSPREvent alloc] init];
    event.mapName = @"test.TestObject";
    event.name = @"testEvent";
    event.instanceIdentifier = @"0x00BADINSTANCE";
    
    id testObjectMock = OCMPartialMock(self.testObject);
    OCMExpect([[testObjectMock reject] rpcHandleInstanceEvent:[OCMArg any]]);
    
    id eventRouterMock = OCMPartialMock(self.eventRouter);
    OCMExpect([eventRouterMock respondToMessage:[OCMArg isNotNil] withError:[OCMArg isNotNil]]);
    [self.eventRouter route:[event createNotification] toPath:@""];
    OCMVerifyAll(eventRouterMock);
    OCMVerifyAll(testObjectMock);
}

- (void)testThrowsIfNotStaticOrInstanceEvent
{
    [(WSPRRemoteObject *)self.testObject setInstanceIdentifier:@"0x00"];
    
    WSPRNotification *badMessage1 = [[WSPRNotification alloc] init];
    badMessage1.method = @"test.TestObject.blah";
    
    WSPRRequest *badMessage2 = [[WSPRRequest alloc] init];
    badMessage2.method = @"test.TestObject.blah";

    WSPRResponse *badMessage3 = [[WSPRResponse alloc] init];
    badMessage3.result = @"BAD";

    WSPRErrorMessage *badMessage4 = [[WSPRErrorMessage alloc] init];
    badMessage4.error = [WSPRError errorWithDomain:0 andCode:0];

    id testObjectClassMock = OCMClassMock([TESTRemoteObject class]);
    id testObjectMock = OCMPartialMock(self.testObject);
    id eventRouterMock = OCMPartialMock(self.eventRouter);
    OCMExpect([[testObjectClassMock reject] rpcHandleStaticEvent:[OCMArg any]]);
    OCMExpect([[testObjectMock reject] rpcHandleInstanceEvent:[OCMArg any]]);
    
    for (WSPRMessage *badMessage in @[badMessage1, badMessage2, badMessage3, badMessage4])
    {
        OCMExpect([eventRouterMock respondToMessage:[OCMArg isNotNil] withError:[OCMArg isNotNil]]);
        [self.eventRouter route:badMessage toPath:@""];
    }
    OCMVerifyAll(eventRouterMock);
    OCMVerifyAll(testObjectClassMock);
    OCMVerifyAll(testObjectMock);
}

-(void)testRemoteObjectNotRetainedByEventRouter
{
    self.testObject = nil;
    XCTAssert(self.eventRouter.remoteObjectInstances.count == 0, @"Did not remove object from list of objects");
}

#pragma mark - Helpers

-(BOOL)eventRouter:(WSPRRemoteObjectRouter *)eventRouter containsInstance:(id<WSPRRemoteObjectEventProtocol>)instance
{
    for (NSObject<EventInstanceModelProtocol> *model in eventRouter.remoteObjectInstances)
    {
        if ([model remoteObject] == instance)
            return YES;
    }
    return NO;
}

@end
