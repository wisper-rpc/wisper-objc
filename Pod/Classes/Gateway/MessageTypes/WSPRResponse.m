//
//  WSPRResponse.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 27/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRResponse.h"

@implementation WSPRResponse

-(id)copyWithZone:(NSZone *)zone
{
    WSPRResponse *newResponse = [super copyWithZone:zone];
    newResponse.requestIdentifier = [_requestIdentifier copyWithZone:zone];
    newResponse.result = _result; //Do not copy this since it might not conform to NSCopying protocol
    return newResponse;
}


-(id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self)
    {
        self.requestIdentifier = dictionary[@"id"];
        self.result = dictionary[@"result"];
        if (dictionary[@"error"])
        {
            self.error = [WSPRError errorWithDictionary:dictionary[@"error"]];
        }
    }
    return self;
}


-(NSDictionary *)asDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.requestIdentifier)
    {
        [dictionary setObject:self.requestIdentifier forKey:@"id"];
    }
    
    if (self.error)
    {
        [dictionary setObject:[self.error asDictionary] forKey:@"error"];
    }
    else
    {
        [dictionary setObject:self.result ? : [NSNull null] forKey:@"result"];
    }
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}


@end
