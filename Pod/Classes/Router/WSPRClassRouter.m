//
//  WSPRClassRouter.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 11/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRClassRouter.h"
#import "WSPRInstanceRegistry.h"
#import "WSPRExceptionHandler.h"
#import "WSPRGatewayRouter.h"

@interface WSPRClassRouter () <WSPRClassInstanceDelegate>

@property (nonatomic, strong) WSPRClass *classModel;
@property (nonatomic, strong) NSMutableArray *ownedInstances;

@end

@implementation WSPRClassRouter

#pragma mark - Life cycle

+(instancetype)routerWithClass:(Class<WSPRClassProtocol>)aClass
{
    return [[[self class] alloc] initWithClass:aClass];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.ownedInstances = [NSMutableArray array];
    }
    return self;
}

-(instancetype)initWithClass:(Class<WSPRClassProtocol>)aClass
{
    self = [self init];
    if (self)
    {
        self.classModel = [aClass rpcRegisterClass];
    }
    return self;
}

-(void)dealloc
{
    //Flush all instances owned directly by this router
    [self flushInstances];
}

#pragma mark - WSPRRouteProtocol

-(void)route:(WSPRNotification *)message toPath:(NSString *)path
{
    WSPRCallType callType = [[self class] callTypeFromMethodString:message.method];
    switch (callType) {
        case WSPRCallTypeCreate:
            [self handleCreateInstance:message];
            break;
        case WSPRCallTypeDestroy:
        {
            WSPRClassInstance *wisperInstance = [WSPRInstanceRegistry instanceWithId:[message.params firstObject] underRootRoute:[self rootRouter]];
            if (!wisperInstance)
                [[WSPRException exceptionWithErrorDomain:WSPRErrorDomainRemoteObject code:-1 originalException:nil andDescription:[NSString stringWithFormat:@"No instance with id: %@", [message.params firstObject]]] raise];
            
            @try {
                [self handleDestroyInstance:message];
            }
            @catch (NSException *exception) {
                // Silence exception, an exception here should only be possible from dealloc in the remote object and we simply consider the object removed anyway
            }
            break;
        }
        case WSPRCallTypeStatic:
        {
            NSString *methodName = [WSPRHelper methodNameFromMethodString:message.method];
            WSPRClassMethod *staticMethod = self.classModel.staticMethods[methodName];
            
            if (!staticMethod)
                [[WSPRException exceptionWithErrorDomain:WSPRErrorDomainRemoteObject code:-1 originalException:nil andDescription:[NSString stringWithFormat:@"No such method: %@", message.method]] raise];
            
            [self handleCallToMethod:staticMethod onInstance:nil fromNotification:message];
            break;
        }
        case WSPRCallTypeInstance:
        {
            NSString *methodName = [WSPRHelper methodNameFromMethodString:message.method];
            WSPRClassMethod *instanceMethod = self.classModel.instanceMethods[methodName];
            
            if (!instanceMethod)
                [[WSPRException exceptionWithErrorDomain:WSPRErrorDomainRemoteObject code:-1 originalException:nil andDescription:[NSString stringWithFormat:@"No such method: %@", message.method]] raise];
            
            WSPRClassInstance *instance = [WSPRInstanceRegistry instanceWithId:[message.params firstObject] underRootRoute:[self rootRouter]];
            
            if (!instance)
                [[WSPRException exceptionWithErrorDomain:WSPRErrorDomainRemoteObject code:-1 originalException:nil andDescription:[NSString stringWithFormat:@"No instance with id: %@", [message.params firstObject]]] raise];

            [self handleCallToMethod:instanceMethod onInstance:instance fromNotification:message];
            break;
        }
        case WSPRCallTypeStaticEvent:
        {
            WSPREvent *event = [[WSPREvent alloc] initWithNotification:message];
            [self.classModel.classRef rpcHandleStaticEvent:event];
            
            if ([message isKindOfClass:[WSPRRequest class]])
            {
                WSPRRequest *request = (WSPRRequest *)message;
                WSPRResponse *response = [request createResponse];
                response.result = event.name;
                request.responseBlock(response);
            }
            break;
        }
        case WSPRCallTypeInstanceEvent:
        {
            WSPREvent *event = [[WSPREvent alloc] initWithNotification:message];
            WSPRClassInstance *instance = [WSPRInstanceRegistry instanceWithId:[message.params firstObject] underRootRoute:[self rootRouter]];

            //Set properties if we have any properties with this event name
            [instance handlePropertyEvent:event];
            
            //Fire method on instance WSPRClassProtocol
            if ([instance.instance respondsToSelector:@selector(rpcHandleInstanceEvent:)])
            {
                [instance.instance rpcHandleInstanceEvent:event];
            }
            
            if ([message isKindOfClass:[WSPRRequest class]])
            {
                WSPRRequest *request = (WSPRRequest *)message;
                WSPRResponse *response = [request createResponse];
                response.result = event.name;
                request.responseBlock(response);
            }
            break;
        }
        default:
            //We don't know what to do so leave it to super
            [super route:message toPath:path];
            break;
    }
}


