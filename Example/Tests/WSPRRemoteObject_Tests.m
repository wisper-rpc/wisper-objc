//
//  WSPRRemoteObject_Tests.m
//  Wisper
//
//  Created by Patrik Nyblad on 26/01/16.
//  Copyright © 2016 Patrik Nyblad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "WSPRRemoteObject.h"
#import "WSPRGateway.h"

@interface WSPRRemoteObject ()

-(void)implementationLessMethodTurnedIntoNotification;
-(void)implementationLessMethodTurnedIntoNotificationWithString:(NSString *)string;
-(void)implementationLessMethodTurnedIntoNotificationWithString:(NSString *)string andNumber:(NSNumber *)number;

@end

@interface WSPRRemoteObject_Tests : XCTestCase

@end

@implementation WSPRRemoteObject_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitWithMapNameAndGatewayFiresInitMessage
{
    id mockGateway = OCMPartialMock([WSPRGateway alloc]);
    OCMExpect([mockGateway sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRRequest *initRequest = (WSPRRequest *)obj;
        if ([initRequest.method isEqualToString:@"test.Test~"])
        {
            return YES;
        }
        return NO;
    }]]);
    
    WSPRRemoteObject *remoteObject = [[WSPRRemoteObject alloc] initWithMapName:@"test.Test" andGateway:mockGateway];
    
    OCMVerifyAllWithDelay(mockGateway, 0.1);
}

- (void)testInitResponseSetsInstanceIdentifier
{
    id mockGateway = OCMPartialMock([[WSPRGateway alloc] init]);
    
    //Init should not have fired message
    OCMExpect([mockGateway sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRRequest *initRequest = (WSPRRequest *)obj;
        
        WSPRResponse *response = [initRequest createResponse];
        response.result = @{@"id" : @"AAA"};
        initRequest.responseBlock(response);
        
        return YES;
    }]]);
    
    WSPRRemoteObject *remoteObject = [[WSPRRemoteObject alloc] initWithMapName:@"test.Test" andGateway:mockGateway];
    
    XCTAssert([remoteObject.instanceIdentifier isEqualToString:@"AAA"], @"Instance identifier not set");
    
    OCMVerifyAllWithDelay(mockGateway, 0.1);
}

- (void)testStaticMethodMessage
{
    id mockGateway = OCMPartialMock([[WSPRGateway alloc] init]);
    
    OCMExpect([mockGateway sendMessage:OCMOCK_ANY]);
    OCMExpect([mockGateway sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRRequest *request = (WSPRRequest *)obj;
        if ([request.method isEqualToString:@"test.Test.staticCall"])
        {
            return YES;
        }
        return NO;
    }]]);
    
    WSPRRemoteObject *remoteObject = [[WSPRRemoteObject alloc] initWithMapName:@"test.Test" andGateway:mockGateway];
    [remoteObject _wisperCallStaticMethod:@"staticCall" withParams:nil];
    
    OCMVerifyAllWithDelay(mockGateway, 0.1);
}

- (void)testInstanceMethodQueuedAndNotFiredIfNoInstanceId
{
    id mockGateway = OCMPartialMock([[WSPRGateway alloc] init]);
    
    OCMExpect([mockGateway sendMessage:OCMOCK_ANY]);
    OCMExpect([[mockGateway reject] sendMessage:OCMOCK_ANY]);
    
    WSPRRemoteObject *remoteObject = [[WSPRRemoteObject alloc] initWithMapName:@"test.Test" andGateway:mockGateway];
    [remoteObject _wisperCallInstanceMethod:@"instanceCall" withParams:nil];
    
    OCMVerifyAllWithDelay(mockGateway, 0.5);
}

- (void)testInstanceMethodQueuedFiredAfterDelayedInitResponse
{
    id mockGateway = OCMPartialMock([[WSPRGateway alloc] init]);
    
    OCMExpect([mockGateway sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRRequest *initRequest = (WSPRRequest *)obj;
        
        WSPRResponse *response = [initRequest createResponse];
        response.result = @{@"id" : @"AAA"};
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            initRequest.responseBlock(response);
        });
        
        return YES;
    }]]);
    OCMExpect([mockGateway sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRRequest *request = (WSPRRequest *)obj;
        if ([request.method isEqualToString:@"test.Test:instanceCall"] && [[request.params firstObject] isEqualToString:@"AAA"])
        {
            return YES;
        }
        return NO;
    }]]);
    
    WSPRRemoteObject *remoteObject = [[WSPRRemoteObject alloc] initWithMapName:@"test.Test" andGateway:mockGateway];
    [remoteObject _wisperCallInstanceMethod:@"instanceCall" withParams:nil];
    
    OCMVerifyAllWithDelay(mockGateway, 1.0);
}

