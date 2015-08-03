//
//  WSRPCClassStaticMethod.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 28/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSRPCClassMethod.h"

@implementation WSRPCClassMethod


+(instancetype)methodWithMapName:(NSString *)mapName selector:(SEL)selector andParamTypes:(NSArray *)paramTypes
{
    return [[[self class] alloc] initWithMapName:mapName selector:selector andParamTypes:paramTypes];
}

+(instancetype)methodWithMapName:(NSString *)mapName selector:(SEL)selector paramTypes:(NSArray *)paramTypes andVoidReturn:(BOOL)isVoidReturn
{
    return [[[self class] alloc] initWithMapName:mapName selector:selector paramTypes:paramTypes andVoidReturn:isVoidReturn];
}

-(instancetype)initWithMapName:(NSString *)mapName selector:(SEL)selector andParamTypes:(NSArray *)paramTypes
{
    return [self initWithMapName:mapName selector:selector paramTypes:paramTypes andVoidReturn:YES];
}

-(instancetype)initWithMapName:(NSString *)mapName selector:(SEL)selector paramTypes:(NSArray *)paramTypes andVoidReturn:(BOOL)isVoidReturn
{
    self = [self init];
    if (self)
    {
        self.mapName = mapName;
        self.selector = selector;
        self.paramTypes = paramTypes;
        self.isVoidReturn = isVoidReturn;
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        self.isVoidReturn = YES;
    }
    return self;
}

-(NSString *)methodName
{
    if (_selector)
    {
        return NSStringFromSelector(_selector);
    }
    return @"";
}

-(NSString *)description
{
    return [@{
              @"mapName" : _mapName ? : @"",
              @"details" : _details ? : @"details",
              @"isVoidReturn" : _isVoidReturn ? @"YES" : @"NO",
              @"paramTypes" : _paramTypes ? : @[],
              @"selector" : self.methodName
              } description];
}

@end
