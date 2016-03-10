//
//  WSPRFunctionRouter_Tests.m
//  Wisper
//
//  Created by Patrik Nyblad on 10/03/16.
//  Copyright © 2016 Patrik Nyblad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Wisper/WSPRFunctionRouter.h>

@interface WSPRFunctionRouter_Tests : XCTestCase

@end

@implementation WSPRFunctionRouter_Tests

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

- (void)testFunctionRouterCanRunBlock
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"n/a"];
    
    WSPRNotification *notification = [[WSPRNotification alloc] init];
    notification.method = @"a.b.block";
    notification.params = @[@"Hello ", @"world!"];
    
    WSPRFunctionRouter *functionRouter = [WSPRFunctionRouter routerWithBlock:^(WSPRFunctionRouter *caller, WSPRMessage *message){
        if (message == notification)
        {
            [expectation fulfill];
        }
    }];
    
    WSPRRouter *router = [[WSPRRouter alloc] init];
    [router exposeRoute:functionRouter onPath:@"a.b.block"];
    [router route:notification toPath:notification.method];
    
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testFunctionRouterCanHandleDeeperRoutedMessages
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"n/a"];
    
    WSPRNotification *notification = [[WSPRNotification alloc] init];
    notification.method = @"a.b.block.other.route.stuff";
    notification.params = @[@"Hello ", @"world!"];
    
    WSPRFunctionRouter *functionRouter = [WSPRFunctionRouter routerWithBlock:^(WSPRFunctionRouter *caller, WSPRMessage *message){
        if (message == notification)
        {
            [expectation fulfill];
        }
    }];
    
    WSPRRouter *router = [[WSPRRouter alloc] init];
    [router exposeRoute:functionRouter onPath:@"a.b.block"];
    [router route:notification toPath:notification.method];
    
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testFunctionRouterThrowsIfBlock
{
    WSPRNotification *notification = [[WSPRNotification alloc] init];
    notification.method = @"a.b.block.other.route.stuff";
    notification.params = @[@"Hello ", @"world!"];
    
    WSPRFunctionRouter *functionRouter = [WSPRFunctionRouter routerWithBlock:nil];
    
    WSPRRouter *router = [[WSPRRouter alloc] init];
    [router exposeRoute:functionRouter onPath:@"a.b.block"];
    
    XCTAssertThrows([router route:notification toPath:notification.method], @"Expected route to throw due to missing block");
}

@end
