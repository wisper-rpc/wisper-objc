//
//  WSPRMessage.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 04/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRMessage.h"

@implementation WSPRMessage

+(instancetype)message
{
    return [self messageWithDictionary:nil];
}

+(instancetype)messageWithDictionary:(NSDictionary *)dictionary
{
    return [[self alloc] initWithDictionary:dictionary];
}

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self)
    {
    }
    return self;
}

-(NSString *)description
{
    return [[self asDictionary] description];
}

-(NSDictionary *)asDictionary
{
    return @{};
}

-(NSString *)asJSONString
{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self asDictionary] options:0 error:nil] encoding:NSUTF8StringEncoding];
}


@end
