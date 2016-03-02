//
//  WSPRExceptionHandler.h
//  Pods
//
//  Created by Patrik Nyblad on 02/03/16.
//
//

#import <Foundation/Foundation.h>
#import "WSPRException.h"

@class WSPRGateway;
@class WSPRMessage;

@interface WSPRExceptionHandler : NSObject

+(void)handleException:(NSException *)exception withMessage:(WSPRMessage *)message underGateway:(WSPRGateway *)gateway;

@end
