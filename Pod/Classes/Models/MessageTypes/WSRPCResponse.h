//
//  WSRPCResponse.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 27/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSRPCError.h"

/**
 When an instance handling a WSRPCRequest has finished doing its work it should generate an instance of this object and fill it with the results. This object is then passed to the other endpoint either through the WSRPCRequest's responseBlock or through the RPCController.
 @see WSRPCController
 */
@interface WSRPCResponse : NSObject

/**
 Contains the id of the request we are responding to. If you are responding to a request you set this manually to the same as the WSRPCRequest object's requestIdentfier. If the WSRPCResponse was created from the -createResponse method of the WSRPCRequest this will be set automatically.
 */
@property (nonatomic, strong) NSString *requestIdentifier;

/**
 Contains the result of the response.
 */
@property (nonatomic, strong) NSObject *result;

/**
 If error is set this response will be sent as an error message and the result will be ignored.
 */
@property (nonatomic, strong) WSRPCError *error;

/**
 Convenience method for creating a response without calling alloc.
 */
+(id)response;

/**
 Convenience method for creating a response without calling alloc and also initializing it with a dictionary containing all properties you want to set.
 @param dictionary An NSDictionary containing keys and values for all properties you want to set.
 */
+(id)responseWithDictionary:(NSDictionary *)dictionary;

/**
 Initialize with a provided dictionary.
 @param dictionary An NSDictionary containing keys and values for all properties you want to set.
 */
-(id)initWithDictionary:(NSDictionary *)dictionary;

/**
 Create a dictionary representation of this response.
 */
-(NSDictionary *)asDictionary;

/**
 Create a JSON string representation of this response.
 */
-(NSString *)asJSONString;


@end
