//
//  WSPRRouter.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 06/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSPRGateway.h"

@protocol WSPRRouteProtocol <NSObject>

@property (nonatomic, strong) NSString *routeNamespace;
@property (nonatomic, assign) id<WSPRRouteProtocol> parentRoute;

/**
 Take a message and route/handle it.
 @param message The message to route/handle
 @param The path to continue routing to. The standard way is to consume the first part of the path (up to the next ".") and pass the new path in the next route.
 @warning Its ok for this method to throw exceptions so you should catch any ecxeptions and try to handle them by passing error responses to the other end point.
 */
-(void)route:(WSPRMessage *)message toPath:(NSString *)path;

/**
 Take the message, append your nameSpace before calling -reverse: on parentRouter.
 @param message The message to route to the parent.
 @param The path the message came from. The standard implementation would prepend the current namespace to the path string before passing to parentRoter.
 */
-(void)reverse:(WSPRMessage *)message fromPath:(NSString *)path;

/**
 Exposes a new route on the specified path.
 @param route The instance implementing the WSPRRoute protocol.
 @param path The path to expose the route on.
 */
-(void)exposeRoute:(id<WSPRRouteProtocol>)route onPath:(NSString *)path;


@end


/**
 *  An object that receives and routes messages to other known routes or reverse up to its known parent.
 */
@interface WSPRRouter : NSObject <WSPRRouteProtocol>

@property (nonatomic, strong) NSMutableDictionary *routes;

/**
 *  Splits a wisper method path into two strings.
 *  First a step and then a rest string.
 *  @param path The path you want to split ex. "wisper.layout.View"
 *  @return An array where first object is step and last is rest (according to example above: ["wisper", "layout.View"])
 */
+(NSArray *)splitPath:(NSString *)path;

/**
 *  Gets the root router of the whole routing tree. This is usually some kind of gateway.
 *  The root is found by recursively looping through all parents until we reach the top level.
 *  @return The root router.
 */
-(id<WSPRRouteProtocol>)rootRouter;

/**
 *  Returns the router for a specific path under this router
 *  @param path The path you want to look up.
 *  @return An instance implementing the route protocol if found, otherwise nil.
 */
-(id<WSPRRouteProtocol>)routerAtPath:(NSString *)path;

@end
