//
//  WSPRObject.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 20/03/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRObject.h"

@interface WSPRObject ()

@property (nonatomic, assign) BOOL isDestroying;

@end
@implementation WSPRObject
@synthesize rpcController = _rpcController;
@synthesize rpcClassInstance = _rpcClassInstance;

+(WSPRClass *)rpcRegisterClass
{
    WSPRClass *rpcObjectClass = [[WSPRClass alloc] init];
    rpcObjectClass.classRef = [self class];
    rpcObjectClass.mapName = @"WSPRClass";
    return rpcObjectClass;
}

-(WSPRClassInstance *)rpcClassInstance
{
    if (_rpcClassInstance)
    {
        return _rpcClassInstance;
    }
    _rpcClassInstance = [self.rpcController getRPCClassInstanceForInstance:self];
    return _rpcClassInstance;
}

+(void)rpcHandleStaticEvent:(WSPREvent *)event
{
}

-(void)rpcDestructor
{
    self.isDestroying = YES;
}

#pragma mark - RPCEvent methods

-(void)rpcCallRemoteMethod:(NSString *)methodName withParams:(NSArray *)params responseBlock:(ResponseBlock)responseBlock
{
    NSMutableArray *idAndParams = [NSMutableArray arrayWithObject:self.rpcClassInstance.instanceIdentifier];
    [idAndParams addObjectsFromArray:params];
    
    WSPRRequest *request = [[WSPRRequest alloc] init];
    request.method = [NSString stringWithFormat:@"%@:%@", self.rpcClassInstance.rpcClass.mapName, methodName];
    request.params = [NSArray arrayWithArray:idAndParams];
    request.responseBlock = responseBlock;
    [self.rpcController sendMessage:request];
}

-(void)rpcSendEvent:(WSPREvent *)event
{
    if (!event || !self.rpcController || self.isDestroying)
        return;
    
    [self.rpcController sendMessage:[event createNotification]];
}

-(WSPREvent *)rpcCreateInstanceEvent
{
    if (!self.rpcClassInstance)
        return nil;
    
    WSPREvent *event = [[WSPREvent alloc] init];
    event.instanceIdentifier = self.rpcClassInstance.instanceIdentifier;
    event.mapName = self.rpcClassInstance.rpcClass.mapName;
    return event;
}

-(WSPREvent *)rpcCreateStaticEvent
{
    if (!self.rpcClassInstance)
        return nil;

    WSPREvent *event = [[WSPREvent alloc] init];
    event.mapName = self.rpcClassInstance.rpcClass.mapName;
    return event;
}


@end
