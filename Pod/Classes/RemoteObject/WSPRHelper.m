//
//  WSRPCHelper.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 11/06/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRHelper.h"

@implementation WSPRHelper

+(BOOL)paramType:(NSString *)paramType matchesArgument:(id)argument
{
    if ([paramType isEqualToString:WSPR_PARAM_TYPE_STRING])
    {
        return [argument isKindOfClass:[NSString class]];
    }
    
    if ([paramType isEqualToString:WSPR_PARAM_TYPE_NUMBER])
    {
        return [argument isKindOfClass:[NSNumber class]];
    }
    
    if ([paramType isEqualToString:WSPR_PARAM_TYPE_ARRAY])
    {
        return [argument isKindOfClass:[NSArray class]];
    }
    
    if ([paramType isEqualToString:WSPR_PARAM_TYPE_DICTIONARY])
    {
        return [argument isKindOfClass:[NSDictionary class]];
    }
    
    if ([paramType isEqualToString:WSPR_PARAM_TYPE_INSTANCE])
    {
        //Argument should already be an instance or nil.
        return argument == nil || [argument respondsToSelector:@selector(classRouter)];
    }
    return NO;
}

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


+(NSString *)classNameFromMethodString:(NSString *)method
{
    NSArray *classComponents = [method componentsSeparatedByString:@"."];
    NSString *lastComponent = [classComponents lastObject];
    
    WSPRCallType callType = [WSPRHelper callTypeFromMethodString:method];
    
    switch (callType)
    {
        case WSPRCallTypeUnknown:
            break;
        case WSPRCallTypeCreate:
        {
            NSRange tildeRange = [method rangeOfString:@"~"];
            return [method substringWithRange:NSMakeRange(0, tildeRange.location)];
        }
            break;
        case WSPRCallTypeStatic:
        {
            return [method substringToIndex:method.length - lastComponent.length - 1];
        }
            break;
        case WSPRCallTypeInstance:
        {
            NSArray *components = [method componentsSeparatedByString:@":"];
            return [components firstObject];
        }
            break;
        case WSPRCallTypeDestroy:
        {
            NSArray *components = [method componentsSeparatedByString:@":"];
            return [components firstObject];
        }
            break;
        case WSPRCallTypeStaticEvent:
        {
            NSRange exclamationRange = [method rangeOfString:@"!"];
            return [method substringWithRange:NSMakeRange(0, exclamationRange.location)];
        }
            break;
        case WSPRCallTypeInstanceEvent:
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
    
    WSPRCallType callType = [WSPRHelper callTypeFromMethodString:method];
    
    switch (callType)
    {
        case WSPRCallTypeUnknown:
            break;
        case WSPRCallTypeCreate:
        {
            return @"~";
        }
        case WSPRCallTypeStatic:
        {
            return [classComponents lastObject];
        }
            break;
        case WSPRCallTypeInstance:
        {
            NSArray *components = [lastComponent componentsSeparatedByString:@":"];
            return [components lastObject];
        }
            break;
        case WSPRCallTypeDestroy:
        {
            return @"~";
        }
            break;
        case WSPRCallTypeStaticEvent:
        {
            return @"!";
        }
            break;
        case WSPRCallTypeInstanceEvent:
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
