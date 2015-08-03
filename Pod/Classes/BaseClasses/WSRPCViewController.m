//
//  WSRPCViewController.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 26/05/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSRPCViewController.h"

@interface WSRPCViewController ()

@property (nonatomic, assign) BOOL isDestroying;

@end

@implementation WSRPCViewController
@synthesize rpcController = _rpcController;
@synthesize rpcClassInstance = _rpcClassInstance;

+(WSRPCClass *)rpcRegisterClass
{
    WSRPCClass *rpcObjectClass = [[WSRPCClass alloc] init];
    rpcObjectClass.classRef = [WSRPCClass class];
    rpcObjectClass.mapName = @"WSRPCClass";
    return rpcObjectClass;
}

-(WSRPCClassInstance *)rpcClassInstance
{
    if (_rpcClassInstance)
    {
        return _rpcClassInstance;
    }
    _rpcClassInstance = [self.rpcController getRPCClassInstanceForInstance:self];
    return _rpcClassInstance;
}

+(void)rpcHandleStaticEvent:(WSRPCEvent *)event
{
}

-(void)rpcDestructor
{
    self.isDestroying = YES;
}

#pragma mark - RPCEvent methods

-(void)rpcSendEvent:(WSRPCEvent *)event
{
    if (!event || !self.rpcController || self.isDestroying)
        return;
    
    [self.rpcController makeNotificationWithNotification:[event createNotification]];
}

-(WSRPCEvent *)rpcCreateInstanceEvent
{
    if (!self.rpcClassInstance)
        return nil;
    
    WSRPCEvent *event = [[WSRPCEvent alloc] init];
    event.instanceIdentifier = self.rpcClassInstance.instanceIdentifier;
    event.mapName = self.rpcClassInstance.rpcClass.mapName;
    return event;
}

-(WSRPCEvent *)rpcCreateStaticEvent
{
    if (!self.rpcClassInstance)
        return nil;
    
    WSRPCEvent *event = [[WSRPCEvent alloc] init];
    event.mapName = self.rpcClassInstance.rpcClass.mapName;
    return event;
}



@end
