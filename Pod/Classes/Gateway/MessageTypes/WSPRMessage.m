//
//  WSPRMessage.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 04/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRMessage.h"
#import "WSPRHelper.h"

@implementation WSPRMessage

-(id)copyWithZone:(NSZone *)zone
{
    return [[self class] allocWithZone:zone];
}

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
    __block NSString *json = nil;

    // Completion is called synchronously, safe!
    [WSPRHelper jsonStringFromObject:[self asDictionary] completion:^(NSString *jsonString, NSError *error) {
        json = jsonString;        
    }];
    
    return json;
}


@end
