//
//  WSRPCHelper.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 11/06/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSRPCClassMethod.h"
#import "WSRPCRemoteObjectCall.h"

/**
 Helper class designed to maintain functions that parses and validates various RPC related objects.
 This class should only have static methods and can be used by all other RPC classes.
 */
@interface WSRPCHelper : NSObject

/**
 Compares if the argument passed is of the matching param type.
 @param paramType A string representing a valid RPC param type.
 ###Use one of the constants:###
 * RPC_PARAM_TYPE_STRING
 * RPC_PARAM_TYPE_NUMBER
 * RPC_PARAM_TYPE_ARRAY
 * RPC_PARAM_TYPE_DICTIONARY
 
 @param argument An object passed as the argument to some RPC method. This objects class will be 
 checked agains the class mathing ont of the paramType strings.

 @return YES if argument is same kind or subclass of paramType.
 */
+(BOOL)paramType:(NSString *)paramType matchesArgument:(id)argument;

/**
 Parses the intended call type from the passed method string
 @see Google Drive document "RPC>The Protocol".
 @param method The full method string.
 @return A call type representing what the method tries to accomplish.
 */
+(WSRPCCallType)callTypeFromMethodString:(NSString *)method;

/**
 Parses the class name from the method string.
 ex. "wisp.ai.Video:~" gives us "wisp.ai.Video".
 @param method The full method string.
 @return A string representing the intended class to be called.
 */
+(NSString *)classNameFromMethodString:(NSString *)method;

/**
 Parses the method name from the method string.
 ex. "wisp.ai.Video:play" gives us "play".
 @param method The full method string.
 @return A string representing the intended method to be called.
 */
+(NSString *)methodNameFromMethodString:(NSString *)method;

/**
 Gives you all components of the method ex. "wisp.ctrl.getEndAction" = ["wisp", "ctrl", "getEndAction"]
 ex. "wisp.ai.Awesome:test" = ["wisp", "ai", "Awesome", "test"]
 @param method The full method string
 @return Array containing all separated components based on "." and ":".
 */
+(NSArray *)methodComponentsFromMethodString:(NSString *)method;

/**
 Gives you all components of the method ex. "wisp.ctrl.getEndAction" = [".", "."]
 ex. "wisp.ai.Awesome:test" = [".", ".", ":"]
 @param method The full method string
 @return Array containing all separators between the components based on "." and ":".
 */
+(NSArray *)methodComponentSeparatorsFromMethodString:(NSString *)method;


@end
