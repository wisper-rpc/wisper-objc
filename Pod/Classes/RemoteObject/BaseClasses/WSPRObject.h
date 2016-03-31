//
//  WSPRObject.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 20/03/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSPRClassInstance.h"
#import "WSPRRequest.h"
#import "WSPRClassRouter.h"

/**
 Object intended for subclassing. This object will give a boiler plate functionality for RPC which can be overridden for each subclass.
 */
@interface WSPRObject : NSObject <WSPRClassProtocol>

/**
 Fetch the WSPRClassInstance registered for this class instance.
 @discussion In reality this is retrieved from the RPCController.
 */
@property (nonatomic, weak, readonly) WSPRClassInstance *rpcClassInstance;

/**
 Send an event to the other end point, the event can be sent to an instance or the whole class. The event has a mandatory name and an optional data property.
 @param event The event we want to send.
 @see -rpcCreateEventNotification
 */
-(void)rpcSendEvent:(WSPREvent *)event;

/**
 Create a notification already prefilled with the correct method for this class and instance event.
 If rpcController is not set this method will return nil.
 @see WSPRClassProtocol
 */
-(WSPREvent *)rpcCreateInstanceEvent;

/**
 Create a notification already prefilled with the correct method for this class event.
 If rpcController is not set this method will return nil.
 @see WSPRClassProtocol
 */
-(WSPREvent *)rpcCreateStaticEvent;

@end
