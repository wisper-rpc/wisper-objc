//
//  WSPRClassRouter.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 11/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRClassRouter.h"
#import "WSPRInstanceRegistry.h"

@interface WSPRClassRouter () <WSPRClassInstanceDelegate>

@property (nonatomic, strong) WSPRClass *classModel;

@end

@implementation WSPRClassRouter

#pragma mark - Life cycle

+(instancetype)routerWithClass:(Class<WSPRClassProtocol>)aClass
{
    return [[[self class] alloc] initWithClass:aClass];
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


#pragma mark - WSPRRouteProtocol

-(void)route:(WSPRNotification *)message toPath:(NSString *)path
{
    WSPRCallType callType = [[self class] callTypeFromMethodString:message.method];
    switch (callType) {
        case WSPRCallTypeCreate:
            [self handleCreateInstance:message];
            break;
        case WSPRCallTypeDestroy:
            [self handleDestroyInstance:message];
            break;
        case WSPRCallTypeStatic:
        {
            NSString *methodName = [WSPRHelper methodNameFromMethodString:message.method];
            WSPRClassMethod *staticMethod = self.classModel.staticMethods[methodName];
            [self handleCallToMethod:staticMethod onInstance:nil fromNotification:message];
            break;
        }
        case WSPRCallTypeInstance:
        {
            NSString *methodName = [WSPRHelper methodNameFromMethodString:message.method];
            WSPRClassMethod *instanceMethod = self.classModel.instanceMethods[methodName];
            WSPRClassInstance *instance = [WSPRInstanceRegistry instanceWithId:[message.params firstObject] underRootRoute:[self rootRouter]];
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
        WSPRClassInstance *wisperInstance = [self addInstance:instance];
        
        if (createMethod.callBlock)
        {
            //try to run the callblock method and catch if any exception occurs
            @try {
                createMethod.callBlock(self, wisperInstance, createMethod, message);
            }
            @catch (NSException *exception)
            {
                //[self handleInvocationException:exception andMessage:@"CallBlock Invocation Error" forRemoteObjectCall:remoteObjectCall];
            }
            @finally {}
            
            return;
        }
        else
        {
            [self invokeMethod:createMethod withParams:message.params onTarget:instance completion:^(id result, WSPRError *error) {
                if (error)
                {
                    //[self sendRPCError:error forRemoteObjectCall:remoteObjectCall asGlobal:NO];
                    return;
                }
                
                
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
        WSPRClassInstance *wisperInstance = [self addInstance:instance];
        
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
            //[self handleInvocationException:exception andMessage:@"CallBlock Invocation Error" forRemoteObjectCall:remoteObjectCall];
        }
        @finally {}
        
        return;
    }
    
    [self invokeMethod:method withParams:instance ? [notification.params subarrayWithRange:NSMakeRange(1, notification.params.count-1)] : notification.params onTarget:instance ? instance.instance : (Class)self.classModel.classRef completion:^(id result, WSPRError *error) {
        if (error)
        {
            //[self sendRPCError:error forRemoteObjectCall:remoteObjectCall asGlobal:NO];
            return;
        }
        
        if ([notification isKindOfClass:[WSPRRequest class]])
        {
            WSPRRequest *request = (WSPRRequest *)notification;
            WSPRResponse *response = [request createResponse];
            response.result = result;
            request.responseBlock(response);
        }
    }];
}

/**
 *  Abstraction of the invokation part of the remote object method call
 *  @param method The WSPRClassMethod you want to invoke, either instance or static.
 *  @param target A pointer to the actual instance or static class to run invoke on.
 *  @param completion The returned value of the method
 */
-(void)invokeMethod:(WSPRClassMethod *)method withParams:(NSArray *)params onTarget:(id)target completion:(void (^)(id result, WSPRError *error))completion
{
    //Create an invocation
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:method.selector]];
    __unsafe_unretained id returnedObject = nil;
    
    //Retain all arguments when calling the method (ARC fix)
    [invocation retainArguments];
    
    //Set the selector
    [invocation setSelector:method.selector];
    
    //Set the object/class to perform the selector on
    [invocation setTarget:target];
    
    //Param count validation
    if (method.paramTypes && method.paramTypes.count != params.count)
    {
        WSPRError *error = [WSPRError errorWithDomain:WSPRErrorDomainRemoteObject andCode:WSPRErrorRemoteObjectInvalidArguments];
        error.message = [NSString stringWithFormat:@"Number of arguments does not match receiving procedure. Expected: %lu, Got: %lu", (unsigned long)method.paramTypes.count, (unsigned long)params.count];
        completion(nil, error);
        return;
    }
    for (NSUInteger i = 0; i < params.count; i++)
    {
        __unsafe_unretained id argument = nil;
        
        if ([method.paramTypes[i] isEqualToString:WSPR_PARAM_TYPE_INSTANCE])
        {
            //Accept NSNull
            if (![params[i] isKindOfClass:[NSNull class]])
            {
                //Lookup instance
                WSPRClassInstance *instanceModel = [WSPRInstanceRegistry instanceWithId:params[i] underRootRoute:[self rootRouter]];
                
                if (!instanceModel)
                {
                    WSPRError *error = [WSPRError errorWithDomain:WSPRErrorDomainRemoteObject andCode:WSPRErrorRemoteObjectInvalidArguments];
                    error.message = [NSString stringWithFormat:@"No reference for ID: %@", params[i]];
                    completion(nil, error);
                    return;
                }
                argument = instanceModel.instance;
            }
        }
        else
        {
            argument = params[i];
        }
        
        //Individual argument validation
        if (![WSPRHelper paramType:method.paramTypes[i] matchesArgument:argument])
        {
            WSPRError *error = [WSPRError errorWithDomain:WSPRErrorDomainRemoteObject andCode:WSPRErrorRemoteObjectInvalidArguments];
            error.message = [NSString stringWithFormat:@"Argument type sent to procedure does not match expected type. Expected arguments: %@", method.paramTypes];
            completion(nil, error);
            return;
        }
        
        [invocation setArgument:&argument atIndex:i + 2]; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
    }
    
    //try the invocation and listen for any exception
    @try {
        [invocation invoke];
    }
    @catch (NSException *exception) {
        
        WSPRError *error = [WSPRError errorWithDomain:WSPRErrorDomainiOS_OSX andCode:0];
        error.message = @"Method Invocation Error";
        error.data = @{
                       @"exception" : @{
                               @"name" : exception.name,
                               @"reason" : exception.reason
                               }
                       };
        completion(nil, error);
        return;
        
    }
    @finally {}
    
    if (!method.isVoidReturn)
    {
        [invocation getReturnValue:&returnedObject];
    }
    
    completion(returnedObject, nil);
}












-(WSPRClassInstance *)addInstance:(id<WSPRClassProtocol>)instance
{
    instance.rpcController = self;
    
    NSString *key = [NSString stringWithFormat:@"%p", instance];
    
    WSPRClassInstance *wisperInstance = [[WSPRClassInstance alloc] init];
    wisperInstance.rpcClass = self.classModel;
    wisperInstance.instance = instance;
    wisperInstance.instanceIdentifier = key;
    wisperInstance.delegate = self;
    
    [WSPRInstanceRegistry addInstance:wisperInstance underRootRoute:[self rootRouter]];
    return wisperInstance;
}

-(BOOL)removeInstance:(WSPRClassInstance *)instance
{
    //TODO: Tell the other endpoint that we have removed the object!
    
    //Do we have the instance?
    WSPRClassInstance *wisperInstance = [WSPRInstanceRegistry instanceWithId:instance.instanceIdentifier underRootRoute:[self rootRouter]];

    if (!wisperInstance)
        return NO;
    
    //Unregister
    wisperInstance.delegate = nil;
    wisperInstance.instance.rpcController = nil;
    
    //Remove the instance
    [WSPRInstanceRegistry removeInstance:wisperInstance underRootRoute:[self rootRouter]];
    
    return YES;
}

-(void)flushInstances
{
    //TODO: This needs to get some solution!
    
    //Avoid mutating dictionary while enumerating
//    NSArray *keys = _instanceMap.allKeys;
//    for (NSString *key in keys)
//    {
//        WSPRClassInstance *rpcInstance = _instanceMap[key];
//        [self destroyInstance:rpcInstance];
//    }
//    [_instanceMap removeAllObjects];
}


#pragma mark - WSPRClassInstanceDelegate

-(void)classInstance:(WSPRClassInstance *)classInstance didCreatePropertyEvent:(WSPREvent *)event
{
    [self.parentRoute reverse:[event createNotification] fromPath:nil];
}


#pragma mark - Helpers

-(void)destroyInstance:(WSPRClassInstance *)instance
{
    //Remove the delegate of the rpcClassInstance so that no more autogenerated notifications/events can be created.
    instance.delegate = nil;
    
    //First run the rpcDestructor method where we allow the object perform extra behaviour like removing modal views or similar.
    if ([instance.instance respondsToSelector:@selector(rpcDestructor)])
    {
        [instance.instance rpcDestructor];
    }
    
    //Second we remove the connections from the instance to the rest of the SDK (we do this after -rpcDestructor so that the object still has references to the AdSpace and other necessary objects)
    [instance.instance setRpcController:nil];
    
    //Lastly we remove the last reference which in turn deallocates the instance.
    [WSPRInstanceRegistry removeInstance:instance underRootRoute:[self rootRouter]];
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