#pragma mark - Private Actions

-(void)handleCreateInstance:(WSPRNotification *)message
{
    Class classPointer = self.classModel.classRef;
    NSObject<WSPRClassProtocol> *instance = [classPointer alloc];
    
    //Have the class supplied its own initializer?
    WSPRClassMethod *createMethod = self.classModel.instanceMethods[@"~"] ? : self.classModel.staticMethods[@"~"];
    if (createMethod)
    {
        WSPRClassInstance *wisperInstance = [self internalAddInstance:instance];
        
        if (createMethod.callBlock)
        {
            //try to run the callblock method and catch if any exception occurs
            @try {
                createMethod.callBlock(self, wisperInstance, createMethod, message);
            }
            @catch (NSException *exception)
            {
                id<WSPRRouteProtocol> rootRouter = [self rootRouter];
                WSPRGateway *gateway = [rootRouter isKindOfClass:[WSPRGatewayRouter class]] ? [(WSPRGatewayRouter *)rootRouter gateway] : nil;

                [WSPRExceptionHandler handleException:exception withMessage:message underGateway:gateway];
            }
            
            return;
        }
        else
        {
            [self invokeMethod:createMethod withParams:message.params onTarget:instance completion:^(id result, WSPRError *error) {
                if ([message isKindOfClass:[WSPRRequest class]])
                {
                    WSPRRequest *request = (WSPRRequest *)message;
                    
                    //Make the response
                    WSPRResponse *response = [request createResponse];
                    response.result = @{@"id" : wisperInstance.instanceIdentifier, @"props" : [self nonNilPropsFromInstance:wisperInstance]};
                    request.responseBlock(response);
                }
            }];
        }
    }
    else
    {
        //Use default initializer
        instance = [instance init];
        
        //Add instance after initializing to avoid events for all properties set in init and protecting instance variables from changes before init has been called.
        WSPRClassInstance *wisperInstance = [self internalAddInstance:instance];
        
        if ([message isKindOfClass:[WSPRRequest class]])
        {
            WSPRRequest *request = (WSPRRequest *)message;
            //Make the response
            WSPRResponse *response = [request createResponse];
            response.result = @{@"id" : wisperInstance.instanceIdentifier, @"props" : [self nonNilPropsFromInstance:wisperInstance]};
            request.responseBlock(response);
        }
    }
}

-(void)handleDestroyInstance:(WSPRNotification *)message
{
    WSPRClassInstance *wisperInstance = [WSPRInstanceRegistry instanceWithId:[message.params firstObject] underRootRoute:[self rootRouter]];
    [self destroyInstance:wisperInstance];
    
    if ([message isKindOfClass:[WSPRRequest class]])
    {
        WSPRRequest *request = (WSPRRequest *)message;
        
        WSPRResponse *response = [request createResponse];
        response.result = [message.params firstObject];
        request.responseBlock(response);
    }
}

-(void)handleCallToMethod:(WSPRClassMethod *)method onInstance:(WSPRClassInstance *)instance fromNotification:(WSPRNotification *)notification
{
    if (method.callBlock)
    {
        //try to run the callblock method and catch if any exception occurs
        @try {
            method.callBlock(self, instance, method, notification);
        }
        @catch (NSException *exception)
        {
            id<WSPRRouteProtocol> rootRouter = [self rootRouter];
            WSPRGateway *gateway = [rootRouter isKindOfClass:[WSPRGatewayRouter class]] ? [(WSPRGatewayRouter *)rootRouter gateway] : nil;
            [WSPRExceptionHandler handleException:exception withMessage:notification underGateway:gateway];
        }
        
        return;
    }
    
    [self invokeMethod:method withParams:instance ? [notification.params subarrayWithRange:NSMakeRange(1, notification.params.count-1)] : notification.params onTarget:instance ? instance.instance : (Class)self.classModel.classRef completion:^(id result, WSPRError *error) {
        
        if ([notification isKindOfClass:[WSPRRequest class]])
        {
            WSPRRequest *request = (WSPRRequest *)notification;
            WSPRResponse *response = [request createResponse];
            response.result = result;
            response.error = error;
            request.responseBlock(response);
        }
        else if (error)
        {
            WSPRErrorMessage *errorMessage = [WSPRErrorMessage message];
            errorMessage.error = error;
            [self reverse:errorMessage fromPath:nil];
        }
    }];
}

