//
//  WSPRInstanceRegistry_Tests.m
//  Wisper
//
//  Created by Patrik Nyblad on 16/02/16.
//  Copyright © 2016 Patrik Nyblad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "WSPRInstanceRegistry.h"

@interface WSPRInstanceRegistry ()

@property (nonatomic, strong) NSMutableDictionary *instances;

+(NSString *)identifierFromRootRoute:(id<WSPRRouteProtocol>)rootRoute;

@end

@interface WSPRInstanceRegistry_Tests : XCTestCase

@end

@implementation WSPRInstanceRegistry_Tests

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

- (void)testAddingInstance
{
    WSPRRouter *rootRoute = [[WSPRRouter alloc] initWithNameSpace:@"R1"];
    WSPRInstanceRegistry *instanceRegistry = [WSPRInstanceRegistry sharedInstance];
    
    WSPRClassInstance *classInstance = [[WSPRClassInstance alloc] init];
    classInstance.instanceIdentifier = @"the_1";
    [WSPRInstanceRegistry addInstance:classInstance underRootRoute:rootRoute];
    
    XCTAssertNotNil(instanceRegistry.instances[[WSPRInstanceRegistry identifierFromRootRoute:rootRoute]], @"No root route map created!");
    
    XCTAssertEqual(instanceRegistry.instances[[WSPRInstanceRegistry identifierFromRootRoute:rootRoute]][classInstance.instanceIdentifier], classInstance, @"Instance was not added!");
}

- (void)testRemovingNonLastInstance
{
    WSPRRouter *rootRoute = [[WSPRRouter alloc] initWithNameSpace:@"R1"];
    WSPRInstanceRegistry *instanceRegistry = [WSPRInstanceRegistry sharedInstance];
    
    WSPRClassInstance *classInstance = [[WSPRClassInstance alloc] init];
    classInstance.instanceIdentifier = @"to_be_removed";
    [WSPRInstanceRegistry addInstance:classInstance underRootRoute:rootRoute];

    WSPRClassInstance *classInstance2 = [[WSPRClassInstance alloc] init];
    classInstance2.instanceIdentifier = @"keeper";
    [WSPRInstanceRegistry addInstance:classInstance2 underRootRoute:rootRoute];

    
    [WSPRInstanceRegistry removeInstance:classInstance underRootRoute:rootRoute];
    
    XCTAssertNotNil(instanceRegistry.instances[[WSPRInstanceRegistry identifierFromRootRoute:rootRoute]], @"No root route map created!");

    XCTAssertNil(instanceRegistry.instances[[WSPRInstanceRegistry identifierFromRootRoute:rootRoute]][classInstance.instanceIdentifier], @"Instance was not removed!");
}

- (void)testRemovingLastInstanceRemovesRootRouteMap
{
    WSPRRouter *rootRoute = [[WSPRRouter alloc] initWithNameSpace:@"R1"];
    WSPRInstanceRegistry *instanceRegistry = [WSPRInstanceRegistry sharedInstance];
    
    WSPRClassInstance *classInstance = [[WSPRClassInstance alloc] init];
    classInstance.instanceIdentifier = @"one";
    [WSPRInstanceRegistry addInstance:classInstance underRootRoute:rootRoute];
    [WSPRInstanceRegistry removeInstance:classInstance underRootRoute:rootRoute];
    
    XCTAssertNil(instanceRegistry.instances[[WSPRInstanceRegistry identifierFromRootRoute:rootRoute]], @"No root route map created!");
}

- (void)testGettingInstanceWithId
{
    WSPRRouter *rootRoute = [[WSPRRouter alloc] initWithNameSpace:@"R1"];
    
    WSPRClassInstance *classInstance = [[WSPRClassInstance alloc] init];
    classInstance.instanceIdentifier = @"neo";
    [WSPRInstanceRegistry addInstance:classInstance underRootRoute:rootRoute];
    
    XCTAssertEqual([WSPRInstanceRegistry instanceWithId:classInstance.instanceIdentifier underRootRoute:rootRoute], classInstance, @"Could not get instance for ID!");
}

- (void)testGettingInstanceWithIdIsScopedForRoute
{
    WSPRRouter *rootRoute = [[WSPRRouter alloc] initWithNameSpace:@"R1"];
    
    WSPRClassInstance *classInstance = [[WSPRClassInstance alloc] init];
    classInstance.instanceIdentifier = @"the_1";
    [WSPRInstanceRegistry addInstance:classInstance underRootRoute:rootRoute];

    WSPRRouter *rootRoute2 = [[WSPRRouter alloc] initWithNameSpace:@"R1"];
    
    WSPRClassInstance *classInstance2 = [[WSPRClassInstance alloc] init];
    classInstance2.instanceIdentifier = @"the_2";
    [WSPRInstanceRegistry addInstance:classInstance2 underRootRoute:rootRoute2];

    XCTAssertNil([WSPRInstanceRegistry instanceWithId:classInstance.instanceIdentifier underRootRoute:rootRoute2], @"Instance was accessible from wrong root route!");
}

@end
