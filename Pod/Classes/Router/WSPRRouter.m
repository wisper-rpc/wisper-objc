//
//  WSPRRouter.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 06/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRRouter.h"
#import "WSPRException.h"

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

-(void)dealloc
{
    //Remove all child route's parent pointers
    for (id<WSPRRouteProtocol>route in [self.routes allValues])
    {
        [route setParentRoute:nil];
    }
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

-(id<WSPRRouteProtocol>)routerAtPath:(NSString *)path
{
    WSPRRouter *router = self;
    NSString *currentPath = path;
    
    NSArray *splitPath = [[self class] splitPath:currentPath];
    NSString *step = [splitPath firstObject];

    while (router.routes[step])
    {
        //Move to new ruter
        router = [router.routes[step] isKindOfClass:[WSPRRouter class]] ? router.routes[step] : nil;
        
        //Find next
        currentPath = splitPath.count == 2 ? [splitPath lastObject] : nil;
        splitPath = [[self class] splitPath:currentPath];
        step = [splitPath firstObject];

    }
    return router;
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
        WSPRException *exception = [WSPRException exceptionWithErrorDomain:WSPRErrorDomainWisper code:WSPRErrorMissingProcedure originalException:nil andDescription:[NSString  stringWithFormat:@"No route for message with method: %@", message.method]];
        [exception raise];
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
            [self.parentRoute reverse:message fromPath:[NSString stringWithFormat:@"%@.%@", self.routeNamespace, path]];
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
    
    if (!rest)
    {
        self.routes[step] = route;
        [route setParentRoute:self];
        [route setRouteNamespace:step];
        return;
    }

    id<WSPRRouteProtocol> existing = self.routes[step];
    if (!existing)
    {
        existing = [[WSPRRouter alloc] init];
        [existing setRouteNamespace:step];
        [existing setParentRoute:self];
        self.routes[step] = existing;
    }
    
    [existing exposeRoute:route onPath:rest];
}

#pragma mark - Helpers

+(NSArray *)splitPath:(NSString *)inPath
{
    if (!inPath)
        return @[];
        
    NSString *path = inPath;
    NSCharacterSet *specialMarkers = [NSCharacterSet characterSetWithCharactersInString:@":~!"];
    
    NSRange specialMarkerRange = [path rangeOfCharacterFromSet:specialMarkers];
    if (specialMarkerRange.location != NSNotFound)
    {
        path = [path substringToIndex:specialMarkerRange.location];
    }
    
    NSRange range = [path rangeOfString:@"."];
    
    if (range.location != NSNotFound)
    {
        NSString *step = [path substringToIndex:range.location];
        NSString *rest = [path substringFromIndex:range.location + range.length];
        
        return @[step, rest];
    }
    return @[path];
}

-(NSString *)description
{
    return [@{
              @"type": NSStringFromClass([self class]),
              @"namespace" : self.routeNamespace ? : @"",
              @"routes" : [self.routes allKeys] ? : @[]
              } description];
}


@end
