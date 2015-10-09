//
//  WSPRErrorMessage.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 06/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRErrorMessage.h"

@implementation WSPRErrorMessage

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
