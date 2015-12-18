//
//  WSPRProperty.h
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
typedef NS_ENUM(NSInteger, WSPRPropertyMode)
{
    /**
     The property can be both written and read. (events will be listened to and sent)
     */
    WSPRPropertyModeReadWrite,
    /**
     The property can only be read (events will be sent but not listened to)
     */
    WSPRPropertyModeReadOnly,
    /**
     The property can only be written to (no events will be sent)
     */
    WSPRPropertyModeWriteOnly
};

/**
 A model object that describes a mapped property in a WSPRClass.
 Properties will be automatically set when an incoming message asks to set it (if allowed by its mode). Properties will also be listened to by using KVO and automatically dispatches an Wisper message when the property is updated.
 
 @warning If you override the setter, make sure KVO is still working or fire the KVO events manually.
 
 @discussion
 Properties are expected to follow Apple guide lines for naming and can only be one of the WSPR_PARAM_TYPEs.
 Setters must be prefixed with set[NAME] and getters just [NAME].
 
 @see WSPRClassMethod for WSPR_PARAM_TYPE(s).
 */
@interface WSPRClassProperty : NSObject

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
@property (nonatomic, assign) WSPRPropertyMode mode;

/**
 Type used for type checking when setting property. Must be one of WSPR_PARAM_TYPE(s).
 */
@property (nonatomic, strong) NSString *type;

/**
 *  Optional block used to transform a wisper value to something you want for your mapped property.
 *  The object you return must be compatible with NSKeyValueCoding -setValue:forKeyPath.
 */
@property (nonatomic, copy) id(^deserializeWisperPropertyBlock)(NSObject *wisperValue);

/**
 *  Optional block used to transform a property value to something wisper understands.
 *  The object you return must be of one of the types wisper can manage: String, Number, Array or Dictionary.
 */
@property (nonatomic, copy) id(^serializeWisperPropertyBlock)(NSObject *propertyValue);

+(instancetype)propertyWithMapName:(NSString *)mapName keyPath:(NSString *)keyPath type:(NSString *)type andMode:(WSPRPropertyMode)mode;

-(instancetype)initWithMapName:(NSString *)mapName keyPath:(NSString *)keyPath type:(NSString *)type andMode:(WSPRPropertyMode)mode;


@end
