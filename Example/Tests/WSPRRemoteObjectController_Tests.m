//
//  WSUTRPCRemoteObjectController.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 01/07/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "WSPRRemoteObjectController.h"
#import "WSPRTestObject.h"

@interface WSPRRemoteObjectController_Tests : XCTestCase

@property (nonatomic, strong) WSPRRemoteObjectController *remoteObjectController;

@end

@implementation WSPRRemoteObjectController_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    WSPRClass *testObjectClassModel = [WSPRTestObject rpcRegisterClass];
    testObjectClassModel.mapName = @"wisp.test.TestObject";
    
    id classMock = OCMClassMock([WSPRTestObject class]);
    OCMStub([classMock rpcRegisterClass]).andReturn(testObjectClassModel);
    
    self.remoteObjectController = [[WSPRRemoteObjectController alloc] init];
    [self.remoteObjectController registerClass:[WSPRTestObject class]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPassByReferenceBySendingRecursiveReference
{
    //Create RPCTestObject mock
    id rpcTestObjectMock = [OCMockObject partialMockForObject:[[WSPRTestObject alloc] init]];
    WSPRClass *rpcClassModel = [self.remoteObjectController getRPCClassForClass:[WSPRTestObject class]];
    WSPRClassInstance *classInstance = [self.remoteObjectController addRPCObjectInstance:(id<WSPRClassProtocol>)rpcTestObjectMock withRPCClass:rpcClassModel];
    
    __block BOOL didCallMockBlock = NO;
    OCMStub([rpcTestObjectMock passByReference:[OCMArg any]]).andDo(^(NSInvocation *invocation){
        didCallMockBlock = YES;
        WSPRObject *firstArgument = nil;
        [invocation getArgument:&firstArgument atIndex:2];
        XCTAssert(firstArgument == rpcTestObjectMock, @"Bad reference passed!");
    });
    
    WSPRNotification *passByReferenceNotification = [WSPRNotification message];
    passByReferenceNotification.method = @"wisp.test.TestObject:passByReference";
    passByReferenceNotification.params = @[classInstance.instanceIdentifier, classInstance.instanceIdentifier];
    [self.remoteObjectController handleMessage:passByReferenceNotification];
    
    XCTAssert(didCallMockBlock, @"Mocked block was never run!");
}

- (void)testPassByReferenceNil
{
    //Create RPCTestObject mock
    id rpcTestObjectMock = [OCMockObject partialMockForObject:[[WSPRTestObject alloc] init]];
    WSPRClass *rpcClassModel = [self.remoteObjectController getRPCClassForClass:[WSPRTestObject class]];
    WSPRClassInstance *classInstance = [self.remoteObjectController addRPCObjectInstance:(id<WSPRClassProtocol>)rpcTestObjectMock withRPCClass:rpcClassModel];
    
    __block BOOL didCallMockBlock = NO;
    OCMStub([rpcTestObjectMock passByReference:[OCMArg any]]).andDo(^(NSInvocation *invocation){
        didCallMockBlock = YES;
        WSPRObject *firstArgument = nil;
        [invocation getArgument:&firstArgument atIndex:2];
        XCTAssertNil(firstArgument, @"Argument should be nil");
    });
    
    WSPRNotification *passByReferenceNotification = [WSPRNotification message];
    passByReferenceNotification.method = @"wisp.test.TestObject:passByReference";
    passByReferenceNotification.params = @[classInstance.instanceIdentifier, [NSNull null]];
    [self.remoteObjectController handleMessage:passByReferenceNotification];
    
    XCTAssert(didCallMockBlock, @"Mocked block was never run!");
}

- (void)testPassByReferenceBadReference
{
    //Create RPCTestObject mock
    WSPRTestObject *rpcTestObject = [[WSPRTestObject alloc] init];
    WSPRClass *rpcClassModel = [self.remoteObjectController getRPCClassForClass:[WSPRTestObject class]];
    WSPRClassInstance *classInstance = [self.remoteObjectController addRPCObjectInstance:(id<WSPRClassProtocol>)rpcTestObject withRPCClass:rpcClassModel];
    
    NSString *badReferenceId = @"BadReferenceID0x0000000";
    
    id remoteObjectControllerDelegateMock = [OCMockObject niceMockForProtocol:@protocol(WSPRGatewayDelegate)];
    self.remoteObjectController.delegate = remoteObjectControllerDelegateMock;
    __block BOOL didCallMockBlock = NO;
    OCMStub([remoteObjectControllerDelegateMock gateway:[OCMArg any] didOutputMessage:[OCMArg any]]).andDo(^(NSInvocation *invocation){
        didCallMockBlock = YES;
        __unsafe_unretained WSPRGateway *firstArgument = nil;
        __unsafe_unretained NSString *secondArgument = nil;

        [invocation getArgument:&firstArgument atIndex:2];
        [invocation getArgument:&secondArgument atIndex:3];

        NSLog(@"Second Argument: %@", secondArgument);
        
        XCTAssert(firstArgument == self.remoteObjectController, @"Wrong remote object controller!");
        XCTAssert([secondArgument containsString:@"error"] && [secondArgument containsString:badReferenceId], @"No error for bad reference!");
    });
    
    WSPRNotification *passByReferenceNotification = [WSPRNotification message];
    passByReferenceNotification.method = @"wisp.test.TestObject:passByReference";
    passByReferenceNotification.params = @[classInstance.instanceIdentifier, badReferenceId];
    [self.remoteObjectController handleMessage:passByReferenceNotification];
    
    XCTAssert(didCallMockBlock, @"Mocked block was never run!");
}


- (void)testPassByReferencePropertyBySendingRecursiveReference
{
    //Create RPCTestObject mock
    WSPRTestObject *rpcTestObject = [[WSPRTestObject alloc] init];
    WSPRClass *rpcClassModel = [self.remoteObjectController getRPCClassForClass:[WSPRTestObject class]];
    WSPRClassInstance *classInstance = [self.remoteObjectController addRPCObjectInstance:rpcTestObject withRPCClass:rpcClassModel];
    
    WSPRNotification *passByReferenceNotification = [WSPRNotification message];
    passByReferenceNotification.method = @"wisp.test.TestObject:!";
    passByReferenceNotification.params = @[classInstance.instanceIdentifier, @"testPassByReferenceProperty", classInstance.instanceIdentifier];
    [self.remoteObjectController handleMessage:passByReferenceNotification];
    
    XCTAssertEqual(rpcTestObject.testPassByReferenceProperty, rpcTestObject, @"Property instance not assigned correctly");
}

- (void)testPassByReferencePropertyKVOSendingEvent
{
    //Create RPCTestObject mock
    WSPRTestObject *rpcTestObject = [[WSPRTestObject alloc] init];
    WSPRClass *rpcClassModel = [self.remoteObjectController getRPCClassForClass:[WSPRTestObject class]];
    WSPRClassInstance *classInstance = [self.remoteObjectController addRPCObjectInstance:rpcTestObject withRPCClass:rpcClassModel];
    
    NSString *expectedParams = [NSString stringWithFormat:@"[\"%@\",\"testPassByReferenceProperty\",\"%@\"]", classInstance.instanceIdentifier, classInstance.instanceIdentifier];

    id remoteObjectControllerDelegateMock = [OCMockObject niceMockForProtocol:@protocol(WSPRGatewayDelegate)];
    self.remoteObjectController.delegate = remoteObjectControllerDelegateMock;
    __block BOOL didCallMockBlock = NO;
    OCMStub([remoteObjectControllerDelegateMock gateway:[OCMArg any] didOutputMessage:[OCMArg any]]).andDo(^(NSInvocation *invocation){
        didCallMockBlock = YES;
        __unsafe_unretained WSPRGateway *firstArgument = nil;
        __unsafe_unretained NSString *secondArgument = nil;
        
        [invocation getArgument:&firstArgument atIndex:2];
        [invocation getArgument:&secondArgument atIndex:3];
        
        NSLog(@"Second Argument: %@", secondArgument);
        

        XCTAssert(firstArgument == self.remoteObjectController, @"Wrong remote object controller!");
        XCTAssert([secondArgument containsString:expectedParams], @"No error for bad reference!");
    });
    
    rpcTestObject.testPassByReferenceProperty = rpcTestObject;
    
    XCTAssert(didCallMockBlock, @"Mocked block was never run!");
}

- (void)testPassByReferencePropertyKVOSendingNilIfBadReference
{
    NSObject *dummyObject = [[NSObject alloc] init];
    
    //Create RPCTestObject mock
    WSPRTestObject *rpcTestObject = [[WSPRTestObject alloc] init];
    WSPRClass *rpcClassModel = [self.remoteObjectController getRPCClassForClass:[WSPRTestObject class]];
    WSPRClassInstance *classInstance = [self.remoteObjectController addRPCObjectInstance:rpcTestObject withRPCClass:rpcClassModel];
    
    NSString *expectedParams = [NSString stringWithFormat:@"[\"%@\",\"testPassByReferenceProperty\",null]", classInstance.instanceIdentifier];
    
    id remoteObjectControllerDelegateMock = [OCMockObject niceMockForProtocol:@protocol(WSPRGatewayDelegate)];
    self.remoteObjectController.delegate = remoteObjectControllerDelegateMock;
    __block BOOL didCallMockBlock = NO;
    OCMStub([remoteObjectControllerDelegateMock gateway:[OCMArg any] didOutputMessage:[OCMArg any]]).andDo(^(NSInvocation *invocation){
        didCallMockBlock = YES;
        __unsafe_unretained WSPRGateway *firstArgument = nil;
        __unsafe_unretained NSString *secondArgument = nil;
        
        [invocation getArgument:&firstArgument atIndex:2];
        [invocation getArgument:&secondArgument atIndex:3];
        
        NSLog(@"Second Argument: %@", secondArgument);
        XCTAssert(firstArgument == self.remoteObjectController, @"Wrong remote object controller!");
        XCTAssert([secondArgument containsString:expectedParams], @"No error for bad reference!");
    });
    
    rpcTestObject.testPassByReferenceProperty = (id)dummyObject;
    
    XCTAssert(didCallMockBlock, @"Mocked block was never run!");
}



@end
