//
//  WSRPCClassModel.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 26/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSRPCClass.h"

@implementation WSRPCClass

-(NSString *)mapName
{
    return _mapName ? : NSStringFromClass(_classRef);
}

-(void)addStaticMethod:(WSRPCClassMethod *)staticMethod
{
    NSMutableDictionary *staticMethods = [NSMutableDictionary dictionaryWithDictionary:self.staticMethods ? : @{}];
    staticMethods[staticMethod.mapName] = staticMethod;
    self.staticMethods = [NSDictionary dictionaryWithDictionary:staticMethods];
}

-(void)addInstanceMethod:(WSRPCClassMethod *)instanceMethod
{
    NSMutableDictionary *instanceMethods = [NSMutableDictionary dictionaryWithDictionary:self.instanceMethods ? : @{}];
    instanceMethods[instanceMethod.mapName] = instanceMethod;
    self.instanceMethods = [NSDictionary dictionaryWithDictionary:instanceMethods];
}

-(void)addProperty:(WSRPCClassProperty *)property
{
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:self.properties ? : @{}];
    properties[property.mapName] = property;
    self.properties = [NSDictionary dictionaryWithDictionary:properties];
}

-(NSString *)description
{
    return [@{
              @"classRef" : NSStringFromClass(_classRef) ? : @"",
              @"mapName" : _mapName ? : @"",
              @"staticMethods" : _staticMethods ? : @{},
              @"instanceMethods" : _instanceMethods ? : @{},
              @"properties" : _properties ? :@{}
              } description];
}

@end
