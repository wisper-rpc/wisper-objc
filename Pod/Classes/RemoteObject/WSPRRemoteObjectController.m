//
//  WSPRRemoteObjectController.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 27/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRRemoteObjectController.h"
#import "WSPRRemoteObjectCall.h"
#import "WSPRHelper.h"

@interface WSPRRemoteObjectController () <WSPRClassInstanceDelegate>

/**
 Contains all the class implementations registered with this RPC Controller instance.
 */
@property (nonatomic, strong) NSMutableDictionary *classMap;
@property (nonatomic, strong) NSMutableDictionary *instanceMap;

@property (nonatomic, strong) NSMutableDictionary *proxyMap;

@end

@implementation WSPRRemoteObjectController

-(id)init
{
    self = [super init];
    if (self)
    {
        self.classMap = [NSMutableDictionary dictionary];
        self.instanceMap = [NSMutableDictionary dictionary];
        self.proxyMap = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)dealloc
{
    //Call all destructors if implemented when destroying this controller.
    [self flushInstances];
}

#pragma mark - Handle classes and implementations

-(void)registerClass:(Class<WSPRClassProtocol>)aClass
{
    WSPRClass *rpcClass = [aClass rpcRegisterClass];
    _classMap[rpcClass.mapName] = rpcClass;
}

-(WSPRClass *)getRPCClassForClass:(Class)aClass
{
    for (NSString *key in _classMap)
    {
        WSPRClass *class = _classMap[key];
        if (class.classRef == aClass)
        {
            return class;
        }
    }
    return nil;
}

-(WSPRClassInstance *)getRPCClassInstanceForInstance:(NSObject<WSPRClassProtocol> *)instance
{
    return [self getRPCClassInstanceForInstanceIdentifier:[NSString stringWithFormat:@"%p", instance]];
}

-(WSPRClassInstance *)getRPCClassInstanceForInstanceIdentifier:(NSString *)instanceIdentifier
{
    return _instanceMap[instanceIdentifier];
}

-(void)handleMessage:(WSPRMessage *)message
{
    [super handleMessage:message];
    
    if (![message isKindOfClass:[WSPRNotification class]])
    {
        return;
    }
    
    WSPRRemoteObjectCall *remoteObjectCall = [[WSPRRemoteObjectCall alloc] init];
    if ([message isKindOfClass:[WSPRRequest class]])
    {
        remoteObjectCall.request = (WSPRRequest *)message;
    }
    else if ([message isKindOfClass:[WSPRNotification class]])
    {
        remoteObjectCall.notification = (WSPRNotification *)message;
    }
    
    [self makeCallBasedOnRemoteObjectCall:remoteObjectCall];
}

-(void)makeCallBasedOnRemoteObjectCall:(WSPRRemoteObjectCall *)remoteObjectCall
{
    //Get class and instance now
    WSPRClass *theClass = _classMap[remoteObjectCall.className];
    WSPRClassInstance *rpcInstance = _instanceMap[remoteObjectCall.instanceId];
    WSPRClassMethod *theMethod = nil;
    
    //Class validation
    if (!theClass)
    {
        BOOL handledAsProxyCall = [self makeProxyCallWithRemoteObjectCall:remoteObjectCall];
        if (!handledAsProxyCall)
        {
            //Since this call could not be handled by anything we simply return with an error
            [self handleRPCError:WSPRErrorRemoteObjectMissingClass
                      andMessage:[NSString stringWithFormat:@"No Class found: %@", remoteObjectCall.fullMethod]
             forRemoteObjectCall:remoteObjectCall];
        }
        return;
    }
    
    //Instance validation
    if (remoteObjectCall.callType == WSPRCallTypeInstance || remoteObjectCall.callType == WSPRCallTypeInstanceEvent || remoteObjectCall.callType == WSPRCallTypeDestroy)
    {
        
        if (!rpcInstance || ![rpcInstance.instance isKindOfClass:theClass.classRef])
        {
            [self handleRPCError:WSPRErrorRemoteObjectInvalidInstance
                      andMessage:[NSString stringWithFormat:@"No instance with ID: %@", remoteObjectCall.instanceId]
             forRemoteObjectCall:remoteObjectCall];
            return;
        }
        
        if (![rpcInstance.instance isKindOfClass:theClass.classRef])
        {
            [self handleRPCError:WSPRErrorRemoteObjectInvalidInstance
                      andMessage:[NSString stringWithFormat:@"Instance is not of class: %@", theClass.mapName]
             forRemoteObjectCall:remoteObjectCall];
            return;
        }
    }
    
    //Event validation
    if (remoteObjectCall.callType == WSPRCallTypeInstanceEvent || remoteObjectCall.callType == WSPRCallTypeStaticEvent)
    {
        if (!remoteObjectCall.notification)
        {
            WSPRError *error = [[WSPRError alloc] initWithDomain:WSPRErrorDomainWisper andCode:WSPRErrorRPCInvalidMessageType];
            error.message = @"Message type cannot be request when sending RemoteObject event, must be notification!";
            [self sendRPCError:error forRemoteObjectCall:remoteObjectCall asGlobal:YES];
            return;
        }
    }
    
    //Make call based on call type
    switch (remoteObjectCall.callType)
    {
        case WSPRCallTypeUnknown:
        {
            [self handleRPCError:WSPRErrorRemoteObjectInvalidModifier
                      andMessage:[NSString stringWithFormat:@"Could not determine RemoteObject call type from request: %@", [remoteObjectCall.request description]]
             forRemoteObjectCall:remoteObjectCall];
            return;
        }
            break;
        case WSPRCallTypeCreate:
        {
            [self handleRPCCreateRemoteObject:remoteObjectCall];
            return;
        }
            break;
        case WSPRCallTypeDestroy:
        {
            [self handleRPCDestroyRemoteObject:remoteObjectCall];
            return;
        }
            break;
        case WSPRCallTypeStaticEvent:
        {
            //Fire method on class WSPRClassProtocol
            WSPREvent *event = [[WSPREvent alloc] initWithNotification:remoteObjectCall.notification];
            [theClass.classRef rpcHandleStaticEvent:event];
            return;
        }
            break;
        case WSPRCallTypeInstanceEvent:
        {
            WSPREvent *event = [[WSPREvent alloc] initWithNotification:remoteObjectCall.notification];
            
            //Set properties if we have any properties with this
            [rpcInstance handlePropertyEvent:event];
            
            //Fire method on instance WSPRClassProtocol
            if (remoteObjectCall.notification && [rpcInstance.instance respondsToSelector:@selector(rpcHandleInstanceEvent:)])
            {
                [rpcInstance.instance rpcHandleInstanceEvent:event];
            }
            return;
        }
            break;
        default:
            break;
    }
    
    //Static and Instance method lookup
    if (remoteObjectCall.callType == WSPRCallTypeInstance)
    {
        theMethod = theClass.instanceMethods[remoteObjectCall.methodName];
    }
    else
    {
        theMethod = theClass.staticMethods[remoteObjectCall.methodName];
    }
    
    //Method Validation
    if (!theMethod)
    {
        [self handleRPCError:WSPRErrorRemoteObjectMissingProcedure
                  andMessage:[NSString stringWithFormat:@"No method found with name: %@", remoteObjectCall.request.method]
         forRemoteObjectCall:remoteObjectCall];
        return;
    }

    //Call the method
    [self callMethod:theMethod onInstance:rpcInstance withClass:theClass andRemoteObjectCall:remoteObjectCall];
}

-(void)handleRPCCreateRemoteObject:(WSPRRemoteObjectCall *)remoteObjectCall
{
    WSPRClass *theClass = _classMap[remoteObjectCall.className];
    
    Class classPointer = theClass.classRef;
    NSObject<WSPRClassProtocol> *instance = [classPointer alloc];
    
    //Have the class supplied its own initializer?
    WSPRClassMethod *createMethod = theClass.instanceMethods[@"~"] ? : theClass.staticMethods[@"~"];
    if (createMethod)
    {
        WSPRClassInstance *rpcInstance = [self addRPCObjectInstance:instance withRPCClass:theClass];
        
        if (createMethod.callBlock)
        {
            //try to run the callblock method and catch if any exception occurs
            @try {
                createMethod.callBlock(self, rpcInstance, createMethod, remoteObjectCall.request);
            }
            @catch (NSException *exception)
            {
                [self handleInvocationException:exception andMessage:@"CallBlock Invocation Error" forRemoteObjectCall:remoteObjectCall];
            }
            @finally {}
            
            return;
        }
        else
        {
            [self invokeMethod:createMethod withParams:remoteObjectCall.params onTarget:instance completion:^(id result, WSPRError *error) {
                if (error)
                {
                    [self sendRPCError:error forRemoteObjectCall:remoteObjectCall asGlobal:NO];
                    return;
                }
                
                
                if (remoteObjectCall.request)
                {
                    //Make the response
                    WSPRResponse *response = [remoteObjectCall.request createResponse];
                    response.result = @{@"id" : rpcInstance.instanceIdentifier, @"props" : [self nonNilPropsFromInstance:rpcInstance]};
                    remoteObjectCall.request.responseBlock(response);
                }
            }];
        }
    }
    else
    {
        //Use default initializer
        instance = [instance init];
        
        //Add instance after initializing to avoid events for all properties set in init and protecting instance variables from changes before init has been called.
        WSPRClassInstance *rpcInstance = [self addRPCObjectInstance:instance withRPCClass:theClass];
        
        if (remoteObjectCall.request)
        {
            //Make the response
            WSPRResponse *response = [remoteObjectCall.request createResponse];
            response.result = @{@"id" : rpcInstance.instanceIdentifier, @"props" : [self nonNilPropsFromInstance:rpcInstance]};
            remoteObjectCall.request.responseBlock(response);
        }
    }
}

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
                WSPRClassInstance *propertyInstance = [self getRPCClassInstanceForInstance:(NSObject<WSPRClassProtocol> *)propertyValue];
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

-(void)handleRPCDestroyRemoteObject:(WSPRRemoteObjectCall *)remoteObjectCall
{
    WSPRClassInstance *rpcInstance = _instanceMap[remoteObjectCall.instanceId];
    
    [self destroyInstance:rpcInstance];
    
    if (remoteObjectCall.request)
    {
        WSPRResponse *response = [remoteObjectCall.request createResponse];
        response.result = remoteObjectCall.instanceId;
        remoteObjectCall.request.responseBlock(response);
    }
}

-(void)handleRPCError:(WSPRErrorRemoteObject)errorCode andMessage:(NSString *)message forRemoteObjectCall:(WSPRRemoteObjectCall *)remoteObjectCall
{
    WSPRError *error = [WSPRError errorWithDomain:WSPRErrorDomainRemoteObject andCode:errorCode];
    error.message = message;
    [self sendRPCError:error forRemoteObjectCall:remoteObjectCall asGlobal:YES];
}


-(void)handleInvocationException:(NSException*)exception andMessage:(NSString*)message forRemoteObjectCall:(WSPRRemoteObjectCall *)remoteObjectCall
{
    WSPRError *error = [WSPRError errorWithDomain:WSPRErrorDomainiOS_OSX andCode:0];
    error.message = message;
    error.data = @{
                   @"exception" : @{
                           @"name" : exception.name,
                           @"reason" : exception.reason
                           }
                   };
    
    [self sendRPCError:error forRemoteObjectCall:remoteObjectCall asGlobal:NO];
}

-(void)sendRPCError:(WSPRError *)error forRemoteObjectCall:(WSPRRemoteObjectCall *)remoteObjectCall asGlobal:(BOOL)asGlobal
{
    if (remoteObjectCall.request)
    {
        WSPRResponse *response = [remoteObjectCall.request createResponse];
        response.error = error;
        remoteObjectCall.request.responseBlock(response);
    }
    //TODO: Check asGlobal, potential bug!
    else if (asGlobal || !remoteObjectCall.instanceId)
    {
        WSPRResponse *response = [WSPRResponse message];
        response.error = error;
        [self sendMessage:response];
    }
    else
    {
        //Send back a notification error
        WSPREvent *errorEvent = [[WSPREvent alloc] init];
        errorEvent.mapName = [WSPRHelper classNameFromMethodString:remoteObjectCall.notification.method];
        errorEvent.instanceIdentifier = remoteObjectCall.instanceId;
        errorEvent.name = @"error";
        errorEvent.data = [error asDictionary];
        [self sendMessage:[errorEvent createNotification]];
    }
}


#pragma mark - RPC Actions

-(void)callMethod:(WSPRClassMethod *)method onInstance:(WSPRClassInstance *)rpcInstance withClass:(WSPRClass *)class andRemoteObjectCall:(WSPRRemoteObjectCall *)remoteObjectCall
{
    if (method.callBlock)
    {
        //try to run the callblock method and catch if any exception occurs
        @try {
            method.callBlock(self, rpcInstance, method, remoteObjectCall.request);
        }
        @catch (NSException *exception)
        {
            [self handleInvocationException:exception andMessage:@"CallBlock Invocation Error" forRemoteObjectCall:remoteObjectCall];
        }
        @finally {}
        
        return;
    }
    
    [self invokeMethod:method withParams:remoteObjectCall.params onTarget:rpcInstance ? rpcInstance.instance : (Class)class.classRef completion:^(id result, WSPRError *error) {
        if (error)
        {
            [self sendRPCError:error forRemoteObjectCall:remoteObjectCall asGlobal:NO];
            return;
        }
        
        if (remoteObjectCall.request)
        {
            WSPRResponse *response = [remoteObjectCall.request createResponse];
            response.result = result;
            remoteObjectCall.request.responseBlock(response);
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
                WSPRClassInstance *classInstanceModel = _instanceMap[params[i]];
                
                if (!classInstanceModel)
                {
                    WSPRError *error = [WSPRError errorWithDomain:WSPRErrorDomainRemoteObject andCode:WSPRErrorRemoteObjectInvalidArguments];
                    error.message = [NSString stringWithFormat:@"No reference for ID: %@", params[i]];
                    completion(nil, error);
                    return;
                }
                argument = classInstanceModel.instance;
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

#pragma mark - WSPRClassInstanceDelegate methods

-(void)classInstance:(WSPRClassInstance *)classInstance didCreatePropertyEvent:(WSPREvent *)event
{
    [self sendMessage:[event createNotification]];
}

#pragma mark - Actions

-(WSPRClassInstance *)addRPCObjectInstance:(id<WSPRClassProtocol>)instance withRPCClass:(WSPRClass *)rpcClass
{
    instance.rpcController = self;
    
    NSString *key = [NSString stringWithFormat:@"%p", instance];
    
    WSPRClassInstance *rpcInstance = [[WSPRClassInstance alloc] init];
    rpcInstance.rpcClass = rpcClass;
    rpcInstance.instance = instance;
    rpcInstance.instanceIdentifier = key;
    rpcInstance.delegate = self;
    
    _instanceMap[key] = rpcInstance;
    return rpcInstance;
}

-(BOOL)removeRPCObjectInstance:(WSPRClassInstance *)rpcInstanceRepresentation
{
    //TODO: Tell the other endpoint that we have removed the object!
    
    //Do we have the instance?
    WSPRClassInstance *rpcInstance = _instanceMap[rpcInstanceRepresentation.instanceIdentifier];
    if (!rpcInstance)
        return NO;

    //Unregister
    rpcInstance.delegate = nil;
    rpcInstance.instance.rpcController = nil;
    
    //Remove the instance
    [_instanceMap removeObjectForKey:rpcInstance.instanceIdentifier];
    
    return YES;
}

-(void)flushInstances
{
    //Avoid mutating dictionary while enumerating
    NSArray *keys = _instanceMap.allKeys;
    for (NSString *key in keys)
    {
        WSPRClassInstance *rpcInstance = _instanceMap[key];
        [self destroyInstance:rpcInstance];
    }
    [_instanceMap removeAllObjects];
}

#pragma mark - Helpers

-(void)destroyInstance:(WSPRClassInstance *)rpcClassInstance
{
    //Remove the delegate of the rpcClassInstance so that no more autogenerated notifications/events can be created.
    rpcClassInstance.delegate = nil;

    //First run the rpcDestructor method where we allow the object perform extra behaviour like removing modal views or similar.
    if ([rpcClassInstance.instance respondsToSelector:@selector(rpcDestructor)])
    {
        [rpcClassInstance.instance rpcDestructor];
    }
    
    //Second we remove the connections from the instance to the rest of the SDK (we do this after -rpcDestructor so that the object still has references to the AdSpace and other necessary objects)
    [rpcClassInstance.instance setRpcController:nil];
    
    //Lastly we remove the last reference which in turn deallocates the instance.
    [_instanceMap removeObjectForKey:rpcClassInstance.instanceIdentifier];
}

#pragma mark - Proxies drafting -

-(void)addProxyObject:(WSPRProxy *)proxy
{
    if (_classMap[proxy.mapName])
    {
        //FAIL
    }
    
    self.proxyMap[proxy.mapName] = proxy;
    proxy.controller = self;
}

-(void)removeProxyObject:(WSPRProxy *)proxy
{
    [self removeProxyForPath:proxy.mapName];
}

-(void)removeProxyForPath:(NSString *)path
{
    WSPRProxy *proxy = _proxyMap[path];
    if (!proxy)
    {
        //FAIL
    }
    [_proxyMap removeObjectForKey:path];
    
    //Call the reverse proxy
    proxy.controller = nil;
    [proxy.receiver removeProxyObject:proxy.reverseProxy];
}

/**
 Tries to make a call through a registered proxy if path is handled by one.
 @param remoteObjectCall The call that should be transported over the proxy.
 @return YES if a proxy handled the call, NO if no proxy could be found for the path.
 */
-(BOOL)makeProxyCallWithRemoteObjectCall:(WSPRRemoteObjectCall *)remoteObjectCall
{
    WSPRRequest *request = [remoteObjectCall request];
    
    for (NSString *proxyKey in _proxyMap)
    {
        NSRange range = [request.method rangeOfString:proxyKey];
        if (range.location == 0)
        {
            WSPRProxy *proxy = _proxyMap[proxyKey];
            [proxy handleRequest:request];
            return YES;
        }
    }
    return NO;
}


@end
