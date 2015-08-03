//
//  WSRPCNotification.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 27/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSRPCNotification.h"

@implementation WSRPCNotification

+(id)notification
{
    return [WSRPCNotification notificationWithDictionary:nil];
}

+(id)notificationWithDictionary:(NSDictionary *)dictionary
{
    return [[WSRPCNotification alloc] initWithDictionary:dictionary];
}

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self)
    {
        self.method = dictionary[@"method"];
        self.params = dictionary[@"params"];
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
             @"method" : self.method ? : @"",
             @"params" : self.params ? : @[]
             };
}

-(NSString *)asJSONString
{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self asDictionary] options:0 error:nil] encoding:NSUTF8StringEncoding];
}

@end
