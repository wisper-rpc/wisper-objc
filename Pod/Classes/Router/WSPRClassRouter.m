//
//  WSPRClassRouter.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 11/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRClassRouter.h"

@interface WSPRClassRouter () <WSPRClassInstanceDelegate>

@property (nonatomic, strong) WSPRClass *classModel;
@property (nonatomic, strong) NSMutableDictionary *instanceMap;

@end

@implementation WSPRClassRouter

#pragma mark - Life cycle
-(instancetype)initWithClass:(Class<WSPRClassProtocol>)aClass
{
    WSPRClass *wisperClass = [aClass rpcRegisterClass];
    self = [self initWithNameSpace:wisperClass.mapName];
    if (self)
    {
        self.classModel = wisperClass;
    }
    return self;
}


#pragma mark - WSPRRouteProtocol

-(void)route:(WSPRNotification *)message toPath:(NSString *)path
{
    WSPRCallType callType = [[self class] callTypeFromMethodString:path];
    switch (callType) {
        case WSPRCallTypeCreate:
            [self handleCreateInstance:message];
            break;
        case WSPRCallTypeDestroy:
            [self handleDestroyInstance:message];
            break;
        case WSPRCallTypeStatic:
            
            break;
        case WSPRCallTypeInstance:
            
            break;
        case WSPRCallTypeStaticEvent:
            
            break;
        case WSPRCallTypeInstanceEvent:
            
            break;
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
        WSPRClassInstance *rpcInstance = [self addRPCObjectInstance:instance];
        
        if (createMethod.callBlock)
        {
            //try to run the callblock method and catch if any exception occurs
            @try {
                createMethod.callBlock(self, rpcInstance, createMethod, message);
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
//            [self invokeMethod:createMethod withParams:remoteObjectCall.params onTarget:instance completion:^(id result, WSPRError *error) {
//                if (error)
//                {
//                    [self sendRPCError:error forRemoteObjectCall:remoteObjectCall asGlobal:NO];
//                    return;
//                }
//                
//                
//                if (remoteObjectCall.request)
//                {
//                    //Make the response
//                    WSPRResponse *response = [remoteObjectCall.request createResponse];
//                    response.result = @{@"id" : rpcInstance.instanceIdentifier, @"props" : [self nonNilPropsFromInstance:rpcInstance]};
//                    remoteObjectCall.request.responseBlock(response);
//                }
//            }];
        }
    }
    else
    {
        //Use default initializer
        instance = [instance init];
        
        //Add instance after initializing to avoid events for all properties set in init and protecting instance variables from changes before init has been called.
        WSPRClassInstance *rpcInstance = [self addRPCObjectInstance:instance];
        
        if ([message isKindOfClass:[WSPRRequest class]])
        {
            WSPRRequest *request = (WSPRRequest *)message;
            //Make the response
            WSPRResponse *response = [request createResponse];
            response.result = @{@"id" : rpcInstance.instanceIdentifier, @"props" : [self nonNilPropsFromInstance:rpcInstance]};
            request.responseBlock(response);
        }
    }
}

-(void)handleDestroyInstance:(WSPRNotification *)message
{
    WSPRClassInstance *rpcInstance = _instanceMap[[message.params firstObject]];
    
    [self destroyInstance:rpcInstance];
    
    if ([message isKindOfClass:[WSPRRequest class]])
    {
        WSPRRequest *request = (WSPRRequest *)message;
        
        WSPRResponse *response = [request createResponse];
        response.result = [message.params firstObject];
        request.responseBlock(response);
    }
}

-(WSPRClassInstance *)addRPCObjectInstance:(id<WSPRClassProtocol>)instance
{
    instance.rpcController = self;
    
    NSString *key = [NSString stringWithFormat:@"%p", instance];
    
    WSPRClassInstance *rpcInstance = [[WSPRClassInstance alloc] init];
    rpcInstance.rpcClass = self.classModel;
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


#pragma mark - WSPRClassInstanceDelegate

-(void)classInstance:(WSPRClassInstance *)classInstance didCreatePropertyEvent:(WSPREvent *)event
{
    [self.parentRoute reverse:[event createNotification] fromPath:nil];
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
            //TODO: Handle instance type properties
//            if ([property.type isEqualToString:WSPR_PARAM_TYPE_INSTANCE])
//            {
//                WSPRClassInstance *propertyInstance = [self getRPCClassInstanceForInstance:(NSObject<WSPRClassProtocol> *)propertyValue];
//                propertyValue = propertyInstance.instanceIdentifier;
//            }
            
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
