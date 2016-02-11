//
//  WSPRClassRouter.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 11/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRClassRouter.h"

@interface WSPRClassRouter ()

@property (nonatomic, strong) WSPRClass *classModel;
@property (nonatomic, strong) NSMutableDictionary *instanceMap;

@end

@implementation WSPRClassRouter

#pragma mark - Life cycle
-(instancetype)initWithClass:(Class<WSPRClassProtocol>)aClass
{
    WSPRClass *wisperClass = [aClass rpcRegisterClass];
    self = [self initWithNameSpace:wisperClass.mapName];
    if (self)
    {
        self.classModel = wisperClass;
    }
    return self;
}


#pragma mark - Helpers

+(WSPRCallType)callTypeFromMethodString:(NSString *)method
{
    NSArray *components = [method componentsSeparatedByString:@":"];
    if (components.count > 1)
    {
        if ([[components lastObject] rangeOfString:@"~"].location != NSNotFound)
        {
            return WSPRCallTypeDestroy;
        }
        else if ([[components lastObject] rangeOfString:@"!"].location != NSNotFound)
        {
            return WSPRCallTypeInstanceEvent;
        }
        return WSPRCallTypeInstance;
    }
    
    if ([method rangeOfString:@"~"].location != NSNotFound)
    {
        return WSPRCallTypeCreate;
    }
    
    if ([method rangeOfString:@"!"].location != NSNotFound)
    {
        return WSPRCallTypeStaticEvent;
    }
    
    if ([method rangeOfString:@"."].location != NSNotFound)
    {
        return WSPRCallTypeStatic;
    }
    
    return WSPRCallTypeUnknown;
}


@end
