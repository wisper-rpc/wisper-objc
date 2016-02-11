//
//  WSPRClassRouter_Tests.m
//  Wisper
//
//  Created by Patrik Nyblad on 11/02/16.
//  Copyright © 2016 Patrik Nyblad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "WSPRClassRouter.h"

@interface WSPRClassRouter_Tests : XCTestCase

@end

@implementation WSPRClassRouter_Tests

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

- (void)testInitSetsWisperClassModel
{
    WSPRClassRouter *classRouter = [[WSPRClassRouter alloc] initWithClass:[WSPRObject class]];
    XCTAssert([classRouter.classModel.mapName isEqualToString:@"WSPRClass"], @"Class model not set correctly on init!");
}


@end
