//
//  WSPRGateway.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 25/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSPRMessageFactory.h"

@class WSPRGateway;

/**
 Delegate protocol for handling the different Wisper messages coming from the other endpoint.
 */
@protocol WSPRGatewayDelegate <NSObject>
@optional

/*
 Generated outgoing message from whatever request/response/notification you ran through this gateway.
 @param message The message as a JSON string to be sent to some other Wisper Gateway.
 */
-(void)gateway:(WSPRGateway *)gateway didOutputMessage:(NSString *)message;

/**
 An incoming message was parsed
 @param gateway The WSPRGateway that received the message.
 @param message WSPRMessage repesentation of the parsed message.
 */
-(void)gateway:(WSPRGateway *)gateway didReceiveMessage:(WSPRMessage *)message;

@end


/**
 This is the receiving end point for RPC messages coming from a UIWebview end point. The controller will handle the incoming object and parse it to a model object that is easier to interact with. This class is created with subclassing in mind.
 */
@interface WSPRGateway : NSObject

/**
 The delegate that implements one of the optional methods found in WSPRGatewayDelegate. The delegate will be invoked with parsed objects whenever we receive a message.
 */
@property (nonatomic, assign) id<WSPRGatewayDelegate> delegate;

/**
 Handle an incoming Wisper message.
 @param message The Wisper message.
 */
-(void)handleMessage:(WSPRMessage *)message;

/**
 Handle an incoming Wisper message string.
 @param jsonString The Wisper message string.
 */
-(void)handleMessageAsJSONString:(NSString *)jsonString;

/**
 Sends any message subclass to the other endpoint.
 @param message The message subclass to send.
 */
-(void)sendMessage:(WSPRMessage *)message;

/**
 The lowest level of sending messages to the other endpoint. It does not get more low level then this in our WSPRGateway. You can pass any string here but for it to be accepted by the other endpoint it has to be JSON formatted and contain proper keys and values.
 @param jsonString The carrier of the message to be sent to the other end point.
 */
-(void)sendMessageWithJSONString:(NSString *)jsonString;

@end
