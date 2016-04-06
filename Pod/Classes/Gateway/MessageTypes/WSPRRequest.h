//
//  WSPRRequest.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 26/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRNotification.h"
#import "WSPRResponse.h"
#import "WSPRError.h"

/**
 Fired when response is ready, the response object is passed into the block.
 @see WSPRGateway
 */
typedef void (^ResponseBlock)(WSPRResponse *response);

/**
 Request object that you can either use yourself to request the other RPC endpoint or you will get this from the RPC controller when the other endpoint is asking you for something.
 @discussion The WSPRRequest is a subclass of WSPRNotification so check that object to see other available properties and methods.
 @see WSPRNotification
 */
@interface WSPRRequest : WSPRNotification

/**
 The id of this request used to identify what response is paired with what request. A response to this request must have the exact same requestIdentifier.
 */
@property (nonatomic, strong) NSString *requestIdentifier;

/**
 A block that can define what to do when we get a response. This block only takes one parameter that will be the response to this request in the form of a WSPRResponse object.
 @discussion If you created the request and sent it using the gateway you are responsible to assign a block to be executed to handle the result of your request. If the WSPRGateway gave you this request the responseBlock will already be set and you have to run it while passing a WSPRResponse object.
 */
@property (nonatomic, copy) ResponseBlock responseBlock;

/**
 Creates a response object for you to pass to the responseBlock if you are responding to a request. This response object will have the requestIdentifier already set correctly.
 */
-(WSPRResponse *)createResponse;

+(instancetype)requestWithMethod:(NSString *)method params:(NSString *)params requestIdentifier:(NSString *)requestIdentifier andResponseBlock:(ResponseBlock)responseBlock;
-(instancetype)initWithMethod:(NSString *)method params:(NSString *)params requestIdentifier:(NSString *)requestIdentifier andResponseBlock:(ResponseBlock)responseBlock;

@end
