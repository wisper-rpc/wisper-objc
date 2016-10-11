//
//  WSPRObject.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 20/03/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRObject.h"
#import "WSPRInstanceRegistry.h"

@interface WSPRObject ()

@property (nonatomic, assign) BOOL isDestroying;

@end
@implementation WSPRObject
@synthesize classRouter = _classRouter;
@synthesize rpcClassInstance = _rpcClassInstance;

+(WSPRClass *)rpcRegisterClass
{
    WSPRClass *rpcObjectClass = [[WSPRClass alloc] init];
    rpcObjectClass.classRef = [self class];
    return rpcObjectClass;
}

-(WSPRClassInstance *)rpcClassInstance
{
    if (_rpcClassInstance)
    {
        return _rpcClassInstance;
    }
    _rpcClassInstance = [WSPRInstanceRegistry instanceModelForInstance:self underRootRoute:[self.classRouter rootRouter]];
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

-(void)rpcSendEvent:(WSPREvent *)event
{
    if (!event || !self.classRouter || self.isDestroying)
        return;
    
    [self.classRouter reverse:[event createNotification] fromPath:nil];
}

-(WSPREvent *)rpcCreateInstanceEvent
{
    if (!self.rpcClassInstance)
        return nil;
    
    WSPREvent *event = [[WSPREvent alloc] init];
    event.instanceIdentifier = self.rpcClassInstance.instanceIdentifier;
    return event;
}

-(WSPREvent *)rpcCreateStaticEvent
{
    if (!self.rpcClassInstance)
        return nil;

    WSPREvent *event = [[WSPREvent alloc] init];
    return event;
}


@end
