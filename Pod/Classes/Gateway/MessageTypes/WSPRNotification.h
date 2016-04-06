//
//  WSPRNotification.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 27/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRMessage.h"

/**
 Representation of a notification (a message that does not require any response) to be or that has been sent over the RPC bridge using the WSPRGateway.
 @see WSPRGateway
 */
@interface WSPRNotification : WSPRMessage

/**
 The method we want to send a notification to. In the case of WSPRRemoteObjectController the method is separated into different components like namespace, class and method.
 */
@property (nonatomic, strong) NSString *method;

/**
 The params passed together with this notification, could be progress information or events.
 */
@property (nonatomic, strong) NSArray *params;

+(instancetype)notificationWithMethod:(NSString *)method andParams:(NSArray *)params;
-(instancetype)initWithMethod:(NSString *)method andParams:(NSArray *)params;

@end
