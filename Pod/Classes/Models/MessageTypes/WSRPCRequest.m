//
//  WSRPCRequest.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 26/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSRPCRequest.h"

@implementation WSRPCRequest

+(id)request
{
    return [WSRPCRequest requestWithDictionary:nil];
}

+(id)requestWithDictionary:(NSDictionary *)dictionary
{
    return [[WSRPCRequest alloc] initWithDictionary:dictionary];
}

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if (self)
    {
        self.requestIdentifier = dictionary[@"id"];
        //Method and params handled in super class
    }
    return self;
}

-(NSString *)description
{
    return [[self asDictionary] description];
}

-(NSDictionary *)asDictionary
{
    return @{
             @"id" : self.requestIdentifier ? : @"",
             @"method" : self.method ? : @"",
             @"params" : self.params ? : @[]
             };
}

-(NSString *)asJSONString
{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self asDictionary] options:0 error:nil] encoding:NSASCIIStringEncoding];
}

-(WSRPCResponse *)createResponse
{
    WSRPCResponse *response = [[WSRPCResponse alloc] init];
    response.requestIdentifier = self.requestIdentifier;
    return response;
}

@end
