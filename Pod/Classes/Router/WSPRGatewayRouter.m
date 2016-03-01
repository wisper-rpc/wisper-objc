//
//  WSPRGatewayRouter.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 07/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRGatewayRouter.h"

@interface WSPRGatewayRouter ()

@property (nonatomic, strong) WSPRGateway *gateway;

@end

@implementation WSPRGatewayRouter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.gateway = [[WSPRGateway alloc] init];
        _gateway.delegate = self;
    }
    return self;
}

#pragma mark - WSPRRoute Protocol

-(void)reverse:(WSPRMessage *)message fromPath:(NSString *)path
{
    if ([message isKindOfClass:[WSPRNotification class]])
    {
        WSPRNotification *notification = (WSPRNotification *)message;
        NSCharacterSet *specialMarkers = [NSCharacterSet characterSetWithCharactersInString:@":!~"];
        NSRange specialMarkerRange = [notification.method rangeOfCharacterFromSet:specialMarkers];
        BOOL isSpecialMethod = specialMarkerRange.location == 0;

        [notification setMethod:[NSString stringWithFormat:@"%@%@%@", path, isSpecialMethod ? @"" : @".", [notification method]]];
    }
    
    [self.gateway sendMessage:message];
}

#pragma mark - WSPRGatewayDelegate

-(void)gateway:(WSPRGateway *)gateway didReceiveMessage:(WSPRMessage *)message
{
    if ([message isKindOfClass:[WSPRNotification class]])
    {
        [self route:message toPath:[(WSPRNotification *)message method]];
    }
}



@end
