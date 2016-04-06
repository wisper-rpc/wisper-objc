//
//  WSPRErrorMessage.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 06/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRMessage.h"
#import "WSPRError.h"

@interface WSPRErrorMessage : WSPRMessage

/**
 If error is set this response will be sent as an error message and the result will be ignored.
 */
@property (nonatomic, strong) WSPRError *error;

+(instancetype)errorMessageWithError:(WSPRError *)error;
-(instancetype)initWithError:(WSPRError *)error;

@end
