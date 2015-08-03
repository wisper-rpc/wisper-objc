//
//  WSRPCProperty.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 20/08/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>

//TODO: Use objc_property, property_getAttributes in the future for type checking.

/**
 Enumeration describing what modes of access is available for the property.
 */
typedef NS_ENUM(NSInteger, WSRPCPropertyMode)
{
    /**
     The property can be both written and read. (events will be listened to and sent)
     */
    WSRPCPropertyModeReadWrite,
    /**
     The property can only be read (events will be sent but not listened to)
     */
    WSRPCPropertyModeReadOnly,
    /**
     The property can only be written to (no events will be sent)
     */
    WSRPCPropertyModeWriteOnly
};

/**
 A model object that describes a mapped property in a WSRPCClass.
 Properties will be automatically set when an incoming message asks to set it (if allowed by its mode). Properties will also be listened to by using KVO and automatically dispatches an RPC message when the property is updated. 
 
 @warning If you override the setter, make sure KVO is still working or fire the KVO events manually.
 
 @discussion
 Properties are expected to follow Apple guide lines for naming and can only be one of the RPC_PARAM_TYPEs.
 Setters must be prefixed with set[NAME] and getters just [NAME].
 
 @see WSRPCClassMethod for RPC_PARAM_TYPE(s).
 */
@interface WSRPCClassProperty : NSObject

/**
 The name you want to expose this property as.
 */
@property (nonatomic, strong) NSString *mapName;

/**
 The name of the property, this is used to build a selector for setting and registering for KVO.
 */
@property (nonatomic, strong) NSString *keyPath;

/**
 Descriptive info about what this property represents.
 */
@property (nonatomic, strong) NSString *details;

/**
 The access mode for the property.
 */
@property (nonatomic, assign) WSRPCPropertyMode mode;

/**
 Type used for type checking when setting property. Must be one of RPC_PARAM_TYPE(s).
 */
@property (nonatomic, strong) NSString *type;

+(instancetype)propertyWithMapName:(NSString *)mapName keyPath:(NSString *)keyPath type:(NSString *)type andMode:(WSRPCPropertyMode)mode;

-(instancetype)initWithMapName:(NSString *)mapName keyPath:(NSString *)keyPath type:(NSString *)type andMode:(WSRPCPropertyMode)mode;


@end
