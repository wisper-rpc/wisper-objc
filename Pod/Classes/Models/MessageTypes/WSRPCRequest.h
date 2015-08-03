//
//  WSRPCRequest.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 26/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSRPCNotification.h"
#import "WSRPCResponse.h"
#import "WSRPCError.h"

/**
 Fired when response is ready, the response object is passed into the block.
 @see WSRPCController
 */
typedef void (^ResponseBlock)(WSRPCResponse *response);

/**
 Request object that you can either use yourself to request the other RPC endpoint or you will get this from the RPC controller when the other endpoint is asking you for something.
 @discussion The WSRPCRequest is a subclass of WSRPCNotification so check that object to see other available properties and methods.
 @see WSRPCNotification
 */
@interface WSRPCRequest : WSRPCNotification

/**
 The id of this request used to identify what response is paired with what request. A response to this request must have the exact same requestIdentifier.
 */
@property (nonatomic, strong) NSString *requestIdentifier;

/**
 A block that can define what to do when we get a response. This block only takes one parameter that will be the response to this request in the form of a WSRPCResponse object.
 @discussion If you created the request and sent it using the controller you assign a block with what to do with the result of the request. If the RPCController gave you this request the responseBlock will already be set and you have to run it while passing a WSRPCResponse object.
 */
@property (nonatomic, copy) ResponseBlock responseBlock;

/**
 Convenience method for creating a request without calling alloc.
 */
+(id)request;

/**
 Convenience method for creating a request without calling alloc and also initializing it with a dictionary containing all properties you want to set.
 @param dictionary An NSDictionary containing keys and values for all properties you want to set.
 */
+(id)requestWithDictionary:(NSDictionary *)dictionary;

/**
 Creates a response object for you to pass to the responseBlock if you are responding to a request. This response object will have the requestIdentifier already set correctly.
 */
-(WSRPCResponse *)createResponse;

@end
