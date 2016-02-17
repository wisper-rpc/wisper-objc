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
 *  Setup this class router with a Wisper object class.
 *  The router will get its mapname from the provided wisper object after running -rpcRegisterClass.
 *
 *  @param aClass The class you want to expose on this router
 *
 *  @return A router instance that handes a wisper class.
 */
-(instancetype)initWithClass:(Class<WSPRClassProtocol>)aClass;

#pragma mark - Helpers

+(WSPRCallType)callTypeFromMethodString:(NSString *)method;

@end
