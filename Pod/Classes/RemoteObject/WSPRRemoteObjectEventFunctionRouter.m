//
//  WSPRRemoteObjectEventFunctionRouter.m
//  Pods
//
//  Created by Patrik Nyblad on 24/03/16.
//
//

#import "WSPRRemoteObjectEventFunctionRouter.h"
#import "WSPRHelper.h"
#import "WSPREvent.h"

/**
 *  Only here to hold a non-retained instance so we can have it in an array without retain cycles.
 */
@interface WSPRRemoteObjectEventFunctionRouterInstanceModel : NSObject
@property (nonatomic, assign) id<WSPRRemoteObjectEventProtocol> remoteObject;
-(instancetype)initWithRemoteObject:(WSPRRemoteObject *)remoteObject;
@end
@implementation WSPRRemoteObjectEventFunctionRouterInstanceModel
- (instancetype)initWithRemoteObject:(WSPRRemoteObject *)remoteObject
{
    self = [self init];
    if (self)
        self.remoteObject = remoteObject;
    return self;
}
@end

@interface WSPRRemoteObjectEventFunctionRouter ()

@property (nonatomic, strong) NSMutableArray *remoteObjectInstances;

@end

@implementation WSPRRemoteObjectEventFunctionRouter

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        __weak WSPRRemoteObjectEventFunctionRouter *weakSelf = self;
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


#pragma mark - Setters & Getters



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
    WSPRRemoteObjectEventFunctionRouterInstanceModel *instanceModel = [[WSPRRemoteObjectEventFunctionRouterInstanceModel alloc] initWithRemoteObject:remoteObject];
    [self.remoteObjectInstances addObject:instanceModel];
}

-(void)unregisterRemoteObjectInstance:(id<WSPRRemoteObjectEventProtocol>)remoteObject
{
    WSPRRemoteObjectEventFunctionRouterInstanceModel *instanceModel = nil;
    for (WSPRRemoteObjectEventFunctionRouterInstanceModel *anInstanceModel in self.remoteObjectInstances)
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
    for (WSPRRemoteObjectEventFunctionRouterInstanceModel *instanceModel in self.remoteObjectInstances)
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


#pragma mark - Helpers


@end
