//
//  WSPRClassModel.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 26/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRClass.h"

@implementation WSPRClass

-(void)addStaticMethod:(WSPRClassMethod *)staticMethod
{
    NSMutableDictionary *staticMethods = [NSMutableDictionary dictionaryWithDictionary:self.staticMethods ? : @{}];
    staticMethods[staticMethod.mapName] = staticMethod;
    self.staticMethods = [NSDictionary dictionaryWithDictionary:staticMethods];
}

-(void)addInstanceMethod:(WSPRClassMethod *)instanceMethod
{
    NSMutableDictionary *instanceMethods = [NSMutableDictionary dictionaryWithDictionary:self.instanceMethods ? : @{}];
    instanceMethods[instanceMethod.mapName] = instanceMethod;
    self.instanceMethods = [NSDictionary dictionaryWithDictionary:instanceMethods];
}

-(void)addProperty:(WSPRClassProperty *)property
{
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:self.properties ? : @{}];
    properties[property.mapName] = property;
    self.properties = [NSDictionary dictionaryWithDictionary:properties];
}

-(NSString *)description
{
    return [@{
              @"classRef" : NSStringFromClass(_classRef) ? : @"",
              @"staticMethods" : _staticMethods ? : @{},
              @"instanceMethods" : _instanceMethods ? : @{},
              @"properties" : _properties ? :@{}
              } description];
}

@end
