//
//  WSPRRouter_Tests.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 07/10/15.
//  Copyright © 2015 Widespace . All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "WSPRRouter.h"

@interface WSPRRouter_Tests : XCTestCase

@property (nonatomic, strong) WSPRRouter *router1;
@property (nonatomic, strong) WSPRRouter *router2;
@property (nonatomic, strong) WSPRRouter *router3;

@end

@implementation WSPRRouter_Tests

- (void)setUp
{
    [super setUp];
    self.router1 = [[WSPRRouter alloc] init];
    self.router2 = [[WSPRRouter alloc] init];
    self.router3 = [[WSPRRouter alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testExposeRouteOneStep
{
    [_router1 exposeRoute:_router2 onPath:@"r2"];
    XCTAssertEqual([_router1 routes][@"r2"], _router2, @"Did not add route correctly!");
    XCTAssertEqual([_router2 parentRoute], _router1, @"Parent route was not set correctly!");
}

- (void)testExposeRouteMultiStep
{
    [_router1 exposeRoute:_router2 onPath:@"some.path.r2"];

    WSPRRouter *someRouter = [_router1 routes][@"some"];
    WSPRRouter *pathRouter = [someRouter routes][@"path"];
    WSPRRouter *r2Router = [pathRouter routes][@"r2"];
    
    XCTAssert(someRouter && someRouter != _router1 && someRouter != _router2, @"Router was not generated properly");
    
    XCTAssert(pathRouter && pathRouter != _router1 && pathRouter != _router2, @"Router was not generated properly");
    
    XCTAssertEqual(_router2, r2Router, @"Last route was not set correctly.");
    
    XCTAssertEqual([_router2 parentRoute], pathRouter, @"Parent router not linked properly");
    XCTAssertEqual([pathRouter parentRoute], someRouter, @"Parent router not linked properly");
    XCTAssertEqual([someRouter parentRoute], _router1, @"Parent router not linked properly");
}

- (void)testExposeSameRouteTwice
{
    [_router1 exposeRoute:_router2 onPath:@"some.path.r2"];
    [_router1 exposeRoute:_router2 onPath:@"some.path.r2"];
    
    WSPRRouter *someRouter = [_router1 routes][@"some"];
    WSPRRouter *pathRouter = [someRouter routes][@"path"];
    WSPRRouter *r2Router = [pathRouter routes][@"r2"];
    
    XCTAssert(someRouter && someRouter != _router1 && someRouter != _router2, @"Router was not generated properly");
    
    XCTAssert(pathRouter && pathRouter != _router1 && pathRouter != _router2, @"Router was not generated properly");
    
    XCTAssertEqual(_router2, r2Router, @"Last route was not set correctly.");
    
    XCTAssertEqual([_router2 parentRoute], pathRouter, @"Parent router not linked properly");
    XCTAssertEqual([pathRouter parentRoute], someRouter, @"Parent router not linked properly");
    XCTAssertEqual([someRouter parentRoute], _router1, @"Parent router not linked properly");

}

- (void)testRouteMessage
{
    id router3Mock = OCMPartialMock(_router3);
    
    WSPRNotification *notification = [WSPRNotification message];
    notification.method = @"r2.r3.call";
    notification.params = @[@"Hello", @"world!"];
    
    OCMExpect([router3Mock route:[OCMArg checkWithBlock:^BOOL(id obj) {
        if (obj == notification)
        {
            return YES;
        }
        return NO;
    }] toPath:[OCMArg checkWithBlock:^BOOL(id obj) {
        if ([(NSString *)obj isEqualToString:@"call"])
        {
            return YES;
        }
        return NO;
    }]]);
    
    [_router1 exposeRoute:_router2 onPath:@"r2"];
    [_router2 exposeRoute:_router3 onPath:@"r3"];
    [_router1 route:notification toPath:notification.method];
    
    OCMVerifyAll(router3Mock);
}

- (void)testReverseRouteMessage
{
    id router1Mock = OCMPartialMock(_router1);
    
    WSPRNotification *notification = [WSPRNotification message];
    notification.method = @"wisper.Class:method";
    notification.params = @[@"Hello", @"world!"];
    
    OCMExpect([router1Mock reverse:[OCMArg checkWithBlock:^BOOL(id obj) {
        if (obj == notification)
        {
            return YES;
        }
        return NO;
    }] fromPath:[OCMArg checkWithBlock:^BOOL(id obj) {
        if ([(NSString *)obj isEqualToString:@"r2.r3"])
        {
            return YES;
        }
        return NO;
    }]]);
    
    [_router1 exposeRoute:_router2 onPath:@"r2"];
    [_router2 exposeRoute:_router3 onPath:@"r3"];
    [_router3 reverse:notification fromPath:nil];
    
    OCMVerifyAll(router1Mock);
}

- (void)testGetRootRouter
{
    [_router1 exposeRoute:_router2 onPath:@"r2"];
    [_router2 exposeRoute:_router3 onPath:@"r3"];
    
    XCTAssertEqual([_router3 rootRouter], _router1, @"Wrong root router returned");
}

- (void)testGetRootRouterOnRoot
{
    XCTAssertEqual([_router1 rootRouter], _router1, @"Wrong root router returned");
}

- (void)testGetRouterAtPath
{
    [_router1 exposeRoute:_router3 onPath:@"r2.r3"];
    XCTAssertEqual([_router1 routerAtPath:@"r2.r3"], _router3, @"Router could not be found!");
}

- (void)testBadRequestRouteThrows
{
    WSPRRequest *request = [[WSPRRequest alloc] init];
    request.method = @"no.route.for.message";
    request.requestIdentifier = @"0";
    request.params = @[@"Yup"];
    request.responseBlock = ^(WSPRResponse *response) {
    };
    
    XCTAssertThrows([_router1 route:request toPath:request.method], @"Bad route did not throw as expected!");
}


@end
