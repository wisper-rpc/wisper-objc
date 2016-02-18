//
//  RemoteObjectIntegrationTests.m
//  Wisper
//
//  Created by Patrik Nyblad on 17/02/16.
//  Copyright © 2016 Patrik Nyblad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "WSPRTestObject.h"
#import "WSPRGatewayRouter.h"
#import "WSPRClassRouter.h"

@interface RemoteObjectIntegrationTests : XCTestCase

@property (nonatomic, strong) WSPRGatewayRouter *gatewayRouter;

@end

@implementation RemoteObjectIntegrationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.gatewayRouter = [[WSPRGatewayRouter alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRegisterTestObject
{
    [_gatewayRouter exposeRoute:[WSPRClassRouter routerWithClass:[WSPRTestObject class]] onPath:@"wisp.test.TestObject"];
    
    WSPRRouter *wispRouter = _gatewayRouter.routes[@"wisp"];
    WSPRRouter *testRouter = wispRouter.routes[@"test"];
    WSPRClassRouter *testObjectRouter = testRouter.routes[@"TestObject"];
    
    XCTAssertEqual(testObjectRouter.classModel.classRef, [WSPRTestObject class], @"Test Object not registered properly!");
}

- (void)testNotifyStaticMethod
{
    id testObjectClassMock = OCMClassMock([WSPRTestObject class]);
    
    OCMExpect(ClassMethod([testObjectClassMock appendString:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [(NSString *)obj isEqualToString:@"Hello "];
    }] withString:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [(NSString *)obj isEqualToString:@"world!"];
    }]]));
    
    [_gatewayRouter exposeRoute:[WSPRClassRouter routerWithClass:[WSPRTestObject class]] onPath:@"wisp.test.TestObject"];
    
    WSPRNotification *notification = [[WSPRNotification alloc] init];
    notification.method = @"wisp.test.TestObject.append";
    notification.params = @[@"Hello ", @"world!"];
    
    [_gatewayRouter.gateway handleMessage:notification];
    
    OCMVerifyAll(testObjectClassMock);
}

- (void)testRequestStaticMethod
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"correct response"];
    
    [_gatewayRouter exposeRoute:[WSPRClassRouter routerWithClass:[WSPRTestObject class]] onPath:@"wisp.test.TestObject"];
    
    WSPRRequest *request = [[WSPRRequest alloc] init];
    request.method = @"wisp.test.TestObject.append";
    request.params = @[@"Hello ", @"world!"];
    request.responseBlock = ^(WSPRResponse *response){
        if ([(NSString *)response.result isEqualToString:@"Hello world!"])
            [expectation fulfill];
    };
    
    [_gatewayRouter.gateway handleMessage:request];
    
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

@end
