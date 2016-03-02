//
//  WSPRException.m
//  Pods
//
//  Created by Patrik Nyblad on 01/03/16.
//
//

#import "WSPRException.h"

@implementation WSPRException

+(instancetype)exceptionWithErrorDomain:(WSPRErrorDomain)domain code:(NSInteger)code originalException:(NSException *)exception andDescription:(NSString *)description
{
    return [[[self class] alloc] initWithErrorDomain:domain code:code originalException:exception andDescription:description];
}

- (instancetype)initWithErrorDomain:(WSPRErrorDomain)domain code:(NSInteger)code originalException:(NSException *)exception andDescription:(NSString *)description
{
    self = [super initWithName:[WSPRError domainNameFromDomain:domain] reason:description userInfo:nil];
    if (self)
    {
        self.domain = domain;
        self.code = code;
        self.originalException = exception;
    }
    return self;
}

-(WSPRError *)wisperError
{
    WSPRError *error = [WSPRError errorWithDomain:self.domain andCode:self.code];
    error.message = [self reason];
    error.data = [self userInfo];
    return error;
}

@end
