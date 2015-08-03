//
//  WSRPCResponse.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 27/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSRPCResponse.h"

@implementation WSRPCResponse

+(id)response
{
    return [WSRPCResponse responseWithDictionary:nil];
}

+(id)responseWithDictionary:(NSDictionary *)dictionary
{
    return [[WSRPCResponse alloc] initWithDictionary:dictionary];
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
            self.error = [WSRPCError errorWithDictionary:dictionary[@"error"]];
        }
    }
    return self;
}

-(NSString *)description
{
    return [[self asDictionary] description];
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

-(NSString *)asJSONString
{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self asDictionary] options:0 error:nil] encoding:NSASCIIStringEncoding];
}

@end
