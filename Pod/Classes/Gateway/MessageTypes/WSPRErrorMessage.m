//
//  WSPRErrorMessage.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 06/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRErrorMessage.h"

@implementation WSPRErrorMessage

+(instancetype)errorMessageWithError:(WSPRError *)error
{
    return [[[self class] alloc] initWithError:error];
}

-(instancetype)initWithError:(WSPRError *)error
{
    self = [self init];
    if (self)
    {
        self.error = error;
    }
    return error;
}

-(id)copyWithZone:(NSZone *)zone
{
    WSPRErrorMessage *newError = [super copyWithZone:zone];
    newError.error = [_error copyWithZone:zone]; //Do not copy this since it might not conform to NSCopying protocol
    return newError;
}

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self)
    {
        if (dictionary[@"error"])
        {
            self.error = [WSPRError errorWithDictionary:dictionary[@"error"]];
        }
    }
    return self;
}

-(NSDictionary *)asDictionary
{
    return self.error ? @{@"error" : [self.error asDictionary]} : @{};
}

@end
