//
//  WSPRError.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 27/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRError.h"

@implementation WSPRError


+(instancetype)error
{
    return [[self class] errorWithDictionary:nil];
}

+(instancetype)errorWithDictionary:(NSDictionary *)dictionary
{
    return [[[self class] alloc] initWithDictionary:dictionary];
}

+(instancetype)errorWithDomain:(WSPRErrorDomain)domain andCode:(NSInteger)code
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

-(instancetype)initWithDomain:(WSPRErrorDomain)domain andCode:(NSInteger)code
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
        case WSPRErrorDomainJavaScript:
            return @"JavaScript";
        case WSPRErrorDomainRPC:
            return @"RPC";
        case WSPRErrorDomainRemoteObject:
            return @"RemoteObject";
        case WSPRErrorDomainAction:
            return @"ActionDomain";
        case WSPRErrorDomainiOS_OSX:
            return @"iOS/OSX";
        case WSPRErrorDomainAndroid:
            return @"Android";
        case WSPRErrorDomainWindows:
            return @"Windows";
    }
    return @"";
}


-(NSString *)errorCodeName
{
    switch (self.domain)
    {
        case WSPRErrorDomainJavaScript:
        {
            WSPRErrorJavascript errorCode = self.code;
            switch (errorCode)
            {
                case WSPRErrorJavascriptError:
                    return @"Error";
                case WSPRErrorJavascriptEval:
                    return @"EvalError";
                case WSPRErrorJavascriptRange:
                    return @"RangeError";
                case WSPRErrorJavascriptReference:
                    return @"ReferenceError";
                case WSPRErrorJavascriptSyntax:
                    return @"SyntaxError";
                case WSPRErrorJavascriptType:
                    return @"TypeError";
                case WSPRErrorJavascriptURI:
                    return @"URIError";
            }
        }
            break;
        case WSPRErrorDomainRPC:
        {
            WSPRErrorRPC errorCode = self.code;
            switch (errorCode)
            {
                case WSPRErrorRPCError:
                    return @"Error";
                case WSPRErrorRPCParseError:
                    return @"ParseError";
                case WSPRErrorRPCFormatError:
                    return @"FormatError";
                case WSPRErrorMissingProcedure:
                    return @"MissingProcedureError";
                case WSPRErrorRPCInvalidMessageType:
                    return @"InvalidMessageTypeError";
            }
        }
            break;
        case WSPRErrorDomainRemoteObject:
        {
            WSPRErrorRemoteObject errorCode = self.code;
            switch (errorCode)
            {
                case WSPRErrorRemoteObjectMissingClass:
                    return @"MissingClassError";
                case WSPRErrorRemoteObjectInvalidInstance:
                    return @"InvalidInstanceError";
                case WSPRErrorRemoteObjectMissingProcedure:
                    return @"MissingProcedureError";
                case WSPRErrorRemoteObjectInvalidArguments:
                    return @"InvalidArgumentsError";
                case WSPRErrorRemoteObjectInvalidModifier:
                    return @"InvalidModifierError";
            }
        }
            break;
        case WSPRErrorDomainAction:
        {
            WSPRErrorAction errorCode = self.code;
            switch (errorCode) {
                case WSPRErrorActionAppNotFound:
                    return @"AppNotFound";
                case WSPRErrorActionGyroNotSupported:
                    return @"GyroNotSupported";
                case WSPRErrorActionOpenGLNotSupported:
                    return @"OpenGLNotSupported";
            }
        }
            break;

        case WSPRErrorDomainiOS_OSX:
        {
            //Not handled yet
        }
            break;
        case WSPRErrorDomainAndroid:
        {
            //Not handled yet
        }
            break;
        case WSPRErrorDomainWindows:
        {
            //Not handled yet
        }
            break;
    }
    return @"";
}


@end
