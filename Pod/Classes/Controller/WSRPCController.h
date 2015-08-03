//
//  RPCController.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 25/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSRPCRequest.h"
#import "WSRPCNotification.h"

#define RPCMessageEndPoint @"wisp.rpc.message"
#define RPCURLScheme @"RPC"

@class WSRPCController;


typedef enum {
    WSRPCErrorTypeInternal,
    WSRPCErrorTypeParseError,
    WSRPCErrorTypeFormatError,
}WSRPCErrorType;


/**
 Delegate protocol for handling the different RPC messages coming from the other endpoint.
 */
@protocol WSRPCControllerDelegate <NSObject>
@optional

/*
 Primitive way to receive request
 */

/**
 Handle incoming requests in JSON > NSDictionary format, a request always requires a response/error to be sent with the same request ID.
 @param rpcController The RPCController that received the request.
 @param request NSDictionary repesentation of the JSON request.
 @discussion This might be good for low level implementations but there are better alternatives in this protocol like the -rpcController:didReceiveNotification:.
 @see -rpcController:didReceiveNotification:
 */
-(void)rpcController:(WSRPCController *)rpcController didReceiveDictionaryRequest:(NSDictionary *)request;

/**
 Handle incoming notifications in JSON > NSDictionary format, a notification never returns a response.
 @param rpcController The RPCController that received the notification.
 @param notification NSDictionary repesentation of the JSON notification.
 @discussion This might be good for low level implementations but there are better alternatives in this protocol like the -rpcController:didReceiveRequest: which has a response block already defined for you to respond with.
 @see -rpcController:didReceiveRequest:
 */
-(void)rpcController:(WSRPCController *)rpcController didReceiveDictionaryNotification:(NSDictionary *)notification;

/**
 Handle incoming reponses in JSON > NSDictionary format, a response is received after making a request, the response will have the same id specified as the request so we can keep track on what the response is for.
 @param rpcController The RPCController that received the response.
 @param response NSDictionary repesentation of the JSON response.
 */
-(void)rpcController:(WSRPCController *)rpcController didReceiveDictionaryResponse:(NSDictionary *)response;

/**
 Handle incoming errors in JSON > NSDictionary format, an error can be received after making a request instead of a response, the error will have the same id specified as the request so we can keep track on what the error is for.
 @param rpcController The RPCController that received the error.
 @param error NSDictionary repesentation of the JSON error.
 */
-(void)rpcController:(WSRPCController *)rpcController didReceiveDictionaryError:(NSDictionary *)error;


/*
 Object RPC receive request
 */

/**
 Handle incoming parsed requests by interacting with the passed WSRPCRequest. This object has a ^responseBlock where you can pass a WSRPCResponse object and it will automatically be sent back.
 @param rpcController The RPCController that received the request.
 @param request WSRPCRequest repesentation of the parsed request.
 @see WSRPCRequest
 @see WSRPCResponse
 */
-(void)rpcController:(WSRPCController *)rpcController didReceiveRequest:(WSRPCRequest *)request;

/**
 Handle incoming parsed notifications with the passed WSRPCNotification.
 @param rpcController The RPCController that received the notification.
 @param notification WSRPCNotification repesentation of the parsed notification.
 @see WSRPCNotification
 */
-(void)rpcController:(WSRPCController *)rpcController didReceiveNotification:(WSRPCNotification *)notification;

/**
 Handle incoming parsed error.
 @param rpcController The RPCController that received the notification.
 @param error WSRPCError representation of the parsed error.
 */
-(void)rpcController:(WSRPCController *)rpcController didReceiveRPCError:(WSRPCError *)error;

/*
 Generated outgoing message
 */
-(void)rpcController:(WSRPCController *)rpcController didGenerateOutgoingEscapedMessage:(NSString *)message;

@end


/**
 This is the receiving end point for RPC messages coming from a UIWebview end point. The controller will handle the incoming object and parse it to a model object that is easier to interact with. This class is created with subclassing in mind.
 */
@interface WSRPCController : NSObject

/**
 The delegate that implements one of the optional methods found in WSRPCControllerDelegate. The delegate will be invoked with parsed objects whenever we receive a message.
 */
