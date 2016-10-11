//
//  WSPRClassModel.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 26/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSPRClassMethod.h"
#import "WSPRNotification.h"
#import "WSPREvent.h"
#import "WSPRClassProperty.h"

@class WSPRClass;
@class WSPRClassRouter;

/**
 Implementation protocol that must be implemented to enable RPC functionality for any class.
 */
@protocol WSPRClassProtocol <NSObject>
@required

/**
 Remember to synthesize this property so that we have an assignable ivar available when this is set by the RPCController.
 @discussion This is handled automatically by all subclasses of WSRPCObject.
 @see WSRPCObject
 */
@property (nonatomic, assign) WSPRClassRouter *classRouter;

/**
 Will be called by the RPCController when a class is being registered to get a model describing what methods are static/instance available.
 @see WSPRClass
 @see WSPRClassMethod
 */
+(WSPRClass *)rpcRegisterClass;

/**
 Used for passing events to a specific class.
 Note, this method is required due to objective-c's nature of not handling an alternative for -respondsToSelector: for static methods.
 @param event The event.
 */
+(void)rpcHandleStaticEvent:(WSPREvent *)event;

@optional

/**
 Used for passing events to a specific instance.
 @param event The event.
 */
-(void)rpcHandleInstanceEvent:(WSPREvent *)event;

/**
 Called right before dereferencing/release of the instance from the RPCController so that we can detach from view hierarchy or whatever needs to be done to release the object properly when RPCController throws away the reference.
 */
-(void)rpcDestructor;

@end


/**
 Model object describing a class to the RPCController. This model can be extended by adding a bunch of WSPRClassMethod models as either static or instance methods. This is what maps the RPC messages to specific classes and methods.
 */
@interface WSPRClass : NSObject

/**
 The actual class that we are registering towards the RPC controller.
 */
@property (nonatomic, assign) Class<WSPRClassProtocol> classRef;

/**
 Map of available static methods for this class to be invoked over the RPC interface. 
 Dictionary uses the mapName of the method for the key.
 Holds instances of WSPRClassMethod.
 */
@property (nonatomic, strong) NSDictionary *staticMethods;

/**
 Map of available instance methods to be used with this class. 
 Dictionary uses the mapName of the method for the key.
 Holds instances of WSPRClassMethod.
 */
@property (nonatomic, strong) NSDictionary *instanceMethods;

/**
 Map of available properties and their settings for this class. 
 Dictionary uses the mapName of the method for the key.
 Holds instances of WSPRClassProperty.
 */
@property (nonatomic, strong) NSDictionary *properties;

/**
 Convenience method for adding a static method.
 @param staticMethod An instance of a WSPRClassMethod model to be added to the map of available static methods.
 */
-(void)addStaticMethod:(WSPRClassMethod *)staticMethod;

/**
 Convenience method for adding an instance method.
 @param instanceMethod An instance of a WSPRClassMethod model to be added to the map of available instance methods.
 */
-(void)addInstanceMethod:(WSPRClassMethod *)instanceMethod;

/**
 Convenience method for adding a property.
 @param property An instance of a WSPRClassProperty model to be added to the map of available properties.
 */
-(void)addProperty:(WSPRClassProperty *)property;



@end
