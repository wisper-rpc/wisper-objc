//
//  WSPRNotification.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 27/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRNotification.h"

@implementation WSPRNotification

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

-(NSDictionary *)asDictionary
{
    return @{
             @"method" : self.method ? : @"",
             @"params" : self.params ? : @[]
             };
}


@end
