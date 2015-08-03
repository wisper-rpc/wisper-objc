//
//  WSRPCEvent.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 11/06/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSRPCEvent.h"
#import "WSRPCHelper.h"

@implementation WSRPCEvent

-(instancetype)initWithNotification:(WSRPCNotification *)notification
{
    self = [self init];
    if (self)
    {
        self.mapName = [WSRPCHelper classNameFromMethodString:notification.method];
        
        switch ([WSRPCHelper callTypeFromMethodString:notification.method])
        {
            case WSRPCCallTypeStaticEvent:
                self.name = [notification.params firstObject];
                self.data = notification.params.count > 1 ? notification.params[1] : nil;
                break;
            case WSRPCCallTypeInstanceEvent:
                self.instanceIdentifier = [notification.params firstObject];
                self.name = notification.params.count > 1 ? notification.params[1] : nil;
                self.data = notification.params.count > 2 ? notification.params[2] : nil;
                break;
            default:
                break;
        }
    }
    return self;
}

//TODO: Rename to asNotification?
-(WSRPCNotification *)createNotification
{
    if (!_name)
        return nil;
    
    NSMutableArray *params = [NSMutableArray array];
    if (_instanceIdentifier)
        [params addObject:_instanceIdentifier];
    if (_name)
        [params addObject:_name];
    if (_data)
        [params addObject:_data];
    
    WSRPCNotification *notification = [[WSRPCNotification alloc] init];
    notification.method = [NSString stringWithFormat:@"%@%@", _mapName, _instanceIdentifier ? @":!" : @"!"];
    notification.params = [NSArray arrayWithArray:params];
    return notification;
}

-(NSString *)description
{
    return [@{
              @"mapName" : _mapName ? : @"",
              @"instanceIdentifier" : _instanceIdentifier ? : @"",
              @"name" : _name ? : @"",
              @"data" : _data ? : @""
              } description];
}

@end
