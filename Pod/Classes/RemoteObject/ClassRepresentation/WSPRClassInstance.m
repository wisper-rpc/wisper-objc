//
//  WSPRClassInstance.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 28/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRClassInstance.h"
#import "WSPRHelper.h"
#import "WSPRInstanceRegistry.h"
#import "WSPRClassRouter.h"

@interface WSPRClassInstance ()

@property (nonatomic, assign) BOOL hasAddedPropertyListeners;

/**
 Map that has the real property name as the key.
 */
@property (nonatomic, strong) NSDictionary *keyPathProperties;

@property (nonatomic, assign) BOOL isSettingProperty;

@end

@implementation WSPRClassInstance

-(void)setInstance:(NSObject<WSPRClassProtocol> *)instance
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

-(void)setRpcClass:(WSPRClass *)rpcClass
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
        for (WSPRClassProperty *property in [_rpcClass.properties allValues])
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
    
    for (WSPRClassProperty *property in [_rpcClass.properties allValues])
    {
        if (property.mode == WSPRPropertyModeReadWrite || property.mode == WSPRPropertyModeReadOnly)
            [_instance addObserver:self forKeyPath:property.keyPath options:0 context:nil];
    }
    self.hasAddedPropertyListeners = YES;
}

-(void)removePropertyListeners
{
    if (!_instance || !_rpcClass || !_hasAddedPropertyListeners)
        return;

    for (WSPRClassProperty *property in [_rpcClass.properties allValues])
    {
        if (property.mode == WSPRPropertyModeReadWrite || property.mode == WSPRPropertyModeReadOnly)
            [_instance removeObserver:self forKeyPath:property.keyPath];
    }
    self.keyPathProperties = nil;
    self.hasAddedPropertyListeners = NO;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!_delegate || _isSettingProperty)
        return;
    
    WSPRClassProperty *property = self.keyPathProperties[keyPath];
    
    WSPREvent *event = [[WSPREvent alloc] init];
    event.instanceIdentifier = self.instanceIdentifier;
    event.mapName = _rpcClass.mapName;
    event.name = [property mapName];
    event.data = [object valueForKeyPath:keyPath];
    
    //If instance property
    if ([[property type] isEqualToString:WSPR_PARAM_TYPE_INSTANCE])
    {
        //Look for instance in rpcController
        WSPRClassInstance *classInstance = [WSPRInstanceRegistry instanceModelForInstance:[object valueForKeyPath:keyPath] underRootRoute:[(WSPRClassRouter *)self.instance.classRouter rootRouter]];
        event.data = classInstance ? classInstance.instanceIdentifier : [NSNull null];
    }
    
    //Encode if block is provided
    if (property.serializeWisperPropertyBlock)
    {
        event.data = property.serializeWisperPropertyBlock(event.data);
    }
    
    [_delegate classInstance:self didCreatePropertyEvent:event];
}

-(BOOL)handlePropertyEvent:(WSPREvent *)event
{
    WSPRClassProperty *property = self.rpcClass.properties[event.name];
    if (property && (property.mode == WSPRPropertyModeReadWrite || property.mode == WSPRPropertyModeWriteOnly) && property.type)
    {
        //Property pass by reference lookup
        if ([property.type isEqualToString:WSPR_PARAM_TYPE_INSTANCE])
        {
            //Accept NSNull
            if ([event.data isKindOfClass:[NSNull class]])
            {
                event.data = nil;
            }
            else
            {
                //Lookup instance
                WSPRClassInstance *classInstanceModel = [WSPRInstanceRegistry instanceWithId:event.data underRootRoute:[(WSPRClassRouter *)self.instance.classRouter rootRouter]];
                
                if (classInstanceModel)
                {
                    event.data = classInstanceModel.instance;
                }
            }
        }
        
        if ([WSPRHelper paramType:property.type matchesArgument:event.data])
        {
            id data = event.data;
            
            //Decode property value if decode block is provided
            if (property.deserializeWisperPropertyBlock)
            {
                data = property.deserializeWisperPropertyBlock(data);
            }
            
            self.isSettingProperty = YES;
            [self.instance setValue:data forKeyPath:property.keyPath];
            self.isSettingProperty = NO;
            return YES;
        }
    }
    return NO;
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
