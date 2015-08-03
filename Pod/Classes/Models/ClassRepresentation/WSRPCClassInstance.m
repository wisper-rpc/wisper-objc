//
//  WSRPCClassInstance.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 28/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSRPCClassInstance.h"
#import "WSRPCRemoteObjectController.h"
@interface WSRPCClassInstance ()

@property (nonatomic, assign) BOOL hasAddedPropertyListeners;

/**
 Map that has the real property name as the key.
 */
@property (nonatomic, strong) NSDictionary *keyPathProperties;

@end

@implementation WSRPCClassInstance

-(void)setInstance:(NSObject<WSRPCClassProtocol> *)instance
{
    if (_instance != instance)
    {
        [self removePropertyListeners];
        _instance = instance;
        [self addPropertyListeners];
    }
}

-(void)dealloc
{
    [self removePropertyListeners];
}

-(void)setRpcClass:(WSRPCClass *)rpcClass
{
    if (_rpcClass != rpcClass)
    {
        [self removePropertyListeners];
        _rpcClass = rpcClass;
        [self addPropertyListeners];
    }
}

-(NSDictionary *)keyPathProperties
{
    if (!_keyPathProperties)
    {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        for (WSRPCClassProperty *property in [_rpcClass.properties allValues])
        {
            dictionary[property.keyPath] = property;
        }
        self.keyPathProperties = [NSDictionary dictionaryWithDictionary:dictionary];
    }
    return _keyPathProperties;
}

-(void)addPropertyListeners
{
    if (!_instance || !_rpcClass || _hasAddedPropertyListeners)
        return;
    
    for (WSRPCClassProperty *property in [_rpcClass.properties allValues])
    {
        if (property.mode == WSRPCPropertyModeReadWrite || property.mode == WSRPCPropertyModeReadOnly)
            [_instance addObserver:self forKeyPath:property.keyPath options:0 context:nil];
    }
    self.hasAddedPropertyListeners = YES;
}

-(void)removePropertyListeners
{
    if (!_instance || !_rpcClass || !_hasAddedPropertyListeners)
        return;

    for (WSRPCClassProperty *property in [_rpcClass.properties allValues])
    {
        if (property.mode == WSRPCPropertyModeReadWrite || property.mode == WSRPCPropertyModeReadOnly)
            [_instance removeObserver:self forKeyPath:property.keyPath];
    }
    self.keyPathProperties = nil;
    self.hasAddedPropertyListeners = NO;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!_delegate)
        return;
    
    WSRPCEvent *event = [[WSRPCEvent alloc] init];
    event.instanceIdentifier = self.instanceIdentifier;
    event.mapName = _rpcClass.mapName;
    event.name = [(WSRPCClassProperty *)self.keyPathProperties[keyPath] mapName];
    
    //If instance property
    if ([[(WSRPCClassProperty *)self.keyPathProperties[keyPath] type] isEqualToString:RPC_PARAM_TYPE_INSTANCE])
    {
        //Look for instance in rpcController
        WSRPCRemoteObjectController *remoteObjectController = self.instance.rpcController;
        WSRPCClassInstance *classInstance = [remoteObjectController getRPCClassInstanceForInstance:[object valueForKeyPath:keyPath]];
        
        event.data = classInstance ? classInstance.instanceIdentifier : [NSNull null];
    }
    else
    {
        event.data = [object valueForKeyPath:keyPath];
    }
    
    [_delegate classInstance:self didCreatePropertyEvent:event];
}


-(NSString *)description
{
    return [@{
              @"instanceIdentifier":_instanceIdentifier ? : @"",
              @"rpcClass" : _rpcClass ? : @"",
              @"instance" : _instance ? : @""}
            description];
}


@end
