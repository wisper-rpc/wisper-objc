//
//  WSPRGatewayRouter.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 07/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRRouter.h"

/**
 *  The Gateway router receives its messages from an internal WSPRGateway instance. 
 *  Reverse messages are sent out through the Gateway.
 */
@interface WSPRGatewayRouter : WSPRRouter <WSPRGatewayDelegate>

/**
 *  The delegate of this class that should receive the outputted wisper messages.
 */
@property (nonatomic, assign) id<WSPRGatewayDelegate> delegate;

/**
 *  The transceiving gateway that all messages are routed to and from. 
 */
@property (nonatomic, readonly) WSPRGateway *gateway;

@end
