//
//  RPCProxy.h
//  SDK5Test
//
//  Created by Patrik Nyblad on 10/02/15.
//  Copyright (c) 2015 Widespace AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSRPCRemoteObjectController;
@class WSRPCRequest;
@class WSRPCNotification;

/**
 An RPC Proxy catches messages in one WSRPCRemoteObjectController under a specific map name and sends those messages to an other WSRPCRemoteObjectController. This way we can expose resources across different WSRPCRemoteObjectControllers.
 */
@interface WSRPCProxy : NSObject

/**
 The object to forward the RPC call to.
 Do not retain this object!
 */
@property (nonatomic, weak) WSRPCRemoteObjectController *receiver;

/**
 The controller that this Proxy is attached to.
 */
@property (nonatomic, weak) WSRPCRemoteObjectController *controller;

/**
 Optional 
 Proxy sitting on the receiver for transfering messages to this proxys controller. When one of these proxys are removed the other one will also be removed.
 */
@property (nonatomic, weak) WSRPCProxy *reverseProxy;

/**
 The name of the resource we want to proxy that is available in the receiver.
 */
@property (nonatomic, strong) NSString *receiverMapName;

/**
 The name that this proxy listens to when registerer with an RPCController.
 */
@property (nonatomic, strong) NSString *mapName;

/**
 Takes a request, transforms it and passes it on to the receiver.
 @param request The request that is trying to reach the other controller
 */
-(void)handleRequest:(WSRPCRequest *)request;

/**
 Takes a notification, transforms it and passes it on to the receiver.
 @param notification The notification that is trying to reach the other controller
 */
-(void)handleNotification:(WSRPCNotification *)notification;

/**
 
 */
-(void)setupReverseProxy;

/**
 Removes the reverese proxy for this proxy. Which means that communication to this proxy can still be channeled through to the receiver and the receiver can respond to a specific request but the receiver cannot send new messages back to this rpc controller any more.
 */
-(void)removeReverseProxy;

@end