- (void)testInstanceMethodMessage
{
    id mockGateway = OCMPartialMock([[WSPRGateway alloc] init]);
    
    OCMExpect([mockGateway sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRRequest *initRequest = (WSPRRequest *)obj;
        
        WSPRResponse *response = [initRequest createResponse];
        response.result = @{@"id" : @"AAA"};
        initRequest.responseBlock(response);
        
        return YES;
    }]]);
    OCMExpect([mockGateway sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRRequest *request = (WSPRRequest *)obj;
        if ([request.method isEqualToString:@"test.Test:instanceCall"] && [[request.params firstObject] isEqualToString:@"AAA"])
        {
            return YES;
        }
        return NO;
    }]]);
    
    WSPRRemoteObject *remoteObject = [[WSPRRemoteObject alloc] initWithMapName:@"test.Test" andGateway:mockGateway];
    [remoteObject _wisperCallInstanceMethod:@"instanceCall" withParams:nil];
    
    OCMVerifyAllWithDelay(mockGateway, 0.1);
}

- (void)testInstanceMethodSendsInstanceIDAsFirstParam
{
    id mockGateway = OCMPartialMock([[WSPRGateway alloc] init]);
    
    //Init should not have fired message
    OCMExpect([mockGateway sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRRequest *initRequest = (WSPRRequest *)obj;
        
        WSPRResponse *response = [initRequest createResponse];
        response.result = @{@"id" : @"AAA"};
        initRequest.responseBlock(response);
        
        return YES;
    }]]);
    OCMExpect([mockGateway sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRRequest *request = (WSPRRequest *)obj;
        if ([request.method isEqualToString:@"test.Test:instanceCall"] && [[request.params firstObject] isEqualToString:@"AAA"])
        {
            return YES;
        }
        return NO;
    }]]);
    
    WSPRRemoteObject *remoteObject = [[WSPRRemoteObject alloc] initWithMapName:@"test.Test" andGateway:mockGateway];
    [remoteObject _wisperCallInstanceMethod:@"instanceCall" withParams:@[@(123), @"test", @[@"hehe"]]];
    
    OCMVerifyAllWithDelay(mockGateway, 0.1);
}


#pragma mark - Forward Invocation Tests

- (void)testForwardWisperInvocationNoParams
{
    id mockGateway = OCMPartialMock([[WSPRGateway alloc] init]);
    
    OCMExpect([mockGateway sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRRequest *initRequest = (WSPRRequest *)obj;
        
        WSPRResponse *response = [initRequest createResponse];
        response.result = @{@"id" : @"AAA"};
        initRequest.responseBlock(response);
        
        return YES;
    }]]);
    OCMExpect([mockGateway sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRRequest *request = (WSPRRequest *)obj;
        if ([request.method isEqualToString:@"test.Test:implementationLessMethodTurnedIntoNotification"] && [[request.params firstObject] isEqualToString:@"AAA"])
        {
            return YES;
        }
        return NO;
    }]]);
    
    WSPRRemoteObject *remoteObject = [[WSPRRemoteObject alloc] initWithMapName:@"test.Test" andGateway:mockGateway];
    [remoteObject implementationLessMethodTurnedIntoNotification];
    
    OCMVerifyAllWithDelay(mockGateway, 0.1);
}

- (void)testForwardWisperInvocationSingleParam
{
    id mockGateway = OCMPartialMock([[WSPRGateway alloc] init]);
    
    OCMExpect([mockGateway sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRRequest *initRequest = (WSPRRequest *)obj;
        
        WSPRResponse *response = [initRequest createResponse];
        response.result = @{@"id" : @"AAA"};
        initRequest.responseBlock(response);
        
        return YES;
    }]]);
    OCMExpect([mockGateway sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRRequest *request = (WSPRRequest *)obj;
        if ([request.method isEqualToString:@"test.Test:implementationLessMethodTurnedIntoNotificationWithString"] &&
            [[request.params firstObject] isEqualToString:@"AAA"] &&
            [request.params[1] isEqualToString:@"someParam"])
        {
            return YES;
        }
        return NO;
    }]]);
    
    WSPRRemoteObject *remoteObject = [[WSPRRemoteObject alloc] initWithMapName:@"test.Test" andGateway:mockGateway];
    [remoteObject implementationLessMethodTurnedIntoNotificationWithString:@"someParam"];
    
    OCMVerifyAllWithDelay(mockGateway, 0.1);
}

- (void)testForwardWisperInvocationMultipleParams
{
    id mockGateway = OCMPartialMock([[WSPRGateway alloc] init]);
    
    OCMExpect([mockGateway sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRRequest *initRequest = (WSPRRequest *)obj;
        
        WSPRResponse *response = [initRequest createResponse];
        response.result = @{@"id" : @"AAA"};
        initRequest.responseBlock(response);
        
        return YES;
    }]]);
    OCMExpect([mockGateway sendMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        WSPRRequest *request = (WSPRRequest *)obj;
        if ([request.method isEqualToString:@"test.Test:implementationLessMethodTurnedIntoNotificationWithString"] &&
            [[request.params firstObject] isEqualToString:@"AAA"] &&
            [request.params[1] isEqualToString:@"someString"] &&
            [request.params[2] integerValue] == 1337)
        {
            return YES;
        }
        return NO;
    }]]);
    
    WSPRRemoteObject *remoteObject = [[WSPRRemoteObject alloc] initWithMapName:@"test.Test" andGateway:mockGateway];
    [remoteObject implementationLessMethodTurnedIntoNotificationWithString:@"someString" andNumber:@(1337)];
    
    OCMVerifyAllWithDelay(mockGateway, 0.1);
}


@end