@property (nonatomic, assign) id<WSRPCControllerDelegate> delegate;


/**
 Method for creating a new uniqe request string so that we always get a new request id.
 */
+(NSString *)uniqueRequestString;

/**
 Handle an incoming RPC message string.
 @param message The RPC message string.
 */
-(void)handleMessage:(NSString *)message;


/*
 Object RPC Call
 */

/**
 Request something from the other endpoint by passing a WSRPCRequest model object. The ^successBlock will be fired with the returned response instead of you having to handle it as a delegate.
 @param request The request we want to make towards the other endpoint.
 */
-(void)makeRequestWithRequest:(WSRPCRequest *)request;

/**
 Notify the other endpoint about something.
 @param notification The notification we want to send to the other endpoint.
 */
-(void)makeNotificationWithNotification:(WSRPCNotification *)notification;

/**
 Make a response for some request that you have handled manually instead of using the ^successBlock of the WSRPCRequest.
 @param response The response we want to send to the other endpoint. You can add an WSRPCError to the response if something went wrong.
 @see WSRPCRequest check out the responseBlock^ as a replacement for using this method directly.
 @see WSRPCError
 */
-(void)makeResponseWithResponse:(WSRPCResponse *)response;



/*
 Primitive ways of calling RPC
 */

/**
 A more primitive way of calling the other endpoint using just a dictionary. The call could be any type of message, request, response, notification, error or whatever.
 @param dictionary The carrier of the message to be sent to the other end point.
 */
-(void)makeRPCCallWithDictionary:(NSDictionary *)dictionary;

/**
 The lowest level of sending messages to the other endpoint. It does not get more low level then this in our RPCController. You can pass any string here but for it to be accepted by the other endpoint it has to be JSON formatted and contain proper keys and values.
 @param jsonString The carrier of the message to be sent to the other end point.
 */
-(void)makeRPCCallWithJSONString:(NSString *)jsonString;



/*
 Methods for subclassing
 Remember to call super in your overridden methods
 */

//Incoming requests

/**
 Called by the RPC Controller when a message has been received, parsed to a dictionary and identified as a request.
 @param request NSDictionary repesentation of the JSON request.
 @discussion Could be overridden in subclass, remember to call super to not break the functionality of this class.
 */
-(void)handleRequestWithDictionary:(NSDictionary *)request;

/**
 Called by the RPC Controller when a message has been received, parsed to a dictionary and identified as a notification.
 @param notification NSDictionary repesentation of the JSON notification.
 @discussion Could be overridden in subclass, remember to call super to not break the functionality of this class.
 */
-(void)handleNotificationWithDictionary:(NSDictionary *)notification;

/**
 Called by the RPC Controller from the -handleRequestWithDictionary: perfect point for subclassing and doing something useful with the WSRPCRequest.
 @param request WSRPCRequest repesentation of the NSDictionary request.
 @discussion Perfect for overriding in subclass, remember to call super to not break the functionality of this class.
 */
-(void)handleRequest:(WSRPCRequest *)request;

/**
 Called by the RPC Controller from the -handleNotificationWithDictionary: perfect point for subclassing and doing something useful with the WSRPCNotification.
 @param notification WSRPCNotification repesentation of the NSDictionary notification.
 @discussion Perfect for overriding in subclass, remember to call super to not break the functionality of this class.
 */
-(void)handleNotification:(WSRPCNotification *)notification;


//Incoming response

/**
 Called by the RPC Controller when a message has been received, parsed to a dictionary and identified as a response.
 @param response NSDictionary repesentation of the JSON response.
 @discussion Could be overridden in subclass, remember to call super to not break the functionality of this class.
 */
-(void)handleResponseWithDictionary:(NSDictionary *)response;

/**
 Called by the RPC Controller when a message has been received, parsed to a dictionary and identified as an error.
 @param error NSDictionary repesentation of the JSON error.
 @discussion Could be overridden in subclass, remember to call super to not break the functionality of this class.
 */
-(void)handleErrorWithDictionary:(NSDictionary *)error;


@end