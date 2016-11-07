//
//  WSRPCHelper.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 11/06/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRHelper.h"
#import "WSPRRouter.h"

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
    
    if ([paramType isEqualToString:WSPR_PARAM_TYPE_CALLER])
    {
        return [argument respondsToSelector:@selector(route:toPath:)];
    }
    
    if ([paramType isEqualToString:WSPR_PARAM_TYPE_ASYNC_RETURN_BLOCK])
    {
        return argument ? YES : NO;
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

/*
 An object that may be converted to JSON must have the following properties:
 
 The top level object is an NSArray or NSDictionary. All objects are instances of NSString, NSNumber, NSArray, NSDictionary, or NSNull.
 All dictionary keys are instances of NSString. Numbers are not NaN or infinity.
 */
+(id)jsonSafeObjectFromObject:(NSObject *)object
{
    if ([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dictionary = (NSDictionary *)object;
        NSMutableDictionary *safeDictionary = [NSMutableDictionary dictionary];
        
        for (id key in [dictionary allKeys])
        {
            id safeKey = [self jsonSafeObjectFromObject:key];
            if ([safeKey isKindOfClass:[NSString class]])
            {
                safeDictionary[safeKey] = [self jsonSafeObjectFromObject:dictionary[key]];
            }
        }
        
        return [NSDictionary dictionaryWithDictionary:safeDictionary];
    }
    
    if ([object isKindOfClass:[NSArray class]])
    {
        NSArray *array = (NSArray *)object;
        NSMutableArray *safeArray = [NSMutableArray array];
        
        for (id object in array)
        {
            [safeArray addObject:[self jsonSafeObjectFromObject:object]];
        }
        
        return [NSArray arrayWithArray:safeArray];
    }

    if ([object isKindOfClass:[NSSet class]])
    {
        NSSet *set = (NSSet *)object;
        NSMutableArray *safeArray = [NSMutableArray array];
        
        for (id object in set)
        {
            [safeArray addObject:[self jsonSafeObjectFromObject:object]];
        }
        
        return [NSArray arrayWithArray:safeArray];
    }

    if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNull class]])
    {
        return object;
    }
    
    if ([object isKindOfClass:[NSNumber class]])
    {
        NSNumber *number = (NSNumber *)object;
        
        if([number isEqualToNumber:[NSDecimalNumber notANumber]])
            return @(0);
        
        if ([number floatValue] == INFINITY)
            return @(0);
        
        return number;
    }
    
    if ([object isKindOfClass:[NSURL class]])
    {
        return [(NSURL *)object absoluteString];
    }
    
    if ([object isKindOfClass:[NSDate class]])
    {
        NSTimeInterval epochInterval = [(NSDate *)object timeIntervalSince1970];
        return [NSNumber numberWithInteger:(NSInteger)(epochInterval * 1000)];
    }
    
    if ([object description])
    {
        return [object description];
    }
    
    return [NSNull null];
}

+(void)objectFromJSONString:(NSString *)jsonString completion:(void (^)(NSDictionary *jsonDict, NSArray *jsonArray, NSError *error))completion
{
    @try
    {
        NSError *error = nil;
        id object =  [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if ([object isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dict = object;
            completion(dict, nil, error);
        }
        else
        {
            NSArray *array = object;
            completion(nil, array, error);
        }
    }
    @catch (NSException *exception)
    {
        NSError *errorFromException = [NSError errorWithDomain:@"WSPRJSONSerilization" code:-1 userInfo:@{NSLocalizedDescriptionKey : [exception description]}];
        
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey : @"Exception when parsing json string!",
                                   NSUnderlyingErrorKey :errorFromException
                                   };
        
        NSError *wrapperError = [NSError errorWithDomain:@"WSPRJSONSerilization" code:-1 userInfo:userInfo];
        completion(nil, nil, wrapperError);
    }
}

+(void)jsonStringFromObject:(NSObject *)object completion:(void (^)(NSString *, NSError *))completion
{
    NSObject *jsonSafeObject = [self jsonSafeObjectFromObject:object];
    
    if (![jsonSafeObject isKindOfClass:[NSDictionary class]] && ![jsonSafeObject isKindOfClass:[NSArray class]])
    {
        completion(nil, [NSError errorWithDomain:@"WSPRJSONSerialization" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Root object is not NSDictionary or NSArray subclass"}]);
        return;
    }
    
    @try
    {
        NSError *error;
        NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonSafeObject options:0 error:&error] encoding:NSUTF8StringEncoding];
        completion(jsonString, error);
    }
    @catch (NSException *exception)
    {
        NSError *errorFromException = [NSError errorWithDomain:@"WSPRJSONSerilization" code:-1 userInfo:@{NSLocalizedDescriptionKey : [exception description]}];
        
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey : @"Exception when serializing object!",
                                   NSUnderlyingErrorKey :errorFromException
                                   };
        
        NSError *wrapperError = [NSError errorWithDomain:@"WSPRJSONSerilization" code:-1 userInfo:userInfo];
        completion(nil, wrapperError);
    }
}



@end
