//
//  WSPRRequest.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 26/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRRequest.h"

@implementation WSPRRequest

-(id)copyWithZone:(NSZone *)zone
{
    WSPRRequest *newRequest = [super copyWithZone:zone];
    newRequest.requestIdentifier = [_requestIdentifier copyWithZone:zone];
    newRequest.responseBlock = [_responseBlock copyWithZone:zone];
    return newRequest;
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

-(NSDictionary *)asDictionary
{
    return @{
             @"id" : self.requestIdentifier ? : @"",
             @"method" : self.method ? : @"",
             @"params" : self.params ? : @[]
             };
}

-(WSPRResponse *)createResponse
{
    WSPRResponse *response = [[WSPRResponse alloc] init];
    response.requestIdentifier = self.requestIdentifier;
    return response;
}

@end
