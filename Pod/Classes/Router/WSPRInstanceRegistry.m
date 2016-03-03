//
//  WSPRInstanceRegistry.m
//  Pods
//
//  Created by Patrik Nyblad on 15/02/16.
//
//

#import "WSPRInstanceRegistry.h"

@interface WSPRInstanceRegistry ()

@property (nonatomic, strong) NSMutableDictionary *instances;

@end

@implementation WSPRInstanceRegistry


#pragma mark - Lifecycle

+(instancetype)sharedInstance
{
    static dispatch_once_t pred;
    static WSPRInstanceRegistry *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[WSPRInstanceRegistry alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.instances = [NSMutableDictionary dictionary];
    }
    return self;
}


#pragma mark - Actions

+(NSMutableDictionary *)instancesUnderRootRoute:(id<WSPRRouteProtocol>)rootRoute
{
    WSPRInstanceRegistry *instanceRegistry = [WSPRInstanceRegistry sharedInstance];
    return instanceRegistry.instances[[self identifierFromRootRoute:rootRoute]];
}

+(WSPRClassInstance *)instanceWithId:(NSString *)identifier underRootRoute:(id<WSPRRouteProtocol>)rootRoute
{
    return [self instancesUnderRootRoute:rootRoute][identifier];
}

+(WSPRClassInstance *)instanceModelForInstance:(id<WSPRClassProtocol>)instance underRootRoute:(id<WSPRRouteProtocol>)rootRoute
{
    NSMutableDictionary *instances = [self instancesUnderRootRoute:rootRoute];
    for (WSPRClassInstance *wisperInstance in [instances allValues])
    {
        if (wisperInstance.instance == instance)
        {
            return wisperInstance;
        }
    }
    return nil;
}

+(void)addInstance:(WSPRClassInstance *)instance underRootRoute:(id<WSPRRouteProtocol>)rootRoute
{
    if (!instance)
        return;
    
    NSMutableDictionary *instancesForRoute = [self instancesUnderRootRoute:rootRoute];
    
    //If we are adding an instance and we didn't have a collection for the root route
    if (!instancesForRoute && instance)
    {
        instancesForRoute = [NSMutableDictionary dictionary];
        [[WSPRInstanceRegistry sharedInstance].instances setObject:instancesForRoute forKey:[self identifierFromRootRoute:rootRoute]];
    }
    
    instancesForRoute[instance.instanceIdentifier] = instance;
}

+(void)removeInstance:(WSPRClassInstance *)instance underRootRoute:(id<WSPRRouteProtocol>)rootRoute
{
    if (!instance)
        return;
    
    NSMutableDictionary *instancesForRoute = [self instancesUnderRootRoute:rootRoute];
    
    [instancesForRoute removeObjectForKey:instance.instanceIdentifier];
    
    //Remove collection if no instances left
    if ([[instancesForRoute allKeys] count] == 0)
    {
        [[WSPRInstanceRegistry sharedInstance].instances removeObjectForKey:[self identifierFromRootRoute:rootRoute]];
    }
}


#pragma mark - Helpers

/**
 *  We use a generated id instead of the object to avoid a retain cycle. Passing the same route to this method will generate the same ID again.
 *  @param rootRoute The route that we want to generate an ID for.
 *  @return The ID for the route.
 */
+(NSString *)identifierFromRootRoute:(id<WSPRRouteProtocol>)rootRoute
{
    NSString *key = [NSString stringWithFormat:@"%p", rootRoute];
    return key;
}


@end
