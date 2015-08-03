//
//  WSRPCError.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 27/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WSRPCErrorDomain)
{
    WSRPCErrorDomainJavaScript = 0,
    WSRPCErrorDomainRPC = 1,
    WSRPCErrorDomainRemoteObject = 2,
    WSRPCErrorDomainAction = 3,
    WSRPCErrorDomainiOS_OSX = 10,
    WSRPCErrorDomainAndroid = 20,
    WSRPCErrorDomainWindows = 30
};

typedef NS_ENUM(NSInteger, WSRPCErrorJavascript)
{
    WSRPCErrorJavascriptError = 0,
    WSRPCErrorJavascriptEval,
    WSRPCErrorJavascriptRange,
    WSRPCErrorJavascriptReference,
    WSRPCErrorJavascriptSyntax,
    WSRPCErrorJavascriptType,
    WSRPCErrorJavascriptURI
};

typedef NS_ENUM(NSInteger, WSRPCErrorRPC)
{
    WSRPCErrorRPCError = 0,
    WSRPCErrorRPCParseError,
    WSRPCErrorRPCFormatError,
    WSRPCErrorMissingProcedure,
    WSRPCErrorRPCInvalidMessageType
};

typedef NS_ENUM(NSInteger, WSRPCErrorRemoteObject)
{
    WSRPCErrorRemoteObjectMissingClass = 0,
    WSRPCErrorRemoteObjectInvalidInstance,
    WSRPCErrorRemoteObjectMissingProcedure,
    WSRPCErrorRemoteObjectInvalidArguments,
    WSRPCErrorRemoteObjectInvalidModifier
};

typedef NS_ENUM(NSInteger, WSRPCErrorAction)
{
    WSRPCErrorActionAppNotFound = 0,
    WSRPCErrorActionOpenGLNotSupported,
    WSRPCErrorActionGyroNotSupported
};


/**
 Object to represent an error as part of a WSRPCResponse.
 @see https://docs.google.com/a/widespace.com/document/d/1PcRFU59FAokaOJyb1x0Bd_r0sqO-Vrv2EWO5aDD-UoA/
 @see WSRPCController
 */
@interface WSRPCError : NSObject

/**
 The error domain of this error.
 Examples:
 0      JavaScript      Originated in generic JavaScript.
 1      RPC             Error caused by parsing, sending, interpreting RPC Requests/Responses.
 2      RemoteObject    Originated when attempting to handle RemoteObjects.
 10     iOS/OSX         Originated in native Objective-C.
 20     Android         Originated in native Android code.
 30     Windows         Originated in native Windows code.
 */
@property (nonatomic, assign) WSRPCErrorDomain domain;

/**
 The error code 
 Please use one of the enums WSRPCErrorRPC or WSRPCErrorRemoteObject.
 */
@property (nonatomic, assign) NSInteger code;

/**
 The name of the error in human readable form. 
 Parsed from the domain and code.
 */
@property (nonatomic, readonly) NSString *name;

/**
 The error message, should describe what went wrong.
 */
@property (nonatomic, strong) NSString *message;

/**
 Optional: User provided data for what else might be interesting about the error.
 */
@property (nonatomic, strong) NSDictionary *data;

/**
 Optional: If this error was caused by another error the underlying error might be set giving the receiver a better understanding of what whent wrong.
 */
@property (nonatomic, strong) WSRPCError *underlyingError;

/**
 Convenience method for creating an error without calling alloc.
 */
+(instancetype)error;

/**
 Convenience method for creating an error without calling alloc and also initializing it with a dictionary containing all properties you want to set.
 @param dictionary An NSDictionary containing keys and values for all properties you want to set.
 */
+(instancetype)errorWithDictionary:(NSDictionary *)dictionary;

/**
 Method for initializing the error object with a dictionary.
 @param dictionary An NSDictionary containing keys and values for all properties you want to set.
 */
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;


/**
 Convenience method for creating an error without calling alloc and also initializing it based on domain and code, you should fill out other
 information like message, date and underlying error your self.
 @param domain The domain that this error occured in.
 @param code A code for the error inside the domain, provide one of the Enums for code under respecive domain.
 */
+(instancetype)errorWithDomain:(WSRPCErrorDomain)domain andCode:(NSInteger)code;

/**
 Method for initializing an error based on domain and code, you should fill out other information like message, date and underlying error your self.
 @param domain The domain that this error occured in.
 @param code A code for the error inside the domain, provide one of the Enums for code under respecive domain.
 */
-(instancetype)initWithDomain:(WSRPCErrorDomain)domain andCode:(NSInteger)code;

/**
 Create a dictionary representation of this error.
 */
-(NSDictionary *)asDictionary;

/**
 Create a JSON string representation of this error.
 */
-(NSString *)asJSONString;

/**
 Domain as string representation.
 */
-(NSString *)domainName;

/**
 Error code as string representation.
 */
-(NSString *)errorCodeName;

@end
