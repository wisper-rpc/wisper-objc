//
//  WSPRGateway.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 25/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRGateway.h"

#define WISPER_REQUEST_PREFIX @"WISPER_IOS_REQ-"

@interface WSPRGateway ()

@property (nonatomic, strong) NSMutableDictionary *requests;

@end

@implementation WSPRGateway

-(id)init
{
    self = [super init];
    if (self)
    {
        self.requests = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)handleMessageAsJSONString:(NSString *)jsonString
{
    NSError *serializationError = nil;
    id object =  [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&serializationError];
    
    if (serializationError && !object)
    {
        //We were supposed to handle the request but the JSON was malformatted
        WSPRError *error = [[WSPRError alloc] initWithDomain:WSPRErrorDomainRPC andCode:WSPRErrorRPCParseError];
        error.message = [serializationError localizedDescription];
        
        WSPRResponse *response = [WSPRResponse message];
        response.error = error;
        
        //Try to manually parse some sort of ID from the JSON string and return the error to the sender as a response.
        NSRange idRange = [jsonString rangeOfString:@"id"];
        if (idRange.location != NSNotFound)
        {
            //Get just the id part
            NSString *idString = [jsonString substringFromIndex:idRange.location];
            NSArray *idKeyAndValue = [idString componentsSeparatedByString:@":"];
            if (idKeyAndValue.count > 1)
            {
                NSString *valuePart = idKeyAndValue[1];
                NSUInteger valueStart = [valuePart rangeOfString:@"\""].location+1;
                NSUInteger valueLength = [valuePart rangeOfString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(valueStart, valuePart.length - valueStart)].location-1;
                
                NSString *value = [valuePart substringWithRange:NSMakeRange(valueStart, valueLength)];
                
                if (value)
                {
                    response.requestIdentifier = value;
                }
            }
        }
        [self sendMessage:response];
        return;
    }
    
    WSPRMessage *wisperMessage = [WSPRMessageFactory messageFromDictionary:[object isKindOfClass:[NSDictionary class]] ? object : nil];
    
    if (wisperMessage)
    {
        [self handleMessage:wisperMessage];
    }
    else
    {
        WSPRError *error = [[WSPRError alloc] initWithDomain:WSPRErrorDomainRPC andCode:WSPRErrorRPCFormatError];
        error.message = [NSString stringWithFormat:@"Could not parse message type from message: %@", jsonString];
        
        WSPRResponse *response = [[WSPRResponse alloc] init];
        response.error = error;
        if (object[@"id"])
        {
            response.requestIdentifier = object[@"id"];
        }
        [self sendMessage:response];
    }
}

#pragma mark - Receive message

-(void)handleMessage:(WSPRMessage *)message
{
    WSPRGatewayMessageType messageType = [WSPRMessageFactory messageTypeFromMessage:message];

    if (messageType == WSPRGatewayMessageTypeRequest)
    {
        WSPRRequest *request = (WSPRRequest *)message;
        if (!request.responseBlock)
        {
            __weak WSPRRequest *weakIncomingRequest = request;
            __weak WSPRGateway *weakSelf = self;
            request.responseBlock = ^(WSPRResponse *response)
            {
                //Retain self so that we don't let go of the reference in the middle of execution.
                __strong WSPRGateway *strongSelf = weakSelf;
                __strong WSPRRequest *strongIncomingRequest = weakIncomingRequest;
                [strongSelf sendMessage:response];
                
                //Assign an empty block as soon as this request has been answered by a response so that a second response cannot be sent.
                strongIncomingRequest.responseBlock = ^(WSPRResponse *response){};
            };
        }
    }
    else if (messageType == WSPRGatewayMessageTypeResponse)
    {
        WSPRResponse *response = (WSPRResponse *)message;
        
        //Run response through WSPRRequest object if it invoked the request
        WSPRRequest *request = self.requests[response.requestIdentifier];
        if (request)
        {
            //Remove request from waiting queue
            [self.requests removeObjectForKey:response.requestIdentifier];
            
            if (request.responseBlock)
            {
                request.responseBlock(response);
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(gateway:didReceiveMessage:)])
    {
        [self.delegate gateway:self didReceiveMessage:message];
    }
}


#pragma mark - Send message

-(void)sendMessage:(WSPRMessage *)message
{
    WSPRGatewayMessageType messageType = [WSPRMessageFactory messageTypeFromMessage:message];

    if (messageType == WSPRGatewayMessageTypeRequest)
    {
        [(WSPRRequest *)message setRequestIdentifier:[[self class] uniqueRequestString]];
    }
    
    @try
    {
        NSString *jsonString = [message asJSONString];
        
        //Parsing was OK?
        if (jsonString)
        {
            if (messageType == WSPRGatewayMessageTypeRequest)
            {
                //Store the request so that we can run the response through the callback block when done
                self.requests[[(WSPRRequest *)message requestIdentifier]] = message;
            }

            //Make the Notification call
            [self sendMessageWithJSONString:jsonString];
        }
    }
    @catch (NSException *exception)
    {
        WSPRError *error = [WSPRError errorWithDomain:WSPRErrorDomainRPC andCode:WSPRErrorRPCParseError];
        error.message = @"JSON Parse error";
        error.data = @{
                       @"exception" : @{
                               @"name" : exception.name,
                               @"reason" : exception.reason
                               }
                       };
        if (messageType == WSPRGatewayMessageTypeRequest)
        {
            WSPRResponse *response = [(WSPRRequest *)message createResponse];
            [(WSPRRequest *)message responseBlock](response);
        }
        else
        {
            WSPRErrorMessage *errorMessage = [WSPRErrorMessage message];
            errorMessage.error = error;
            [self handleMessage:errorMessage];
        }
    }
    @finally
    {
    }
}

-(void)sendMessageWithJSONString:(NSString *)jsonString
{
    NSString *quoteEscapedString = [self escapedStringFromString:jsonString];
    
    if ([_delegate respondsToSelector:@selector(gateway:didOutputMessage:)])
    {
        [_delegate gateway:self didOutputMessage:quoteEscapedString];
    }
}

#pragma mark - Utilities

-(NSString *)escapedStringFromString:(NSString *)string
{
    NSString *s = [string copy];
    s = [s stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]; //First: Escape all backslashes
    s = [s stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"]; //Escape single quotations
    return s;
}

static NSInteger requestCount;
+(NSString *)uniqueRequestString
{
    requestCount ++;
    return [NSString stringWithFormat:@"%@%ld", WISPER_REQUEST_PREFIX, (long)requestCount];
}


@end
