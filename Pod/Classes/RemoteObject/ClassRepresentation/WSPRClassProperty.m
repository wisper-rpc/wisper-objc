//
//  WSPRProperty.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 20/08/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRClassProperty.h"

@implementation WSPRClassProperty

+(instancetype)propertyWithMapName:(NSString *)mapName keyPath:(NSString *)keyPath type:(NSString *)type andMode:(WSPRPropertyMode)mode
{
    return [[[self class] alloc] initWithMapName:mapName keyPath:keyPath type:type andMode:mode];
}

-(instancetype)initWithMapName:(NSString *)mapName keyPath:(NSString *)keyPath type:(NSString *)type andMode:(WSPRPropertyMode)mode
{
    self = [self init];
    if (self)
    {
        self.mapName = mapName;
        self.keyPath = keyPath;
        self.type = type;
        self.mode = mode;
    }
    return self;
}


-(NSString *)description
{
    return [@{
              @"mapName" : _mapName ? : @"",
              @"keyPath" : _keyPath ? : @"",
              @"mode" : @(_mode),
              @"type" : _type ? : @"",
              @"details" : _details ? : @""
              } description];
}

@end
