//
//  WSPRPropertyBinder.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 25/08/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Binding component in propety binder.
 */
@interface WSPRPropertyBinding : NSObject

/**
 The object we want to add an observer to.
 */
@property (nonatomic, strong) NSObject *target;

/**
 The keypath we want to listen to.
 */
@property (nonatomic, strong) NSString *keyPath;

/**
 Block used when setting the property, if nil it will just set the property.
 Use this to transform the value if it needs conversion from one type to another.
 */
@property (nonatomic, copy) id(^transformSetValueBlock)(id newValue);

@end

/**
 Helper object used for binding a property in one instance to a property in another instance. Setting one will set the other and vice versa.
 Uses KVO.
 */
@interface WSPRPropertyBinder : NSObject

/**
 All the added bindings.
 */
@property (nonatomic, readonly) NSArray *propertyBindings;

/**
 Add a binding to be updated when any of the other bindings are updated.
 @param target  The object we want to observe for changes and update when other bindings update.
 @param keyPath The keyPath we want to objserver on the target.
 @return A binding object that can be used to remove the binding.
 */
-(WSPRPropertyBinding *)addBindingForTarget:(NSObject *)target atKeyPath:(NSString *)keyPath;

/**
 Add a binding to be updated when any of the other bindings are updated.
 @param target                 The object we want to observe for changes and update when other bindings update.
 @param keyPath                The keyPath we want to objserver on the target.
 @param transformSetValueBlock A block that will execute when setting the value of the target at keyPath. You can transform the value here before it is set.
 @return A binding object that can be used to remove the binding.
 */
-(WSPRPropertyBinding *)addBindingForTarget:(NSObject *)target atKeyPath:(NSString *)keyPath transformSetValueBlock:(id (^)(id newValue)) transformSetValueBlock;

/**
 Removes a binding so that it is no longer listened to or updated when any other object is updated.
 @param binding The binding to remove.
 */
-(void)removeBinding:(WSPRPropertyBinding *)binding;

/**
 Removes all bindings.
 */
-(void)removeAllBindings;

@end
