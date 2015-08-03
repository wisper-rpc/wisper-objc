//
//  WSRPCError.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 27/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSRPCError.h"

@implementation WSRPCError


+(instancetype)error
{
    return [[self class] errorWithDictionary:nil];
}

+(instancetype)errorWithDictionary:(NSDictionary *)dictionary
{
    return [[[self class] alloc] initWithDictionary:dictionary];
}

+(instancetype)errorWithDomain:(WSRPCErrorDomain)domain andCode:(NSInteger)code
{
    return [[[self class] alloc] initWithDomain:domain andCode:code];
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self)
    {
        self.domain = [dictionary[@"domain"] integerValue];
        self.code = [dictionary[@"code"] integerValue];
        self.message = dictionary[@"message"];
        self.data = dictionary[@"data"];
        
        if (dictionary[@"underlying"])
        {
            self.underlyingError = [[[self class] alloc] initWithDictionary:dictionary[@"underlying"]];
        }
    }
    return self;
}

-(instancetype)initWithDomain:(WSRPCErrorDomain)domain andCode:(NSInteger)code
{
    self = [self init];
    if (self)
    {
        self.domain = domain;
        self.code = code;
    }
    return self;
}

-(NSString *)name
{
    return [self errorCodeName];
}

-(NSString *)description
{
    return [[self asDictionary] description];
}


-(NSDictionary *)asDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
             @"domain" : @(self.domain),
             @"code" : @(self.code),
             @"name" : self.name,
             @"message" : self.message ? : @"",
             }];
    if (self.data)
    {
        [dictionary setObject:self.data forKey:@"data"];
    }
    if (self.underlyingError)
    {
        [dictionary setObject:[self.underlyingError asDictionary] forKey:@"underlying"];
    }
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

-(NSString *)asJSONString
{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self asDictionary] options:0 error:nil] encoding:NSASCIIStringEncoding];
}

#pragma mark - Enum to string helpers

-(NSString *)domainName
{
    switch (self.domain)
    {
        case WSRPCErrorDomainJavaScript:
            return @"JavaScript";
        case WSRPCErrorDomainRPC:
            return @"RPC";
        case WSRPCErrorDomainRemoteObject:
            return @"RemoteObject";
        case WSRPCErrorDomainAction:
            return @"ActionDomain";
        case WSRPCErrorDomainiOS_OSX:
            return @"iOS/OSX";
        case WSRPCErrorDomainAndroid:
            return @"Android";
        case WSRPCErrorDomainWindows:
            return @"Windows";
    }
    return @"";
}


-(NSString *)errorCodeName
{
    switch (self.domain)
    {
        case WSRPCErrorDomainJavaScript:
        {
            WSRPCErrorJavascript errorCode = self.code;
            switch (errorCode)
            {
                case WSRPCErrorJavascriptError:
                    return @"Error";
                case WSRPCErrorJavascriptEval:
                    return @"EvalError";
                case WSRPCErrorJavascriptRange:
                    return @"RangeError";
                case WSRPCErrorJavascriptReference:
                    return @"ReferenceError";
                case WSRPCErrorJavascriptSyntax:
                    return @"SyntaxError";
                case WSRPCErrorJavascriptType:
                    return @"TypeError";
                case WSRPCErrorJavascriptURI:
                    return @"URIError";
            }
        }
            break;
        case WSRPCErrorDomainRPC:
        {
            WSRPCErrorRPC errorCode = self.code;
            switch (errorCode)
            {
                case WSRPCErrorRPCError:
                    return @"Error";
                case WSRPCErrorRPCParseError:
                    return @"ParseError";
                case WSRPCErrorRPCFormatError:
                    return @"FormatError";
                case WSRPCErrorMissingProcedure:
                    return @"MissingProcedureError";
                case WSRPCErrorRPCInvalidMessageType:
                    return @"InvalidMessageTypeError";
            }
        }
            break;
        case WSRPCErrorDomainRemoteObject:
        {
            WSRPCErrorRemoteObject errorCode = self.code;
            switch (errorCode)
            {
                case WSRPCErrorRemoteObjectMissingClass:
                    return @"MissingClassError";
                case WSRPCErrorRemoteObjectInvalidInstance:
                    return @"InvalidInstanceError";
                case WSRPCErrorRemoteObjectMissingProcedure:
                    return @"MissingProcedureError";
                case WSRPCErrorRemoteObjectInvalidArguments:
                    return @"InvalidArgumentsError";
                case WSRPCErrorRemoteObjectInvalidModifier:
                    return @"InvalidModifierError";
            }
        }
            break;
        case WSRPCErrorDomainAction:
        {
            WSRPCErrorAction errorCode = self.code;
            switch (errorCode) {
                case WSRPCErrorActionAppNotFound:
                    return @"AppNotFound";
                case WSRPCErrorActionGyroNotSupported:
                    return @"GyroNotSupported";
                case WSRPCErrorActionOpenGLNotSupported:
                    return @"OpenGLNotSupported";
            }
        }
            break;

        case WSRPCErrorDomainiOS_OSX:
        {
            //Not handled yet
        }
            break;
        case WSRPCErrorDomainAndroid:
        {
            //Not handled yet
        }
            break;
        case WSRPCErrorDomainWindows:
        {
            //Not handled yet
        }
            break;
    }
    return @"";
}


@end
