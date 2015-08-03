//
//  WSRPCEvent.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 11/06/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSRPCNotification.h"

/**
 Model object representing an event to be sent or received.
 */
@interface WSRPCEvent : NSObject

/**
 The mapped name of the class that should handle/is sending the notification.
 */
@property (nonatomic, strong) NSString *mapName;

/**
 The event name.
 */
@property (nonatomic, strong) NSString *name;

/**
 The data for the event, this can be nil and must always be one of the allowed RPC_PARAM_TYPE(s).
 Setting data that is not allowed does nothing.
 */
@property (nonatomic, strong) id data;

/**
 If set the event will be routed to the specific instance. 
 If nil, event is interpreted as a static event.
 */
@property (nonatomic, strong) NSString *instanceIdentifier;


/**
 Create an event from a notification.
 @param notification The notification to create the event from.
 */
-(instancetype)initWithNotification:(WSRPCNotification *)notification;

/**
 Creates a notification object from this event.
 @return A notification representation of the event that can be sent off to some other end point.
 */
-(WSRPCNotification *)createNotification;


@end
