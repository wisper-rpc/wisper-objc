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
@property (nonatomic, copy) void (^block)(WSPRFunctionRouter *caller, WSPRMessage *message);

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
        self.block = ^(WSPRFunctionRouter *caller, WSPRMessage *message) {
            
            __strong WSPRRemoteObjectEventFunctionRouter *strongSelf = weakSelf;
            if (!strongSelf)
                return;
            
            WSPRNotification *notification = [message isKindOfClass:[WSPRNotification class]] ? (WSPRNotification *)message : nil;
            WSPRRequest *request = [message isKindOfClass:[WSPRRequest class]] ? (WSPRRequest *)message : nil;
            
            if (notification)
            {
                WSPRCallType callType = [WSPRHelper callTypeFromMethodString:notification.method];
                
                switch (callType) {
                    case WSPRCallTypeStaticEvent:
                        [strongSelf passStaticEventFromNotification:notification];
                        break;
                    case WSPRCallTypeInstanceEvent:
                        [strongSelf passInstanceEventFromNotification:notification];
                        break;
                    default:
                    {
                        WSPRError *error = [[WSPRError alloc] init];
                        error.message = [NSString  stringWithFormat:@"No route for message with method: %@", notification.method];
                        [strongSelf respondToMessage:message withError:error];
                        return;
                    }
                }
                
                if (request)
                {
                    request.responseBlock([request createResponse]);
                }
                
                return;
            }
            
            WSPRError *error = [[WSPRError alloc] init];
            error.message = [NSString  stringWithFormat:@"No route for message with method: %@", notification.method];
            [strongSelf respondToMessage:message withError:error];
        };
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
