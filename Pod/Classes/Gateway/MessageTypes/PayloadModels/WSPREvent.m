//
//  WSPREvent.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 11/06/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPREvent.h"
#import "WSPRHelper.h"

@implementation WSPREvent

-(instancetype)initWithNotification:(WSPRNotification *)notification
{
    self = [self init];
    if (self)
    {
        self.mapName = [WSPRHelper classNameFromMethodString:notification.method];
        
        switch ([WSPRHelper callTypeFromMethodString:notification.method])
        {
            case WSPRCallTypeStaticEvent:
                self.name = [notification.params firstObject];
                self.data = notification.params.count > 1 ? notification.params[1] : nil;
                break;
            case WSPRCallTypeInstanceEvent:
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
-(WSPRNotification *)createNotification
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
    
    WSPRNotification *notification = [[WSPRNotification alloc] init];
    notification.method = [NSString stringWithFormat:@"%@%@", _mapName ? : @"", _instanceIdentifier ? @":!" : @"!"];
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
