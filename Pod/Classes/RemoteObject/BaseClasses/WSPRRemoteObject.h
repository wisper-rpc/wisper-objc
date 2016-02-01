//
//  WSPRRemoteObject.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 07/01/16.
//  Copyright © 2016 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSPRGateway.h"

/**
 * Object intended to be the remote instance representative. You can start calling methods even before the remote 
 * is initialized. All messages will be queued up and run sequentially as soon as the remote is ready.
 */
@interface WSPRRemoteObject : NSObject

/**
 *  When enabled any call to this class will generate a Wisper Notification to the implementation object.
 *  Since wisper is asynchronous and expects a callback block for requests only methods without a return type 
 *  can be invoked this way. 
 *
 *  Any remote forwarding calls will parse the method name from the incoming selector up to the first argument 
 *  and then just append all arguments as params
 *
 *  @default YES
 */
@property (nonatomic, assign, getter=isAutomaticRemoteForwardingEnabled) BOOL automaticRemoteForwardingEnabled;

/**
 *  The map name of the remote object. This will be prepended on all method calls to the remote object.
 *  Must be passed on init!
 */
@property (nonatomic, strong, readonly) NSString * _Nonnull mapName;

/**
 *  The remote instance identifier.
 *  This will be set as soon as the remote is initialized.
 */
@property (nonatomic, strong, readonly) NSString * _Nullable instanceIdentifier;

/**
 *  The gateway that the remote object is located behind.
 *  Must be passed on init!
 */
@property (nonatomic, strong, readonly) WSPRGateway * _Nonnull gateway;

/**
 *  Disabled init method due to init argument requirement.
 *  @return N/A
 */
-(_Nonnull instancetype) __unavailable init;

/**
 *  Initialize a remote object with a map name and a gateway.
 *
 *  @param mapName The name of the remote object you want to represent with this object.
 *  @param gateway The gateway through where the remote object is reachable.
 *
 *  @return An instance of this object ready to be interacted with. There might be some delay before the remote 
 *  is initialized but method calls will be queued up until the remote is ready.
 */
-(_Nonnull instancetype)initWithMapName:(NSString * _Nonnull)mapName andGateway:(WSPRGateway * _Nonnull)gateway;

/**
 *  Call a remote instance method expecting a return value. This message is sent as a request.
 *
 *  @param method     The method name, you should not provide the map name of this class before the method name.
 *  @param params     The params you want to pass to the remote method.
 *  @param completion Completion block that will be triggered when done with the call.
 */
-(void)_wisperCallInstanceMethod:(NSString * _Nonnull)method withParams:(NSArray * _Nullable)params andCompletion:(void (^ _Nonnull)(NSObject * _Nullable result, WSPRError * _Nullable error))completion;

/**
 *  Call a remote static method expecting a return value. This message is sent as a request.
 *
 *  @param method     The method name, you should not provide the map name of this class before the method name.
 *  @param params     The params you want to pass to the remote method.
 *  @param completion Completion block that will be triggered when done with the call.
 */
-(void)_wisperCallStaticMethod:(NSString * _Nonnull)method withParams:(NSArray * _Nullable)params andCompletion:(void (^ _Nonnull)(NSObject * _Nullable result, WSPRError * _Nullable error))completion;

/**
 *  Call a remote instance method, this message is sent as a notification due to the non existing requirement of a return value.
 *
 *  @param method     The method name, you should not provide the map name of this class before the method name.
 *  @param params     The params you want to pass to the remote method.
 */
-(void)_wisperCallInstanceMethod:(NSString * _Nonnull)method withParams:(NSArray * _Nullable)params;

/**
 *  Call a remote static method, this message is sent as a notification due to the non existing requirement of a return value.
 *
 *  @param method     The method name, you should not provide the map name of this class before the method name.
 *  @param params     The params you want to pass to the remote method.
 */
-(void)_wisperCallStaticMethod:(NSString * _Nonnull)method withParams:(NSArray * _Nullable)params;

/**
 *  Send an instance event.
 *
 *  @param name  The name of the event.
 *  @param value The value to be sent in the event.
 */
-(void)_wisperSendInstanceEventWithName:(NSString * _Nonnull)name andValue:(NSObject * _Nullable)value;

/**
 *  Send a static event.
 *
 *  @param name  The name of the event.
 *  @param value The value to be sent in the event.
 */
-(void)_wisperSendStaticEventWithName:(NSString * _Nonnull)name andValue:(NSObject * _Nullable)value;


@end
