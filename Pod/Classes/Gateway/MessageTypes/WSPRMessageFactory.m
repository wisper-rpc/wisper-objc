//
//  WSPRMessageFactory.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 05/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRMessageFactory.h"

@implementation WSPRMessageFactory

+(WSPRMessage *)messageFromDictionary:(NSDictionary *)dictionary
{
    if (!dictionary)
        return nil;
    
    WSPRGatewayMessageType type = [self messageTypeFromMessageDictionary:dictionary];
    switch (type)
    {
        case WSPRGatewayMessageTypeRequest:
            return [WSPRRequest messageWithDictionary:dictionary];
            break;
        case WSPRGatewayMessageTypeNotification:
            return [WSPRNotification messageWithDictionary:dictionary];
            break;
        case WSPRGatewayMessageTypeResponse:
            return [WSPRResponse messageWithDictionary:dictionary];
            break;
        case WSPRGatewayMessageTypeError:
            return [WSPRErrorMessage messageWithDictionary:dictionary];
            break;
        default:
            return nil;
            break;
    }
}

+(WSPRGatewayMessageType)messageTypeFromMessageDictionary:(NSDictionary *)message
{
    if (!message)
        return WSPRGatewayMessageTypeUndefined;
    
    if ([message[@"method"] isKindOfClass:[NSString class]] && [message[@"params"] isKindOfClass:[NSArray class]])
    {
        if (!message[@"id"])
        {
            return WSPRGatewayMessageTypeNotification;
        }
        else if([message[@"id"] isKindOfClass:[NSString class]])
        {
            return WSPRGatewayMessageTypeRequest;
        }
    }
    
    if ((message[@"result"] || message[@"error"]) && [message[@"id"] isKindOfClass:[NSString class]])
    {
        return WSPRGatewayMessageTypeResponse;
    }
    
    if (message[@"error"])
    {
        return WSPRGatewayMessageTypeError;
    }
    
    return WSPRGatewayMessageTypeUndefined;
}

+(WSPRGatewayMessageType)messageTypeFromMessage:(WSPRMessage *)message
{
    if ([message isKindOfClass:[WSPRRequest class]])
        return WSPRGatewayMessageTypeRequest;
    
    if ([message isKindOfClass:[WSPRNotification class]])
        return WSPRGatewayMessageTypeNotification;
    
    if ([message isKindOfClass:[WSPRResponse class]])
        return WSPRGatewayMessageTypeResponse;
    
    if ([message isKindOfClass:[WSPRErrorMessage class]])
        return WSPRGatewayMessageTypeError;
    
    return WSPRGatewayMessageTypeUndefined;
}


@end
