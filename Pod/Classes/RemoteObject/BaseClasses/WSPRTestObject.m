//
//  WSPRTestObject.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 16/05/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRTestObject.h"

@implementation WSPRTestObject

+(WSPRClass *)rpcRegisterClass
{
    WSPRClass *classModel = [[WSPRClass alloc] init];
    classModel.classRef = [self class];
    
    WSPRClassMethod *appendMethod = [[WSPRClassMethod alloc] init];
    appendMethod.mapName = @"append";
    appendMethod.selector = @selector(appendString:withString:);
    appendMethod.paramTypes = @[WSPR_PARAM_TYPE_STRING, WSPR_PARAM_TYPE_STRING];

    WSPRClassMethod *staticAppendMethod = [[WSPRClassMethod alloc] init];
    staticAppendMethod.mapName = @"append";
    staticAppendMethod.selector = @selector(appendString:withString:);
    staticAppendMethod.paramTypes = @[WSPR_PARAM_TYPE_STRING, WSPR_PARAM_TYPE_STRING];
    
    WSPRClassProperty *testProperty = [[WSPRClassProperty alloc] init];
    testProperty.mapName = @"testProperty";
    testProperty.keyPath = @"testProperty";
    testProperty.mode = WSPRPropertyModeReadWrite;
    testProperty.type = WSPR_PARAM_TYPE_STRING;

    WSPRClassProperty *testPassByReferenceProperty = [[WSPRClassProperty alloc] init];
    testPassByReferenceProperty.mapName = @"testPassByReferenceProperty";
    testPassByReferenceProperty.keyPath = @"testPassByReferenceProperty";
    testPassByReferenceProperty.mode = WSPRPropertyModeReadWrite;
    testPassByReferenceProperty.type = WSPR_PARAM_TYPE_INSTANCE;

    WSPRClassProperty *testSerializeProperty = [[WSPRClassProperty alloc] init];
    testSerializeProperty.mapName = @"testSerializeProperty";
    testSerializeProperty.keyPath = @"testSerializeProperty";
    testSerializeProperty.mode = WSPRPropertyModeReadWrite;
    testSerializeProperty.type = WSPR_PARAM_TYPE_DICTIONARY;
    [testSerializeProperty setSerializeWisperPropertyBlock:^id(NSObject *property) {
        CGPoint pointValue = [(NSValue *)property CGPointValue];
        return @{
                 @"x" : @(pointValue.x),
                 @"y" : @(pointValue.y)
                 };
    }];
    [testSerializeProperty setDeserializeWisperPropertyBlock:^id(NSObject *serializedProperty) {
        NSDictionary *pointDictionary = (NSDictionary *)serializedProperty;
        return [NSValue valueWithCGPoint:CGPointMake(
                                                     [pointDictionary[@"x"] floatValue],
                                                     [pointDictionary[@"y"] floatValue]
                                                     )];
    }];
    
    WSPRClassMethod *echoMethod = [[WSPRClassMethod alloc] init];
    echoMethod.mapName = @"echo";
    echoMethod.callBlock = ^(id caller, WSPRClassInstance *instance, WSPRClassMethod *theMethod, WSPRNotification *notification){
        WSPRRequest *request = [notification isKindOfClass:[WSPRRequest class]] ? (WSPRRequest *)notification : nil;
        
        if (!request)
            return;
        
        WSPRResponse *response = [request createResponse];
        response.result = request.params;
        request.responseBlock(response);
    };
    
    WSPRClassMethod *initWithArgsMethod = [[WSPRClassMethod alloc] init];
    initWithArgsMethod.mapName = @"~";
    initWithArgsMethod.paramTypes = @[WSPR_PARAM_TYPE_STRING];
    initWithArgsMethod.selector = @selector(initWithTestPropertyValue:);
    initWithArgsMethod.callBlock = ^(id caller, WSPRClassInstance *instance, WSPRClassMethod *theMethod, WSPRNotification *notification) {
        
        WSPRRequest *request = [notification isKindOfClass:[WSPRRequest class]] ? (WSPRRequest *)notification : nil;
        if (!request)
            return;

        WSPRTestObject *testObject = [(WSPRTestObject *)instance.instance initWithTestPropertyValue:request.params[0]];
        WSPRResponse *response = [request createResponse];
        response.result = @{@"id":instance.instanceIdentifier, @"props":testObject.testProperty ?@{@"testProperty":testObject.testProperty} : @{}};
        request.responseBlock(response);
    };
    
    
    WSPRClassMethod *echoStringMethod = [[WSPRClassMethod alloc] init];
    echoStringMethod.mapName = @"echoString";
    echoStringMethod.paramTypes = @[WSPR_PARAM_TYPE_STRING];
    echoStringMethod.selector = @selector(echoString:);
    
    WSPRClassMethod *exceptionStaticMethod = [[WSPRClassMethod alloc] init];
    exceptionStaticMethod.mapName = @"exceptionInMethodCall";
    exceptionStaticMethod.selector = @selector(exceptionInMethodCall);

    WSPRClassMethod *exceptionStaticBlock = [[WSPRClassMethod alloc] init];
    exceptionStaticBlock.mapName = @"exceptionInMethodBlock";
    exceptionStaticBlock.callBlock = ^(id caller, WSPRClassInstance *instance, WSPRClassMethod *theMethod, WSPRNotification *notification) {
        NSException *exception = [NSException exceptionWithName:@"Test Exception" reason:@"Raised for test purposes" userInfo:nil];
        [exception raise];
    };
    
    WSPRClassMethod *exceptionInstanceBlock = [[WSPRClassMethod alloc] init];
    exceptionInstanceBlock.mapName = @"exceptionInMethodBlock";
    exceptionInstanceBlock.callBlock = ^(id caller, WSPRClassInstance *instance, WSPRClassMethod *theMethod, WSPRNotification *notification) {
        NSException *exception = [NSException exceptionWithName:@"Test Exception" reason:@"Raised for test purposes" userInfo:nil];
        [exception raise];
    };

    WSPRClassMethod *exceptionMethod = [[WSPRClassMethod alloc] init];
    exceptionMethod.mapName = @"exceptionInMethodCall";
    exceptionMethod.selector = @selector(exceptionInMethodCall);
    
    WSPRClassMethod *staticPassByReferenceMethod = [[WSPRClassMethod alloc] init];
    staticPassByReferenceMethod.mapName = @"passByReference";
    staticPassByReferenceMethod.paramTypes = @[WSPR_PARAM_TYPE_INSTANCE];
    staticPassByReferenceMethod.selector = @selector(passByReference:);
    
    WSPRClassMethod *passByReferenceMethod = [[WSPRClassMethod alloc] init];
    passByReferenceMethod.mapName = @"passByReference";
    passByReferenceMethod.paramTypes = @[WSPR_PARAM_TYPE_INSTANCE];
    passByReferenceMethod.selector = @selector(passByReference:);
    
    
    [classModel addStaticMethod:[[WSPRClassMethod alloc] initWithMapName:@"passCaller" selector:@selector(passCaller:) andParamTypes:@[WSPR_PARAM_TYPE_CALLER]]];
    
    [classModel addStaticMethod:[[WSPRClassMethod alloc] initWithMapName:@"passAsyncReturnBlock" selector:@selector(passAsyncReturnBlock:) andParamTypes:@[WSPR_PARAM_TYPE_ASYNC_RETURN_BLOCK]]];
    
    [classModel addStaticMethod:[[WSPRClassMethod alloc] initWithMapName:@"passAsyncReturnBlockAndCaller" selector:@selector(passAsyncReturnBlock:andCaller:) andParamTypes:@[WSPR_PARAM_TYPE_ASYNC_RETURN_BLOCK, WSPR_PARAM_TYPE_CALLER]]];
    
    [classModel addStaticMethod:echoMethod];
    [classModel addStaticMethod:echoStringMethod];
    [classModel addStaticMethod:staticAppendMethod];
    [classModel addStaticMethod:exceptionStaticMethod];
    [classModel addStaticMethod:staticPassByReferenceMethod];
    [classModel addStaticMethod:exceptionStaticBlock];
    [classModel addInstanceMethod:initWithArgsMethod];
    [classModel addInstanceMethod:appendMethod];
    [classModel addInstanceMethod:exceptionMethod];
    [classModel addInstanceMethod:passByReferenceMethod];
    [classModel addInstanceMethod:exceptionInstanceBlock];
    [classModel addProperty:testProperty];
    [classModel addProperty:testPassByReferenceProperty];
    [classModel addProperty:testSerializeProperty];
    
    return classModel;
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        [[self class] mockCall];
    }
    return self;
}

-(instancetype)initWithTestPropertyValue:(NSString *)testString
{
    self = [self init];
    if (self)
    {
        self.testProperty = testString;
    }
    return self;
}

+(void)mockCall
{
    //This method is here to replace in mocks for testing init and dealloc flows
}

-(void)dealloc
{
    [[self class] mockCall];
}

-(void)rpcDestructor
{
    
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

+(NSString *)passByReference:(id<WSPRClassProtocol>)instance
{
    return [instance description];
}

-(NSString *)passByReference:(id<WSPRClassProtocol>)instance
{
    return [instance description];
}

+(NSNumber *)passCaller:(id)caller
{
    return caller ? @YES : @NO;
}

+(void)passAsyncReturnBlock:(WSPRAsyncReturnBlock)asyncReturnBlock
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        asyncReturnBlock(@(YES), nil);
    });
}

+(void)passAsyncReturnBlock:(WSPRAsyncReturnBlock)asyncReturnBlock andCaller:(id)caller
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        asyncReturnBlock(@(caller ? YES : NO), nil);
    });
}

-(void)rpcHandleInstanceEvent:(WSPREvent *)event
{

}


@end
