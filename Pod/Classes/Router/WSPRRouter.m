//
//  WSPRRouter.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 06/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRRouter.h"

@interface WSPRRouter ()

@end

@implementation WSPRRouter

@synthesize parentRoute = _parentRoute;
@synthesize routeNamespace = _routeNamespace;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.routes = [NSMutableDictionary dictionary];
    }
    return self;
}

-(id<WSPRRouteProtocol>)rootRouter
{
    id<WSPRRouteProtocol> route = self;
    while (route.parentRoute)
    {        
        route = route.parentRoute;
    }
    return route;
}


#pragma mark - WSPRRoute Protocol

-(void)route:(WSPRNotification *)message toPath:(NSString *)path
{
    NSArray *splitPath = [[self class] splitPath:path];
    NSString *step = [splitPath firstObject];
    NSString *rest = splitPath.count == 2 ? [splitPath lastObject] : nil;
    
    id<WSPRRouteProtocol> route = self.routes[step];
    if (route)
    {
        [route route:message toPath:rest];
    }
    else
    {
        //TODO: Throw!
    }
}

-(void)reverse:(WSPRMessage *)message fromPath:(NSString *)path
{
    if ([message isKindOfClass:[WSPRNotification class]])
    {
        //Prepend the current namespace and pass to parent
        if (!path)
        {
            [self.parentRoute reverse:message fromPath:self.routeNamespace];
        }
        else
        {
            [self.parentRoute reverse:message fromPath:[[NSString stringWithFormat:@"%@.", self.routeNamespace] stringByAppendingString:path]];
        }
    }
    else
    {
        [self.parentRoute reverse:message fromPath:nil];
    }
}

-(void)exposeRoute:(id<WSPRRouteProtocol>)route onPath:(NSString *)path
{
    NSArray *splitPath = [[self class] splitPath:path];
    NSString *step = [splitPath firstObject];
    NSString *rest = splitPath.count == 2 ? [splitPath lastObject] : nil;

    id<WSPRRouteProtocol> existing = self.routes[step];
    if (!existing)
    {
        if (!rest)
        {
            self.routes[step] = route;
            [route setParentRoute:self];
            if (![route routeNamespace])
                [route setRouteNamespace:step];
            return;
        }
        existing = [[WSPRRouter alloc] init];
        [existing setRouteNamespace:step];
        [existing setParentRoute:self];
        self.routes[step] = existing;
    }
    
    [existing exposeRoute:route onPath:rest];
}

#pragma mark - Helpers

+(NSArray *)splitPath:(NSString *)path
{
    NSRange range = [path rangeOfString:@"."];

    if (range.location != NSNotFound)
    {
        NSString *step = [path substringToIndex:range.location];
        NSString *rest = [path substringFromIndex:range.location + range.length];
        
        return @[step, rest];
    }
    return @[path];
}


@end
