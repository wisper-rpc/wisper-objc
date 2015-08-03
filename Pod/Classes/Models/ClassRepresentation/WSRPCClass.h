//
//  WSRPCClassModel.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 26/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSRPCClassMethod.h"
#import "WSRPCNotification.h"
#import "WSRPCEvent.h"
#import "WSRPCClassProperty.h"

@class WSRPCClass;
@class WSRPCRemoteObjectController;

/**
 Implementation protocol that must be implemented to enable RPC functionality for any class.
 */
@protocol WSRPCClassProtocol <NSObject>
@required

/**
 Remember to synthesize this property so that we have an assignable ivar available when this is set by the RPCController.
 @discussion This is handled automatically by all subclasses of WSRPCObject.
 @see WSRPCObject
 */
@property (nonatomic, assign) WSRPCRemoteObjectController *rpcController;

/**
 Will be called by the RPCController when a class is being registered to get a model describing what methods are static/instance available.
 @see WSRPCClass
 @see WSRPCClassMethod
 */
+(WSRPCClass *)rpcRegisterClass;

/**
 Used for passing events to a specific class.
 Note, this method is required due to objective-c's nature of not handling an alternative for -respondsToSelector: for static methods.
 @param event The event.
 */
+(void)rpcHandleStaticEvent:(WSRPCEvent *)event;

@optional

/**
 Used for passing events to a specific instance.
 @param event The event.
 */
-(void)rpcHandleInstanceEvent:(WSRPCEvent *)event;

/**
 Called right before dereferencing/release of the instance from the RPCController so that we can detach from view hierarchy or whatever needs to be done to release the object properly when RPCController throws away the reference.
 */
-(void)rpcDestructor;

@end


/**
 Model object describing a class to the RPCController. This model can be extended by adding a bunch of WSRPCClassMethod models as either static or instance methods. This is what maps the RPC messages to specific classes and methods.
 */
@interface WSRPCClass : NSObject

/**
 The actual class that we are registering towards the RPC controller.
 */
@property (nonatomic, assign) Class<WSRPCClassProtocol> classRef;

/**
 This will be used when mapping incoming requests against classes. You could strip the prefix of a class here to make it pretty for the caller ;)
 The mapname must be uniqe, otherwise the latest class registered in the RPCController will be the only available with the mapName.
 If nil the getter will return the classRef as a string.
 */
@property (nonatomic, strong) NSString *mapName;

/**
 Map of available static methods for this class to be invoked over the RPC interface. 
 Dictionary uses the mapName of the method for the key.
 Holds instances of WSRPCClassMethod.
 */
@property (nonatomic, strong) NSDictionary *staticMethods;

/**
 Map of available instance methods to be used with this class. 
 Dictionary uses the mapName of the method for the key.
 Holds instances of WSRPCClassMethod.
 */
@property (nonatomic, strong) NSDictionary *instanceMethods;

/**
 Map of available properties and their settings for this class. 
 Dictionary uses the mapName of the method for the key.
 Holds instances of WSRPCClassProperty.
 */
@property (nonatomic, strong) NSDictionary *properties;

/**
 Convenience method for adding a static method.
 @param staticMethod An instance of a WSRPCClassMethod model to be added to the map of available static methods.
 */
-(void)addStaticMethod:(WSRPCClassMethod *)staticMethod;

/**
 Convenience method for adding an instance method.
 @param instanceMethod An instance of a WSRPCClassMethod model to be added to the map of available instance methods.
 */
-(void)addInstanceMethod:(WSRPCClassMethod *)instanceMethod;

/**
 Convenience method for adding a property.
 @param property An instance of a WSRPCClassProperty model to be added to the map of available properties.
 */
-(void)addProperty:(WSRPCClassProperty *)property;



@end
