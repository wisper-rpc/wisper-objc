//
//  WSRPCHelper.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 11/06/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSRPCHelper.h"

@implementation WSRPCHelper

+(BOOL)paramType:(NSString *)paramType matchesArgument:(id)argument
{
    if ([paramType isEqualToString:RPC_PARAM_TYPE_STRING])
    {
        return [argument isKindOfClass:[NSString class]];
    }
    
    if ([paramType isEqualToString:RPC_PARAM_TYPE_NUMBER])
    {
        return [argument isKindOfClass:[NSNumber class]];
    }
    
    if ([paramType isEqualToString:RPC_PARAM_TYPE_ARRAY])
    {
        return [argument isKindOfClass:[NSArray class]];
    }
    
    if ([paramType isEqualToString:RPC_PARAM_TYPE_DICTIONARY])
    {
        return [argument isKindOfClass:[NSDictionary class]];
    }
    
    if ([paramType isEqualToString:RPC_PARAM_TYPE_INSTANCE])
    {
        //Argument should already be an instance or nil.
        return argument == nil || [argument respondsToSelector:@selector(rpcController)];
    }
    return NO;
}

+(WSRPCCallType)callTypeFromMethodString:(NSString *)method
{
    NSArray *components = [method componentsSeparatedByString:@":"];
    if (components.count > 1)
    {
        if ([[components lastObject] rangeOfString:@"~"].location != NSNotFound)
        {
            return WSRPCCallTypeDestroy;
        }
        else if ([[components lastObject] rangeOfString:@"!"].location != NSNotFound)
        {
            return WSRPCCallTypeInstanceEvent;
        }
        return WSRPCCallTypeInstance;
    }
    
    if ([method rangeOfString:@"~"].location != NSNotFound)
    {
        return WSRPCCallTypeCreate;
    }
    
    if ([method rangeOfString:@"!"].location != NSNotFound)
    {
        return WSRPCCallTypeStaticEvent;
    }
    
    if ([method rangeOfString:@"."].location != NSNotFound)
    {
        return WSRPCCallTypeStatic;
    }
    
    return WSRPCCallTypeUnknown;
}


+(NSString *)classNameFromMethodString:(NSString *)method
{
    NSArray *classComponents = [method componentsSeparatedByString:@"."];
    NSString *lastComponent = [classComponents lastObject];
    
    WSRPCCallType callType = [WSRPCHelper callTypeFromMethodString:method];
    
    switch (callType)
    {
        case WSRPCCallTypeUnknown:
            break;
        case WSRPCCallTypeCreate:
        {
            NSRange tildeRange = [method rangeOfString:@"~"];
            return [method substringWithRange:NSMakeRange(0, tildeRange.location)];
        }
            break;
        case WSRPCCallTypeStatic:
        {
            return [method substringToIndex:method.length - lastComponent.length - 1];
        }
            break;
        case WSRPCCallTypeInstance:
        {
            NSArray *components = [method componentsSeparatedByString:@":"];
            return [components firstObject];
        }
            break;
        case WSRPCCallTypeDestroy:
        {
            NSArray *components = [method componentsSeparatedByString:@":"];
            return [components firstObject];
        }
            break;
        case WSRPCCallTypeStaticEvent:
        {
            NSRange exclamationRange = [method rangeOfString:@"!"];
            return [method substringWithRange:NSMakeRange(0, exclamationRange.location)];
        }
            break;
        case WSRPCCallTypeInstanceEvent:
        {
            NSArray *components = [method componentsSeparatedByString:@":"];
            return [components firstObject];
        }
            break;
    }
    return nil;
}

+(NSString *)methodNameFromMethodString:(NSString *)method
{
    NSArray *classComponents = [method componentsSeparatedByString:@"."];
    NSString *lastComponent = [classComponents lastObject];
    
    WSRPCCallType callType = [WSRPCHelper callTypeFromMethodString:method];
    
    switch (callType)
    {
        case WSRPCCallTypeUnknown:
            break;
        case WSRPCCallTypeCreate:
        {
            return @"~";
        }
        case WSRPCCallTypeStatic:
        {
            return [classComponents lastObject];
        }
            break;
        case WSRPCCallTypeInstance:
        {
            NSArray *components = [lastComponent componentsSeparatedByString:@":"];
            return [components lastObject];
        }
            break;
        case WSRPCCallTypeDestroy:
        {
            return @"~";
        }
            break;
        case WSRPCCallTypeStaticEvent:
        {
            return @"!";
        }
            break;
        case WSRPCCallTypeInstanceEvent:
        {
            return @"!";
        }
            break;
    }
    return nil;
}

+(NSArray *)methodComponentsFromMethodString:(NSString *)method
{
    NSMutableCharacterSet *characterSet = [[NSMutableCharacterSet alloc] init];
    [characterSet addCharactersInString:@".:"];
    
    return [method componentsSeparatedByCharactersInSet:characterSet];
}

+(NSArray *)methodComponentSeparatorsFromMethodString:(NSString *)method
{
    return [method componentsSeparatedByCharactersInSet:[NSCharacterSet alphanumericCharacterSet]];
}


@end
