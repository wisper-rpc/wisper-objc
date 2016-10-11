//
//  WSPRExceptionHandler.m
//  Pods
//
//  Created by Patrik Nyblad on 02/03/16.
//
//

#import "WSPRExceptionHandler.h"
#import "WSPRGateway.h"
#import "WSPRException.h"

@implementation WSPRExceptionHandler

+(void)handleException:(NSException *)exception withMessage:(WSPRMessage *)message underGateway:(WSPRGateway *)gateway
{
    WSPRException *wisperException = nil;
    if (![exception isKindOfClass:[WSPRException class]])
    {
        wisperException = [WSPRException exceptionWithErrorDomain:WSPRErrorDomainiOS_OSX code:-1 originalException:exception andDescription:nil];
    }
    else
    {
        wisperException = (WSPRException *)exception;
    }
    
    if ([message isKindOfClass:[WSPRRequest class]])
    {
        WSPRRequest *request = (WSPRRequest *)message;
        WSPRResponse *response = [request createResponse];
        response.error = [wisperException wisperError];
        request.responseBlock(response);
    }
    else
    {
        WSPRErrorMessage *errorMessage = [[WSPRErrorMessage alloc] init];
        errorMessage.error = [wisperException wisperError];
        [gateway sendMessage:errorMessage];
    }
}

@end
