//
//  WSPRResponse.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 27/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRErrorMessage.h"

/**
 When an instance handling a WSPRRequest has finished doing its work it should generate an instance of this object and fill it with the results. This object is then passed to the other endpoint either through the WSPRRequest's responseBlock or through the Gateway.
 @see WSPRGateway
 */
@interface WSPRResponse : WSPRErrorMessage

/**
 Contains the id of the request we are responding to. If you are responding to a request you set this manually to the same as the WSPRRequest object's requestIdentfier. If the WSPRResponse was created from the -createResponse method of the WSPRRequest this will be set automatically.
 */
@property (nonatomic, strong) NSString *requestIdentifier;

/**
 Contains the result of the response.
 */
@property (nonatomic, strong) NSObject *result;


@end
