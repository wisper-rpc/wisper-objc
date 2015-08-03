//
//  RPCController.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 25/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//



/*
 Examples
 
 OBJECTIVE C
 [RPC call: @"getX" withParams: @[@"nisse"]]
 
 
 JS
 rpc.exposeProcMap({
 'getGeolocation': function () {
 return geolocationModule.rpc("geolocation", "nisse");
 }
 })
 JS
 rpc.rpc("wai.Video").then(...)
 
 */


#import "WSRPCController.h"

#define WSRPC_REQUEST_PREFIX @"IOS_SDK_REQ-"

typedef enum {
    WSRPCControllerRequestTypeRequest = 0,
    WSRPCControllerRequestTypeNotification,
    WSRPCControllerRequestTypeResult,
    WSRPCControllerRequestTypeError,
    WSRPCControllerRequestTypeUndefined
} WSRPCControllerRequestType;

@interface WSRPCController ()

//TODO - Wait for isReady before sending off requests and notifications
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, strong) NSMutableDictionary *requests;

@end

@implementation WSRPCController

static NSInteger requestCount;

+(NSString *)uniqueRequestString
{
    requestCount ++;
    return [NSString stringWithFormat:@"%@%ld", WSRPC_REQUEST_PREFIX, (long)requestCount];
}

