//
//  WSPRClassRouter.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 11/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRRouter.h"
#import "WSPRObject.h"
#import "WSPRHelper.h"

//typedef enum {
//    WSPRCallTypeUnknown,
//    WSPRCallTypeCreate,
//    WSPRCallTypeDestroy,
//    WSPRCallTypeStatic,
//    WSPRCallTypeStaticEvent,
//    WSPRCallTypeInstance,
//    WSPRCallTypeInstanceEvent
//} WSPRCallType;

/**
 *  A router that takes care of exactly one remote object class and all of its messages and instances.
 */
@interface WSPRClassRouter : WSPRRouter

/**
 *  The registered class model that this router manages.
 */
@property (nonatomic, strong, readonly) WSPRClass *classModel;

/**
 *  Shorthand method for -initWithClass:
 */
+(instancetype)routerWithClass:(Class<WSPRClassProtocol>)aClass;

/**
 *  Setup this class router with a Wisper object class.
 *  The router will get its mapname from the provided wisper object after running -rpcRegisterClass.
 *
 *  @param aClass The class you want to expose on this router
 *
 *  @return A router instance that handes a wisper class.
 */
-(instancetype)initWithClass:(Class<WSPRClassProtocol>)aClass;

/**
 *  Add an instance not created by wisper to the router. A create `!` `~, {id:_instance_id_, props:{...}}` event will be sent to notify the other side that a new instance is available.
 *  @param instance instance description
 *  @return The resulting wrapper for the instance you added.
 */
-(WSPRClassInstance *)addInstance:(id<WSPRClassProtocol>)instance;

/**
 *  Removes an instance that you have added. A destroy `:!` `_instance_id_, ~` event will be sent to notify the other side that the instance is no longer available.
 *  @param instance The instance you want to remove.
 */
-(void)removeInstance:(WSPRClassInstance *)instance;

/**
 *  Removes all owned instances and an event for each instance will be sent notifying the other side of its destruction.
 *  Essentially looping through all instances and calling -removeInstance.
 */
-(void)flushInstances;

#pragma mark - Helpers

+(WSPRCallType)callTypeFromMethodString:(NSString *)method;

@end
