//
//  WSRPCRemoteObjectCall.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 12/05/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSRPCRequest.h"

typedef enum {
    WSRPCCallTypeUnknown,
    WSRPCCallTypeCreate,
    WSRPCCallTypeDestroy,
    WSRPCCallTypeStatic,
    WSRPCCallTypeStaticEvent,
    WSRPCCallTypeInstance,
    WSRPCCallTypeInstanceEvent
} WSRPCCallType;

@interface WSRPCRemoteObjectCall : NSObject

/**
 Set a notification to read its properties using the readonly getters.
 */
@property (nonatomic, strong) WSRPCNotification *notification;

/**
 Set a request to read its properties using the readonly getters.
 */
@property (nonatomic, strong) WSRPCRequest *request;

/**
 Call type of the notifictation/request.
 */
@property (nonatomic, readonly) WSRPCCallType callType;

/**
 Parsed class name from the notification/request method ex. "wisp.ctrl.getEndAction" = "ctrl".
 */
@property (nonatomic, readonly) NSString *className;

/**
 Parsed method name from the notification/request method ex. "wisp.ctrl.getEndAction" = "getEndAction".
 */
@property (nonatomic, readonly) NSString *methodName;

/**
 The full method path from the request/notification.
 */
@property (nonatomic, readonly) NSString *fullMethod;

/**
 Gives you all components of the method ex. "wisp.ctrl.getEndAction" = ["wisp", "ctrl", "getEndAction"]
 ex. "wisp.ai.Awesome:test" = ["wisp", "ai", "Awesome", "test"]
 */
@property (nonatomic, readonly) NSArray *methodComponents;

/**
 Gives you all components of the method ex. "wisp.ctrl.getEndAction" = [".", "."]
 ex. "wisp.ai.Awesome:test" = [".", ".", ":"]
 */
@property (nonatomic, readonly) NSArray *methodComponentSeparators;

/**
 The pure params of the notification/request, will strip away the instance id so this is always safe to use.
 */
@property (nonatomic, readonly) NSArray *params;

/**
 The instance id of the remote object in question. Parsed from the first item of the params. 
 Use this to search in our instance map.
 */
@property (nonatomic, readonly) NSString *instanceId;

/**
 Initialize this model object with a notification.
 @param notification The notification to parse and handle.
 @return An instance of this model object.
 */
-(instancetype)initWithNotification:(WSRPCNotification *)notification;

/**
 Initialize this model object with a request.
 @param request The request to parse and handle.
 @return An instance of this model object.
 */
-(instancetype)initWithRequest:(WSRPCRequest *)request;

@end
