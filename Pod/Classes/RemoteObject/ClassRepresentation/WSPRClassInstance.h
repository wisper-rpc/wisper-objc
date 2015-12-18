//
//  WSPRClassInstance.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 28/02/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSPRClass.h"

@protocol WSPRClassInstanceDelegate <NSObject>
@required
-(void)classInstance:(WSPRClassInstance *)classInstance didCreatePropertyEvent:(WSPREvent *)event;

@end

/**
 A model object that describes an instance of a WSPRClassProtocol complicant object.
 */
@interface WSPRClassInstance : NSObject


@property (nonatomic, assign) id<WSPRClassInstanceDelegate> delegate;

/**
 The model object for describing what methods and mappings this class has available.
 */
@property (nonatomic, strong) WSPRClass *rpcClass;

/**
 The id that is used in RPC messages to tell what specific instance of the RPCController should be used.
 */
@property (nonatomic, strong) NSString *instanceIdentifier;

/**
 The actual Objective C object instance of the class.
 */
@property (nonatomic, strong) NSObject<WSPRClassProtocol> *instance;

/**
 *  Handle a property event and set the value of the property if we could handle the event.
 *  @param event An event to try to handle as a property event.
 *  @return YES if we handled the property event and actually set a property on the instance, NO if we could not handle the event.
 */
-(BOOL)handlePropertyEvent:(WSPREvent *)event;

@end
