//
//  WSRPCRemoteObjectCall.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 12/05/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSRPCRemoteObjectCall.h"
#import "WSRPCHelper.h"

@implementation WSRPCRemoteObjectCall

-(instancetype)initWithNotification:(WSRPCNotification *)notification
{
    self = [self init];
    if (self)
    {
        self.notification = notification;
    }
    return self;
}
-(instancetype)initWithRequest:(WSRPCRequest *)request
{
    self = [self init];
    if (self)
    {
        self.request = request;
    }
    return self;
}

#pragma mark - Setters and Getters

-(WSRPCCallType)callType
{
    return [WSRPCHelper callTypeFromMethodString:[self fullMethod]];
}

-(NSString *)instanceId
{
    switch ([self callType]) {
        case WSRPCCallTypeCreate:
        case WSRPCCallTypeUnknown:
        case WSRPCCallTypeStatic:
        case WSRPCCallTypeStaticEvent:
            return nil;
            break;
        default:
            break;
    }
    
    NSArray *params = self.request ? self.request.params : self.notification.params;
    
    if (params && params.count)
    {
        return [params firstObject];
    }
    return nil;
}


-(NSArray *)params
{
    NSArray *params = self.request ? self.request.params : self.notification.params;
    
    if (params.count > 0)
    {
        switch ([self callType])
        {
            case WSRPCCallTypeInstance:
            case WSRPCCallTypeInstanceEvent:
            case WSRPCCallTypeDestroy:
                return [params subarrayWithRange:NSMakeRange(1, params.count-1)];
            default:
                break;
        }
    }
    return params;
}

-(NSString *)className
{
    return [WSRPCHelper classNameFromMethodString:[self fullMethod]];
}

-(NSString *)methodName
{
    return [WSRPCHelper methodNameFromMethodString:[self fullMethod]];
}

-(NSArray *)methodComponents
{
    return [WSRPCHelper methodComponentsFromMethodString:[self fullMethod]];
}

-(NSArray *)methodComponentSeparators
{
    return [WSRPCHelper methodComponentSeparatorsFromMethodString:[self fullMethod]];
}

-(NSString *)fullMethod
{
    if (self.notification)
    {
        return self.notification.method;
    }
    if (self.request)
    {
        return self.request.method;
    }
    return nil;
}

-(NSString *)description
{
    return _request ? [_request description] : _notification ? [_notification description] : [super description];
}



@end
