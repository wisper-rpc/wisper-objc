//
//  WSPRRemoteObjectCall.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 12/05/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRRemoteObjectCall.h"
#import "WSPRHelper.h"

@implementation WSPRRemoteObjectCall

-(instancetype)initWithNotification:(WSPRNotification *)notification
{
    self = [self init];
    if (self)
    {
        self.notification = notification;
    }
    return self;
}
-(instancetype)initWithRequest:(WSPRRequest *)request
{
    self = [self init];
    if (self)
    {
        self.request = request;
    }
    return self;
}

#pragma mark - Setters and Getters

-(WSPRCallType)callType
{
    return [WSPRHelper callTypeFromMethodString:[self fullMethod]];
}

-(NSString *)instanceId
{
    switch ([self callType]) {
        case WSPRCallTypeCreate:
        case WSPRCallTypeUnknown:
        case WSPRCallTypeStatic:
        case WSPRCallTypeStaticEvent:
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
            case WSPRCallTypeInstance:
            case WSPRCallTypeInstanceEvent:
            case WSPRCallTypeDestroy:
                return [params subarrayWithRange:NSMakeRange(1, params.count-1)];
            default:
                break;
        }
    }
    return params;
}

-(NSString *)className
{
    return [WSPRHelper classNameFromMethodString:[self fullMethod]];
}

-(NSString *)methodName
{
    return [WSPRHelper methodNameFromMethodString:[self fullMethod]];
}

-(NSArray *)methodComponents
{
    return [WSPRHelper methodComponentsFromMethodString:[self fullMethod]];
}

-(NSArray *)methodComponentSeparators
{
    return [WSPRHelper methodComponentSeparatorsFromMethodString:[self fullMethod]];
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