/**
 *  Abstraction of the invokation part of the remote object method call
 *  @param method The WSPRClassMethod you want to invoke, either instance or static.
 *  @param target A pointer to the actual instance or static class to run invoke on.
 *  @param completion The returned value of the method
 */
-(void)invokeMethod:(WSPRClassMethod *)method withParams:(NSArray *)params onTarget:(id)target completion:(void(^)(id result, WSPRError *error))completion
{
    //Create an invocation
    NSMethodSignature *methodSignature = [target methodSignatureForSelector:method.selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    __unsafe_unretained id returnedObject = nil;
    WSPRAsyncReturnBlock asyncReturnBlock = nil;
    
    //Retain all arguments when calling the method (ARC fix)
    [invocation retainArguments];
    
    //Set the selector
    [invocation setSelector:method.selector];
    
    //Set the object/class to perform the selector on
    [invocation setTarget:target];
    
    //Param count validation
    NSInteger expectedNumberOfMethodParams = method.paramTypes.count;
    for (NSString *paramType in method.paramTypes)
    {
        if ([paramType isEqualToString:WSPR_PARAM_TYPE_ASYNC_RETURN_BLOCK] || [paramType isEqualToString:WSPR_PARAM_TYPE_CALLER])
        {
            expectedNumberOfMethodParams--;
        }
    }
    
    //Param count validation
    if (method.paramTypes && expectedNumberOfMethodParams != params.count)
    {
        [[WSPRException exceptionWithErrorDomain:WSPRErrorDomainRemoteObject
                                            code:WSPRErrorRemoteObjectInvalidArguments
                               originalException:nil
                                  andDescription:[NSString stringWithFormat:@"Number of arguments does not match receiving procedure. Expected: %lu, Got: %lu", (unsigned long)method.paramTypes.count, (unsigned long)params.count]] raise];
    }
    
    NSInteger messageParamIndex = 0;
    NSInteger argumentIndex = 0;
    for (NSString *paramType in method.paramTypes)
    {
        __unsafe_unretained id argument = nil;
        
        if ([paramType isEqualToString:WSPR_PARAM_TYPE_INSTANCE])
        {
            //Accept NSNull
            if (![params[messageParamIndex] isKindOfClass:[NSNull class]])
            {
                //Lookup instance
                WSPRClassInstance *instanceModel = [WSPRInstanceRegistry instanceWithId:params[messageParamIndex] underRootRoute:[self rootRouter]];
                
                if (!instanceModel)
                {
                    [[WSPRException exceptionWithErrorDomain:WSPRErrorDomainRemoteObject
                                                        code:WSPRErrorRemoteObjectInvalidArguments
                                           originalException:nil
                                              andDescription:[NSString stringWithFormat:@"No reference for ID: %@", params[messageParamIndex]]] raise];
                }
                argument = instanceModel.instance;
            }
            messageParamIndex++;
        }
        else if ([paramType isEqualToString:WSPR_PARAM_TYPE_CALLER])
        {
            argument = self;
        }
        else if ([paramType isEqualToString:WSPR_PARAM_TYPE_ASYNC_RETURN_BLOCK])
        {
            __block BOOL calledOnce = NO;
            asyncReturnBlock = ^(id result, WSPRError *error) {
                if (calledOnce)
                    return;
                
                calledOnce = YES;
                completion(result, error);
            };
            argument = asyncReturnBlock;
        }
        else
        {
            argument = params[messageParamIndex];
            messageParamIndex++;
        }
        
        //Individual argument validation
        if (![WSPRHelper paramType:paramType matchesArgument:argument])
        {
            [[WSPRException exceptionWithErrorDomain:WSPRErrorDomainRemoteObject
                                                code:WSPRErrorRemoteObjectInvalidArguments
                                   originalException:nil
                                      andDescription:[NSString stringWithFormat:@"Argument type sent to procedure does not match expected type. Expected arguments: %@", method.paramTypes]] raise];
        }
        
        [invocation setArgument:&argument atIndex:argumentIndex + 2]; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
        argumentIndex++;
    }
    
    //try the invocation and listen for any exception
    @try {
        [invocation invoke];
    }
    @catch (NSException *exception) {
        [[WSPRException exceptionWithErrorDomain:WSPRErrorDomainiOS_OSX
                                           code:-1
                              originalException:exception
                                 andDescription:@"Method Invocation Error"] raise];
    }
    
    BOOL isVoidReturn = (strncmp([methodSignature methodReturnType], "v", 1) == 0);
    if (!isVoidReturn)
    {
        [invocation getReturnValue:&returnedObject];
    }
    
    if (!asyncReturnBlock)
    {
        completion(returnedObject, nil);
    }
}

-(WSPRClassInstance *)internalAddInstance:(id<WSPRClassProtocol>)instance
{
    instance.classRouter = self;
    
    NSString *key = [NSString stringWithFormat:@"%p", instance];
    
    WSPRClassInstance *wisperInstance = [[WSPRClassInstance alloc] init];
    wisperInstance.rpcClass = self.classModel;
    wisperInstance.instance = instance;
    wisperInstance.instanceIdentifier = key;
    wisperInstance.delegate = self;
    
    [WSPRInstanceRegistry addInstance:wisperInstance underRootRoute:[self rootRouter]];
    [self.ownedInstances addObject:key];
    return wisperInstance;
}

-(void)destroyInstance:(WSPRClassInstance *)instance
{
    //Remove the delegate of the rpcClassInstance so that no more autogenerated notifications/events can be created.
    instance.delegate = nil;
    
    //First run the rpcDestructor method where we allow the object perform extra behaviour like removing modal views or similar.
    if ([instance.instance respondsToSelector:@selector(rpcDestructor)])
    {
        @try {
            [instance.instance rpcDestructor];
        }
        @catch (NSException *exception) {
            // Silence exception, we consider it OK for an object to throw in this method since we are destroying it anyway.
        }
    }
    
    //Second we remove the connections from the instance to the rest of wisper (we do this after -rpcDestructor so that the object still has references to the things it might need)
    [instance.instance setClassRouter:nil];
    
    //Lastly we remove the last reference which in turn deallocates the instance.
    [WSPRInstanceRegistry removeInstance:instance underRootRoute:[self rootRouter]];
    
    if ([self.ownedInstances containsObject:instance.instanceIdentifier])
        [self.ownedInstances removeObject:instance.instanceIdentifier];
}


#pragma mark - Public Actions

-(WSPRClassInstance *)addInstance:(id<WSPRClassProtocol>)instance
{
    WSPRClassInstance *wisperInstance = [self internalAddInstance:instance];
    
    WSPREvent *event = [[WSPREvent alloc] init];
    event.name = @"~";
    event.data = @{@"id" : wisperInstance.instanceIdentifier, @"props" : [self nonNilPropsFromInstance:wisperInstance]};
    [self reverse:[event createNotification] fromPath:event.mapName];
    
    return wisperInstance;
}

-(void)removeInstance:(WSPRClassInstance *)instance
{
    [self destroyInstance:instance];
    
    WSPREvent *event = [[WSPREvent alloc] init];
    event.name = @"~";
    event.instanceIdentifier = instance.instanceIdentifier;
    [self reverse:[event createNotification] fromPath:event.mapName];
}

-(void)flushInstances
{
    //Avoid mutating array while enumerating
    NSArray *ids = [NSArray arrayWithArray:self.ownedInstances];
    for (NSString *key in ids)
    {
        WSPRClassInstance *instance = [WSPRInstanceRegistry instanceWithId:key underRootRoute:[self rootRouter]];
        [self removeInstance:instance];
        
        //Instance could not be found (most likely since root router was deallocated)
        if (!instance)
        {
            [WSPRInstanceRegistry forceRemoveInstanceWithId:key];
        }
    }
}


#pragma mark - WSPRClassInstanceDelegate

-(void)classInstance:(WSPRClassInstance *)classInstance didCreatePropertyEvent:(WSPREvent *)event
{
    event.mapName = self.routeNamespace;
    [self.parentRoute reverse:[event createNotification] fromPath:nil];
}


#pragma mark - Helpers

-(NSDictionary *)nonNilPropsFromInstance:(WSPRClassInstance *)classInstance
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    WSPRClass *classRepresentation = classInstance.rpcClass;
    for (NSString *propertyName in [classRepresentation.properties allKeys])
    {
        WSPRClassProperty *property = classRepresentation.properties[propertyName];
        
        NSObject *propertyValue = [classInstance.instance valueForKeyPath:property.keyPath];
        
        if (propertyValue)
        {
            if ([property.type isEqualToString:WSPR_PARAM_TYPE_INSTANCE])
            {
                WSPRClassInstance *propertyInstance = [WSPRInstanceRegistry instanceModelForInstance:(NSObject<WSPRClassProtocol> *)propertyValue underRootRoute:[self rootRouter]];
                propertyValue = propertyInstance.instanceIdentifier;
            }
            
            if (property.serializeWisperPropertyBlock)
            {
                propertyValue = property.serializeWisperPropertyBlock(propertyValue);
            }
            
            dictionary[propertyName] = propertyValue;
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
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


@end
