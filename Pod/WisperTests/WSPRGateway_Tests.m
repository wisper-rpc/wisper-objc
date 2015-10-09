//
//  WSPRGateway_Tests.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 07/10/15.
//  Copyright © 2015 Widespace . All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "WSPRGateway.h"

@interface WSPRGateway_Tests : XCTestCase

@property (nonatomic, strong) WSPRGateway *gateway;

@end

@implementation WSPRGateway_Tests

- (void)setUp
{
    [super setUp];
    self.gateway = [[WSPRGateway alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

-(NSDictionary *)dictionaryFromJSONString:(NSString *)jsonString
{
    return [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
}

- (void)testHandleBadJSON
{
    
}

- (void)testHandleMalformedJSONRequestObject
{
    
}

- (void)testHandleRequest
{
    //Handle incoming request
    id gatewayDelegateMock = OCMProtocolMock(@protocol(WSPRGatewayDelegate));
    
    OCMExpect([gatewayDelegateMock gateway:OCMOCK_ANY didReceiveMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        //Verify message
        WSPRRequest *request = (WSPRRequest *)obj;
        if ([request.method isEqualToString:@"wisper.test.request"] &&
            [request.requestIdentifier isEqualToString:@"test00"] &&
            [request.params count] == 1 &&
            [[request.params firstObject] isEqualToString:@"1"]
            )
        {
            return YES;
        }
        return NO;
    }]]);

    NSString *sampleRequest = @"{\"method\" : \"wisper.test.request\", \"id\" : \"test00\", \"params\" : [\"1\"]}";
    
    self.gateway.delegate = gatewayDelegateMock;
    [self.gateway handleMessageAsJSONString:sampleRequest];
    
    OCMVerifyAll(gatewayDelegateMock);
}

- (void)testHandleNotification
{
    //Handle incoming notification
    id gatewayDelegateMock = OCMProtocolMock(@protocol(WSPRGatewayDelegate));
    
    OCMExpect([gatewayDelegateMock gateway:OCMOCK_ANY didReceiveMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        //Verify message
        WSPRNotification *notification = (WSPRNotification *)obj;
        if (![notification isKindOfClass:[WSPRRequest class]] &&
            [notification.method isEqualToString:@"wisper.test.notification"] &&
            [notification.params count] == 1 &&
            [[notification.params firstObject] isEqualToString:@"1"]
            )
        {
            return YES;
        }
        return NO;
    }]]);
    
    NSString *sampleNotification = @"{\"method\" : \"wisper.test.notification\", \"params\" : [\"1\"]}";
    
    self.gateway.delegate = gatewayDelegateMock;
    [self.gateway handleMessageAsJSONString:sampleNotification];
    
    OCMVerifyAll(gatewayDelegateMock);
}

- (void)testHandleResponse
{
    //Handle incoming response
    id gatewayDelegateMock = OCMProtocolMock(@protocol(WSPRGatewayDelegate));
    
    OCMExpect([gatewayDelegateMock gateway:OCMOCK_ANY didReceiveMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        //Verify message
        WSPRResponse *response = (WSPRResponse *)obj;
        if ([response.requestIdentifier isEqualToString:@"response1"] &&
            [(NSArray *)response.result count] == 1 &&
            [[(NSArray *)response.result firstObject] isEqualToString:@"2"]
            )
        {
            return YES;
        }
        return NO;
    }]]);
    
    NSString *sampleResponse = @"{\"id\" : \"response1\", \"result\" : [\"2\"]}";
    
    self.gateway.delegate = gatewayDelegateMock;
    [self.gateway handleMessageAsJSONString:sampleResponse];
    
    OCMVerifyAll(gatewayDelegateMock);
}

- (void)testHandleError
{
    //Handle incoming response
    id gatewayDelegateMock = OCMProtocolMock(@protocol(WSPRGatewayDelegate));
    
    OCMExpect([gatewayDelegateMock gateway:OCMOCK_ANY didReceiveMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        //Verify message
        WSPRErrorMessage *errorMessage = (WSPRErrorMessage *)obj;
        WSPRError *error = errorMessage.error;
        if (error.domain == WSPRErrorDomainRPC &&
            error.code == 1234 &&
            [error.message isEqualToString:@"error message"]
            )
        {
            return YES;
        }
        return NO;
    }]]);
    
    NSString *sampleResponse = @"{\"error\" : {\"domain\" : 1, \"code\" : 1234, \"message\" : \"error message\"}}";
    
    self.gateway.delegate = gatewayDelegateMock;
    [self.gateway handleMessageAsJSONString:sampleResponse];
    
    OCMVerifyAll(gatewayDelegateMock);
}

- (void)testSendRequest
{
    id gatewayDelegateMock = OCMProtocolMock(@protocol(WSPRGatewayDelegate));
    
    OCMExpect([gatewayDelegateMock gateway:OCMOCK_ANY didOutputMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        //Verify message
        NSString *jsonMessage = (NSString *)obj;
        WSPRRequest *request = (WSPRRequest *)[WSPRMessageFactory messageFromDictionary:[self dictionaryFromJSONString:jsonMessage]];
        if ([request.method isEqualToString:@"wisper.test.request"] &&
            [request.requestIdentifier length] > 0 &&
            [request.params count] == 1 &&
            [[request.params firstObject] isEqualToString:@"1"]
            )
        {
            return YES;
        }
        return NO;
    }]]);
    
    WSPRRequest *request = [WSPRRequest message];
    request.method = @"wisper.test.request";
    request.params = @[@"1"];
    
    self.gateway.delegate = gatewayDelegateMock;
    [self.gateway sendMessage:request];
    
    OCMVerifyAll(gatewayDelegateMock);
}

