//
//  WSRPCNotification.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 27/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Representation of a notification (a message that does not require any response) to be or that has been sent over the RPC bridge using the WSRPCController.
 @see WSRPCController
 */
@interface WSRPCNotification : NSObject


/**
 The method we want to send a notification to. In the case of WSRPCClassAndInstanceController the method is separated into different components like namespace, class and method.
 */
@property (nonatomic, strong) NSString *method;

/**
 The params passed together with this notification, could be progress information or events.
 */
@property (nonatomic, strong) NSArray *params;

/**
 Convenience method for creating a notification without calling alloc.
 */
+(id)notification;

/**
 Convenience method for creating a notification without calling alloc and also initializing it with a dictionary containing all properties you want to set.
 @param dictionary An NSDictionary containing keys and values for all properties you want to set.
 */
+(id)notificationWithDictionary:(NSDictionary *)dictionary;

/**
 Method for initializing the notification object with a dictionary.
 @param dictionary An NSDictionary containing keys and values for all properties you want to set.
 */
-(id)initWithDictionary:(NSDictionary *)dictionary;

/**
 Create a dictionary representation of this notification.
 */
-(NSDictionary *)asDictionary;

/**
 Create a JSON string representation of this notification.
 */
-(NSString *)asJSONString;

@end