-(id)init
{
    self = [super init];
    if (self)
    {
        self.requests = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)handleMessage:(NSString *)message
{
    NSError *error = nil;
    id object =  [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    
    if (error && !object)
    {
        //We were supposed to handle the request but the JSON was malformatted
        WSRPCError *rpcError = [[WSRPCError alloc] initWithDomain:WSRPCErrorDomainRPC andCode:WSRPCErrorRPCParseError];
        rpcError.message = [error localizedDescription];
        
        WSRPCResponse *response = [[WSRPCResponse alloc] init];
        response.error = rpcError;
        
        //Try to manually parse some sort of ID from the JSON string and return the error to the sender as a response.
        NSRange idRange = [message rangeOfString:@"id"];
        if (idRange.location != NSNotFound)
        {
            //Get just the id part
            NSString *idString = [message substringFromIndex:idRange.location];
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
        [self makeResponseWithResponse:response];
        return;
    }
    
    WSRPCControllerRequestType type = [self getRequestTypeFromRPCObject:object];
    
    switch (type)
    {
        case WSRPCControllerRequestTypeRequest:
            [self handleRequestWithDictionary:object];
            break;
        case WSRPCControllerRequestTypeNotification:
            [self handleNotificationWithDictionary:object];
            break;
        case WSRPCControllerRequestTypeResult:
            [self handleResponseWithDictionary:object];
            break;
        case WSRPCControllerRequestTypeError:
            [self handleErrorWithDictionary:object];
            break;
        default:
        {
            WSRPCError *rpcError = [[WSRPCError alloc] initWithDomain:WSRPCErrorDomainRPC andCode:WSRPCErrorRPCFormatError];
            rpcError.message = [NSString stringWithFormat:@"Could not parse message type from message: %@", message];
            
            WSRPCResponse *response = [[WSRPCResponse alloc] init];
            response.error = rpcError;
            if (object[@"id"])
            {
                response.requestIdentifier = object[@"id"];
            }
            [self makeResponseWithResponse:response];
        }
            break;
    }
}

#pragma mark - RPC handle call

//Incoming request

-(void)handleRequestWithDictionary:(NSDictionary *)request
{
    WSRPCRequest *incomingRequest = [WSRPCRequest requestWithDictionary:request];
    __weak WSRPCRequest *weakIncomingRequest = incomingRequest;
    __weak WSRPCController *weakSelf = self;
    incomingRequest.responseBlock = ^(WSRPCResponse *response)
    {
        //Retain self so that we don't let go of the reference in the middle of execution.
        __strong WSRPCController *strongSelf = weakSelf;
        __strong WSRPCRequest *strongIncomingRequest = weakIncomingRequest;
        [strongSelf makeResponseWithResponse:response];
        
        //Assign an empty block as soon as this request has been answered by a response so that a second response cannot be sent.
        strongIncomingRequest.responseBlock = ^(WSRPCResponse *response){};
    };
    [self handleRequest:incomingRequest];
    
    
    if ([self.delegate respondsToSelector:@selector(rpcController:didReceiveDictionaryRequest:)])
    {
        [self.delegate rpcController:self didReceiveDictionaryRequest:request];
    }
}

-(void)handleRequest:(WSRPCRequest *)request
{
    if ([self.delegate respondsToSelector:@selector(rpcController:didReceiveRequest:)])
    {
        [self.delegate rpcController:self didReceiveRequest:request];
    }
}

-(void)handleNotificationWithDictionary:(NSDictionary *)notification
{
    WSRPCNotification *incomingNotification = [WSRPCNotification notificationWithDictionary:notification];
    [self handleNotification:incomingNotification];
    
    if ([self.delegate respondsToSelector:@selector(rpcController:didReceiveDictionaryNotification:)])
    {
        [self.delegate rpcController:self didReceiveDictionaryNotification:notification];
    }
}

-(void)handleNotification:(WSRPCNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(rpcController:didReceiveNotification:)])
    {
        [self.delegate rpcController:self didReceiveNotification:notification];
    }
}

//Incoming response

-(void)handleResponseWithDictionary:(NSDictionary *)response
{
    //Run response through WSRPCRequest object if it invoked the request
    WSRPCRequest *theRequest = self.requests[response[@"id"]];
    if (theRequest)
    {
        //Remove request from waiting queue
        [self.requests removeObjectForKey:response[@"id"]];
        
        WSRPCResponse *theResponse = [WSRPCResponse responseWithDictionary:response];
        [self handleResponse:theResponse toRequest:theRequest];
    }
    
    //Always run response out to the delegate.
    if ([self.delegate respondsToSelector:@selector(rpcController:didReceiveDictionaryResponse:)])
    {
        [self.delegate rpcController:self didReceiveDictionaryResponse:response];
    }
}

-(void)handleResponse:(WSRPCResponse *)response toRequest:(WSRPCRequest *)request
{
    if (request.responseBlock)
    {
        request.responseBlock(response);
    }
    else if (response.error)
    {
        if ([self.delegate respondsToSelector:@selector(rpcController:didReceiveRPCError:)])
        {
            [self.delegate rpcController:self didReceiveRPCError:response.error];
        }
    }
}


-(void)handleErrorWithDictionary:(NSDictionary *)error
{
    //Run response through WSRPCRequest object if it invoked the request
    WSRPCRequest *theRequest = self.requests[error[@"id"]];
    if (theRequest)
    {
        //Remove request from waiting queue
        [self.requests removeObjectForKey:error[@"id"]];
        [self handleResponse:[WSRPCResponse responseWithDictionary:error] toRequest:theRequest];
    }
    
    if ([self.delegate respondsToSelector:@selector(rpcController:didReceiveDictionaryError:)])
    {
        [self.delegate rpcController:self didReceiveDictionaryError:error];
    }
}

#pragma mark - RPC make call

-(void)makeRequestWithRequest:(WSRPCRequest *)request
{
    //Add an identifier if one has not already been set
    if (!request.requestIdentifier)
    {
        request.requestIdentifier = [WSRPCController uniqueRequestString];
    }
    
    NSString *jsonString = nil;
    
    @try
    {
        jsonString = [request asJSONString];
    }
    @catch (NSException *exception)
    {
        WSRPCError *error = [WSRPCError errorWithDomain:WSRPCErrorDomainRPC andCode:WSRPCErrorRPCParseError];
        error.message = @"JSON Parser error";
        error.data = @{
                       @"exception" : @{
                               @"name" : exception.name,
                               @"reason" : exception.reason
                               }
                       };
        WSRPCResponse *response = [WSRPCResponse responseWithDictionary:@{@"error" : error}];
        response.requestIdentifier = request.requestIdentifier;
        request.responseBlock(response);
    }
    @finally
    {
    }
    
    //Parsing was OK?
    if (jsonString)
    {
        //Store the request so that we can run the response through the callback block when done
        self.requests[request.requestIdentifier] = request;

        //Make request
        [self makeRPCCallWithJSONString:jsonString];
    }
}

-(void)makeNotificationWithNotification:(WSRPCNotification *)notification
{
    NSString *jsonString = nil;

    @try
    {
        jsonString = [notification asJSONString];
        
        //Parsing was OK?
        if (jsonString)
        {
            //Make the Notification call
            [self makeRPCCallWithJSONString:jsonString];
        }
    }
    @catch (NSException *exception)
    {
        WSRPCError *error = [WSRPCError errorWithDomain:WSRPCErrorDomainRPC andCode:WSRPCErrorRPCParseError];
        error.message = @"JSON Parser error";
        error.data = @{
                       @"exception" : @{
                               @"name" : exception.name,
                               @"reason" : exception.reason
                               }
                       };
        WSRPCResponse *response = [WSRPCResponse responseWithDictionary:@{@"error" : error}];
        [self handleResponse:response toRequest:nil];
    }
    @finally
    {
    }
}

-(void)makeResponseWithResponse:(WSRPCResponse *)response
{
    NSString *jsonString = nil;
    
    @try
    {
        jsonString = [response asJSONString];
    }
    @catch (NSException *exception)
    {
        WSRPCError *error = [WSRPCError errorWithDomain:WSRPCErrorDomainRPC andCode:WSRPCErrorRPCParseError];
        error.message = @"JSON Parser error";
        error.data = @{
                       @"exception" : @{
                               @"name" : exception.name,
                               @"reason" : exception.reason
                               }
                       };
        WSRPCResponse *response = [WSRPCResponse responseWithDictionary:@{@"error" : error}];
        [self handleResponse:response toRequest:nil];
    }
    @finally
    {
    }
    
    //Parsing was OK?
    if (jsonString)
    {
        //Just convert the response to JSON and send it
        [self makeRPCCallWithJSONString:jsonString];
    }
}

-(void)makeRPCCallWithDictionary:(NSDictionary *)dictionary
{
    
    NSString *jsonString = nil;
    
    @try
    {
        jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil] encoding:NSASCIIStringEncoding];
    }
    @catch (NSException *exception)
    {
        WSRPCError *error = [WSRPCError errorWithDomain:WSRPCErrorDomainRPC andCode:WSRPCErrorRPCParseError];
        error.message = @"JSON Parser error";
        error.data = @{
                       @"exception" : @{
                               @"name" : exception.name,
                               @"reason" : exception.reason
                               }
                       };
        WSRPCResponse *response = [WSRPCResponse responseWithDictionary:@{@"error" : error}];
        [self handleResponse:response toRequest:nil];
    }
    @finally
    {
    }
    
    //Parsing was OK?
    if (jsonString)
    {
        //Just convert the response to JSON and send it
        [self makeRPCCallWithJSONString:jsonString];
    }
}

-(void)makeRPCCallWithJSONString:(NSString *)jsonString
{
    NSString *quoteEscapedString = [self escapedStringFromString:jsonString];
    
    if ([_delegate respondsToSelector:@selector(rpcController:didGenerateOutgoingEscapedMessage:)])
    {
        [_delegate rpcController:self didGenerateOutgoingEscapedMessage:quoteEscapedString];
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

-(WSRPCControllerRequestType)getRequestTypeFromRPCObject:(id)rpc
{
    if ([rpc isKindOfClass:[NSDictionary class]])
    {
        if (rpc[@"method"] && rpc[@"params"])
        {
            if (rpc[@"id"])
            {
                return WSRPCControllerRequestTypeRequest;
            }
            else
            {
                return WSRPCControllerRequestTypeNotification;
            }
        }
        
        if (rpc[@"result"] && rpc[@"id"])
        {
            return WSRPCControllerRequestTypeResult;
        }
        
        if (rpc[@"error"])
        {
            return WSRPCControllerRequestTypeError;
        }
    }
    
    return WSRPCControllerRequestTypeUndefined;
}



@end
