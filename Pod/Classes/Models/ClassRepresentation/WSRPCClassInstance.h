//
//  WSRPCClassInstance.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 28/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSRPCClass.h"

@protocol WSRPCClassInstanceDelegate <NSObject>
@required
-(void)classInstance:(WSRPCClassInstance *)classInstance didCreatePropertyEvent:(WSRPCEvent *)event;

@end

/**
 A model object that describes an instance of a WSRPCClassProtocol complicant object.
 */
@interface WSRPCClassInstance : NSObject


@property (nonatomic, assign) id<WSRPCClassInstanceDelegate> delegate;

/**
 The model object for describing what methods and mappings this class has available.
 */
@property (nonatomic, strong) WSRPCClass *rpcClass;

/**
 The id that is used in RPC messages to tell what specific instance of the RPCController should be used.
 */
@property (nonatomic, strong) NSString *instanceIdentifier;

/**
 The actual Objective C object instance of the class.
 */
@property (nonatomic, strong) NSObject<WSRPCClassProtocol> *instance;

@end
