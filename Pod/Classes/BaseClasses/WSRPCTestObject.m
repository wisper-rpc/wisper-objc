//
//  WSRPCTestObject.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 16/05/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSRPCTestObject.h"

@implementation WSRPCTestObject

+(WSRPCClass *)rpcRegisterClass
{
    WSRPCClass *classModel = [[WSRPCClass alloc] init];
    classModel.classRef = [self class];
    classModel.mapName = @"wisp.test.TestObject";
    
    WSRPCClassMethod *appendMethod = [[WSRPCClassMethod alloc] init];
    appendMethod.mapName = @"append";
    appendMethod.selector = @selector(appendString:withString:);
    appendMethod.isVoidReturn = NO;
    appendMethod.paramTypes = @[RPC_PARAM_TYPE_STRING, RPC_PARAM_TYPE_STRING];

    WSRPCClassMethod *staticAppendMethod = [[WSRPCClassMethod alloc] init];
    staticAppendMethod.mapName = @"append";
    staticAppendMethod.selector = @selector(appendString:withString:);
    staticAppendMethod.isVoidReturn = NO;
    staticAppendMethod.paramTypes = @[RPC_PARAM_TYPE_STRING, RPC_PARAM_TYPE_STRING];
    
    WSRPCClassProperty *testProperty = [[WSRPCClassProperty alloc] init];
    testProperty.mapName = @"testProperty";
    testProperty.keyPath = @"testProperty";
    testProperty.mode = WSRPCPropertyModeReadWrite;
    testProperty.type = RPC_PARAM_TYPE_STRING;

    WSRPCClassProperty *testPassByReferenceProperty = [[WSRPCClassProperty alloc] init];
    testPassByReferenceProperty.mapName = @"testPassByReferenceProperty";
    testPassByReferenceProperty.keyPath = @"testPassByReferenceProperty";
    testPassByReferenceProperty.mode = WSRPCPropertyModeReadWrite;
    testPassByReferenceProperty.type = RPC_PARAM_TYPE_INSTANCE;
    
    WSRPCClassMethod *echoMethod = [[WSRPCClassMethod alloc] init];
    echoMethod.mapName = @"echo";
    echoMethod.callBlock = ^(WSRPCRemoteObjectController *rpcController, WSRPCClassInstance *instance, WSRPCClassMethod *theMethod, WSRPCRequest *request){
        WSRPCResponse *response = [request createResponse];
        response.result = request.params;
        request.responseBlock(response);
    };
    
    WSRPCClassMethod *echoStringMethod = [[WSRPCClassMethod alloc] init];
    echoStringMethod.mapName = @"echoString";
    echoStringMethod.paramTypes = @[RPC_PARAM_TYPE_STRING];
    echoStringMethod.selector = @selector(echoString:);
    
    WSRPCClassMethod *exceptionStaticMethod = [[WSRPCClassMethod alloc] init];
    exceptionStaticMethod.mapName = @"exceptionInMethodCall";
    exceptionStaticMethod.selector = @selector(exceptionInMethodCall);
    
    WSRPCClassMethod *exceptionMethod = [[WSRPCClassMethod alloc] init];
    exceptionMethod.mapName = @"exceptionInMethodCall";
    exceptionMethod.selector = @selector(exceptionInMethodCall);
    
    WSRPCClassMethod *staticPassByReferenceMethod = [[WSRPCClassMethod alloc] init];
    staticPassByReferenceMethod.mapName = @"passByReference";
    staticPassByReferenceMethod.isVoidReturn = NO;
    staticPassByReferenceMethod.paramTypes = @[RPC_PARAM_TYPE_INSTANCE];
    staticPassByReferenceMethod.selector = @selector(passByReference:);
    
    
    WSRPCClassMethod *passByReferenceMethod = [[WSRPCClassMethod alloc] init];
    passByReferenceMethod.mapName = @"passByReference";
    passByReferenceMethod.isVoidReturn = NO;
    passByReferenceMethod.paramTypes = @[RPC_PARAM_TYPE_INSTANCE];
    passByReferenceMethod.selector = @selector(passByReference:);
    
    [classModel addStaticMethod:echoMethod];
    [classModel addStaticMethod:echoStringMethod];
    [classModel addStaticMethod:staticAppendMethod];
    [classModel addStaticMethod:exceptionStaticMethod];
    [classModel addStaticMethod:staticPassByReferenceMethod];
    [classModel addInstanceMethod:appendMethod];
    [classModel addInstanceMethod:exceptionMethod];
    [classModel addInstanceMethod:passByReferenceMethod];
    [classModel addProperty:testProperty];
    [classModel addProperty:testPassByReferenceProperty];
    
    return classModel;
}

+(NSString *)echoString:(NSString *)message
{
    return message;
}

-(NSString *)appendString:(NSString *)first withString:(NSString *)second
{
    return [first stringByAppendingString:second];
}

+(NSString *)appendString:(NSString *)first withString:(NSString *)second
{
    return [first stringByAppendingString:second];
}

+(void)exceptionInMethodCall
{
    NSException *exception = [NSException exceptionWithName:@"Test Exception" reason:@"Raised for test purposes" userInfo:nil];
    [exception raise];
}

-(void)exceptionInMethodCall
{
    NSException *exception = [NSException exceptionWithName:@"Test Exception" reason:@"Raised for test purposes" userInfo:nil];
    [exception raise];
}

+(NSString *)passByReference:(id<WSRPCClassProtocol>)instance
{
    return [instance description];
}

-(NSString *)passByReference:(id<WSRPCClassProtocol>)instance
{
    return [instance description];
}

@end
