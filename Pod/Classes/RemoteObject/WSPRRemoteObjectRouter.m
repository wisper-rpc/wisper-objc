//
//  WSPRRemoteObjectRouter.m
//  Pods
//
//  Created by Patrik Nyblad on 24/03/16.
//
//

#import "WSPRRemoteObjectRouter.h"
#import "WSPRHelper.h"
#import "WSPREvent.h"

/**
 *  Only here to hold a non-retained instance so we can have it in an array without retain cycles.
 */
@interface WSPRRemoteObjectRouterInstanceModel : NSObject
@property (nonatomic, assign) id<WSPRRemoteObjectEventProtocol> remoteObject;
-(instancetype)initWithRemoteObject:(WSPRRemoteObject *)remoteObject;
@end
@implementation WSPRRemoteObjectRouterInstanceModel
- (instancetype)initWithRemoteObject:(WSPRRemoteObject *)remoteObject
{
    self = [self init];
    if (self)
        self.remoteObject = remoteObject;
    return self;
}
@end

@interface WSPRRemoteObjectRouter ()

@property (nonatomic, strong) NSMutableArray *remoteObjectInstances;

@end

@implementation WSPRRemoteObjectRouter

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.remoteObjectInstances = [NSMutableArray array];
    }
    return self;
}

-(instancetype)initWithRemoteObjectClass:(Class<WSPRRemoteObjectEventProtocol>)remoteObjectClass
{
    self = [self init];
    if (self)
    {
        self.remoteObjectClass = remoteObjectClass;
    }
    return self;
}


#pragma mark - WSPRRouteProtocol

-(void)route:(WSPRMessage *)message toPath:(NSString *)path
{
    WSPRNotification *notification = [message isKindOfClass:[WSPRNotification class]] ? (WSPRNotification *)message : nil;
    WSPRRequest *request = [message isKindOfClass:[WSPRRequest class]] ? (WSPRRequest *)message : nil;

    if (notification)
    {
        WSPRCallType callType = [WSPRHelper callTypeFromMethodString:notification.method];
        
        switch (callType) {
            case WSPRCallTypeStaticEvent:
                [self passStaticEventFromNotification:notification];
                break;
            case WSPRCallTypeInstanceEvent:
                [self passInstanceEventFromNotification:notification];
                break;
            default:
            {
                [super route:message toPath:path];
                return;
            }
        }
        
        if (request)
        {
            request.responseBlock([request createResponse]);
        }
        
        return;
    }
    
    [super route:message toPath:path];
}


#pragma mark - Public Actions

-(void)registerRemoteObjectInstance:(id<WSPRRemoteObjectEventProtocol>)remoteObject
{
    WSPRRemoteObjectRouterInstanceModel *instanceModel = [[WSPRRemoteObjectRouterInstanceModel alloc] initWithRemoteObject:remoteObject];
    [self.remoteObjectInstances addObject:instanceModel];
}

-(void)unregisterRemoteObjectInstance:(id<WSPRRemoteObjectEventProtocol>)remoteObject
{
    WSPRRemoteObjectRouterInstanceModel *instanceModel = nil;
    for (WSPRRemoteObjectRouterInstanceModel *anInstanceModel in self.remoteObjectInstances)
    {
        if (anInstanceModel.remoteObject == remoteObject)
        {
            instanceModel = anInstanceModel;
            break;
        }
    }
    [self.remoteObjectInstances removeObject:instanceModel];
}


#pragma mark - Private Actions

-(void)passStaticEventFromNotification:(WSPRNotification *)notification
{
    WSPREvent *event = [[WSPREvent alloc] initWithNotification:notification];
    [self.remoteObjectClass rpcHandleStaticEvent:event];
}

-(void)passInstanceEventFromNotification:(WSPRNotification *)notification
{
    WSPREvent *event = [[WSPREvent alloc] initWithNotification:notification];
    for (WSPRRemoteObjectRouterInstanceModel *instanceModel in self.remoteObjectInstances)
    {
        if ([instanceModel.remoteObject.instanceIdentifier isEqualToString:event.instanceIdentifier])
        {
            [instanceModel.remoteObject rpcHandleInstanceEvent:event];
            return;
        }
    }
    
    WSPRError *error = [[WSPRError alloc] init];
    error.message = [NSString  stringWithFormat:@"No instance for event: %@", event];
    [self respondToMessage:notification withError:error];
}


@end
