//
//  WSPRMessageFactory.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 05/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSPRRequest.h"
#import "WSPRResponse.h"
#import "WSPRNotification.h"
#import "WSPRErrorMessage.h"


typedef enum {
    WSPRGatewayMessageTypeRequest = 0,
    WSPRGatewayMessageTypeNotification,
    WSPRGatewayMessageTypeResponse,
    WSPRGatewayMessageTypeError,
    WSPRGatewayMessageTypeUndefined
} WSPRGatewayMessageType;


/**
 Creates different kinds of messages
 */
@interface WSPRMessageFactory : NSObject

/**
 Creates a message from the passed dictionary. The factory automatically figures out the message type.
 @param dictionary The data representing a Wisper message.
 @return A Wisper message subclass for the passed dictionary.
 */
+(WSPRMessage *)messageFromDictionary:(NSDictionary *)dictionary;

/**
 Get the message type from dictionary representing a wisper message
 */
+(WSPRGatewayMessageType)messageTypeFromMessageDictionary:(NSDictionary *)message;

/**
 Get the message type from message.
 */
+(WSPRGatewayMessageType)messageTypeFromMessage:(WSPRMessage *)message;

@end
