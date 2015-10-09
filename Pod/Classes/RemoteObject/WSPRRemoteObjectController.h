//
//  WSPRRemoteObjectController.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 27/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRGateway.h"
#import "WSPRClassInstance.h"
#import "WSPRProxy.h"

/**
 Subclass of the WSPRGateway to extend functionality for handling objective c instances with rpc messages. This class will allow you to register classes to be used by the rpc bridge through exposed methods.
 */
@interface WSPRRemoteObjectController : WSPRGateway

/**
 Register an RPC compliant class with the RPC Controller so that the other end point can start managing instances and call methods on both the static class as well as the instances created.
 @param aClass a class that implements the WSPRClassProtocol pointer.
 */
-(void)registerClass:(Class<WSPRClassProtocol>)aClass;

/**
 Get a registered class model for a specific class. If no class model can be found this method will return nil.
 @param aClass a class that implements the WSPRClassProtocol pointer.
 */
-(WSPRClass *)getRPCClassForClass:(Class)aClass;

/**
 Get a class instance model for an instantiated and mapped class that is owned by this RPC Controller.
 @param instanceIdentifier An instance id connected to this remote object controller.
 @return The WSPRClassInstance model object representing the instance or nil if instance is not registered with this RPCRemoteObjectController.
 */
-(WSPRClassInstance *)getRPCClassInstanceForInstanceIdentifier:(NSString *)instanceIdentifier;

/**
 Get a class instance model for an instantiated and mapped class that is owned by this RPC Controller.
 @param instance An instance that implements the WSPRClassProtocol.
 @return The WSPRClassInstance model object representing the instance or nil if instance is not registered with this RPCRemoteObjectController.
 */
-(WSPRClassInstance *)getRPCClassInstanceForInstance:(NSObject<WSPRClassProtocol> *)instance;

/**
 Flushes all instances in the instance map.
 Should be used as cleanup when an ad closes or a new ad is being loaded.
 */
-(void)flushInstances;

/**
 Add an already instantiated object conforming to the WSPRClassProtocol. The instance will be registered with this controller and accessible using RPC messages.
 @param instance The instance you want to attach to this RPC Controller
 @return RPC instance representation of the added instance.
 */
-(WSPRClassInstance *)addRPCObjectInstance:(id<WSPRClassProtocol>)instance withRPCClass:(WSPRClass *)rpcClass;

/**
 Add an already instantiated object conforming to the WSPRClassProtocol. The instance will be registered with this controller and accessible using RPC messages.
 @param instance The instance you want to attach to this RPC Controller
 @return Success or failure.
 */
-(BOOL)removeRPCObjectInstance:(WSPRClassInstance *)rpcInstanceRepresentation;

-(void)addProxyObject:(WSPRProxy *)proxy;
-(void)removeProxyObject:(WSPRProxy *)proxy;
-(void)removeProxyForPath:(NSString *)path;

@end