- (void)testSendNotification
{
    id gatewayDelegateMock = OCMProtocolMock(@protocol(WSPRGatewayDelegate));
    
    OCMExpect([gatewayDelegateMock gateway:OCMOCK_ANY didOutputMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        //Verify message
        NSString *jsonMessage = (NSString *)obj;
        WSPRNotification *notification = (WSPRNotification *)[WSPRMessageFactory messageFromDictionary:[self dictionaryFromJSONString:jsonMessage]];
        if (![notification isKindOfClass:[WSPRRequest class]] &&
            [notification.method isEqualToString:@"wisper.test.notification"] &&
            [notification.params count] == 1 &&
            [[notification.params firstObject] isEqualToString:@"1"]
            )
        {
            return YES;
        }
        return NO;
    }]]);
    
    WSPRNotification *notification = [WSPRNotification message];
    notification.method = @"wisper.test.notification";
    notification.params = @[@"1"];
    
    self.gateway.delegate = gatewayDelegateMock;
    [self.gateway sendMessage:notification];
    
    OCMVerifyAll(gatewayDelegateMock);
}

- (void)testSendResponse
{
    id gatewayDelegateMock = OCMProtocolMock(@protocol(WSPRGatewayDelegate));
    
    OCMExpect([gatewayDelegateMock gateway:OCMOCK_ANY didOutputMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        //Verify message
        NSString *jsonMessage = (NSString *)obj;
        WSPRResponse *response = (WSPRResponse *)[WSPRMessageFactory messageFromDictionary:[self dictionaryFromJSONString:jsonMessage]];
        if ([(NSString *)response.result isEqualToString:@"success"]&&
            [response.requestIdentifier isEqualToString:@"test00"]
            )
        {
            return YES;
        }
        return NO;
    }]]);
    
    WSPRResponse *response = [WSPRResponse message];
    response.requestIdentifier = @"test00";
    response.result = @"success";
    
    self.gateway.delegate = gatewayDelegateMock;
    [self.gateway sendMessage:response];
    
    OCMVerifyAll(gatewayDelegateMock);
}

- (void)testSendError
{
    id gatewayDelegateMock = OCMProtocolMock(@protocol(WSPRGatewayDelegate));
    
    OCMExpect([gatewayDelegateMock gateway:OCMOCK_ANY didOutputMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        //Verify message
        NSString *jsonMessage = (NSString *)obj;
        WSPRErrorMessage *errorMessage = (WSPRErrorMessage *)[WSPRMessageFactory messageFromDictionary:[self dictionaryFromJSONString:jsonMessage]];
        WSPRError *error = errorMessage.error;
        if (error.domain == WSPRErrorDomainRPC &&
            error.code == 1234 &&
            [error.message isEqualToString:@"error message"]
            )
        {
            return YES;
        }
        return NO;
    }]]);
    
    WSPRError *error = [WSPRError errorWithDictionary:@{
                                                        @"domain" : @1,
                                                        @"code" : @1234,
                                                        @"message" : @"error message"
                                                        }];
    WSPRErrorMessage *errorMessage = [WSPRErrorMessage message];
    errorMessage.error = error;
    
    self.gateway.delegate = gatewayDelegateMock;
    [self.gateway sendMessage:errorMessage];
    
    OCMVerifyAll(gatewayDelegateMock);

    OCMExpect([gatewayDelegateMock gateway:OCMOCK_ANY didReceiveMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
        //Verify message
        WSPRErrorMessage *errorMessage = (WSPRErrorMessage *)obj;
        WSPRError *error = errorMessage.error;
        if (error.domain == WSPRErrorDomainRPC &&
            error.code == 1234 &&
            [error.message isEqualToString:@"error message"]
            )
        {
            return YES;
        }
        return NO;
    }]]);

}

- (void)testResponseToRequest
{
        //Handle incoming request
        //Make response
        //Verify outgoing response message
        
        id gatewayDelegateMock = OCMProtocolMock(@protocol(WSPRGatewayDelegate));
        
        OCMExpect([gatewayDelegateMock gateway:OCMOCK_ANY didReceiveMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
            //Verify message
            WSPRRequest *request = (WSPRRequest *)obj;
            if ([request.method isEqualToString:@"wisper.test.request"] &&
                [request.requestIdentifier isEqualToString:@"test00"] &&
                [request.params count] == 1 &&
                [[request.params firstObject] isEqualToString:@"1"]
                )
            {
                WSPRResponse *response = [request createResponse];
                response.result = @"success";
                request.responseBlock(response);
                return YES;
            }
            return NO;
        }]]);
        
        OCMExpect([gatewayDelegateMock gateway:OCMOCK_ANY didOutputMessage:[OCMArg checkWithBlock:^BOOL(id obj) {
            //Verify message
            NSString *jsonMessage = (NSString *)obj;
            WSPRResponse *response = (WSPRResponse *)[WSPRMessageFactory messageFromDictionary:[self dictionaryFromJSONString:jsonMessage]];
            if ([(NSString *)response.result isEqualToString:@"success"])
            {
                return YES;
            }
            return NO;
        }]]);
        
        WSPRRequest *request = [WSPRRequest message];
        request.requestIdentifier = @"test00";
        request.method = @"wisper.test.request";
        request.params = @[@"1"];
        
        self.gateway.delegate = gatewayDelegateMock;
        [self.gateway handleMessage:request];
        
        OCMVerifyAll(gatewayDelegateMock);
}


@end
