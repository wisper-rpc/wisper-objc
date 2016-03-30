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
        self.remoteObjectInstances = [NSMutableArray array];
        self.block = ^(WSPRFunctionRouter *caller, WSPRMessage *message) {
            WSPRNotification *notification = [message isKindOfClass:[WSPRNotification class]] ? (WSPRNotification *)message : nil;
            WSPRRequest *request = [message isKindOfClass:[WSPRRequest class]] ? (WSPRRequest *)message : nil;
            
            if (notification)
            {
                WSPRCallType callType = [WSPRHelper callTypeFromMethodString:notification.method];
                
                switch (callType) {
                    case WSPRCallTypeStaticEvent:
                        [self passStaticEvent:[[WSPREvent alloc] initWithNotification:notification]];
                        break;
                    case WSPRCallTypeInstanceEvent:
                        [self passInstanceEvent:[[WSPREvent alloc] initWithNotification:notification]];
                        break;
                    default:
                        //Handle error by throwing (will respond to request or send global error)
                        [[NSException exceptionWithName:@"No route for message" reason:@"The router could not handle the message." userInfo:nil] raise];
                        break;
                }
                
                if (request)
                {
                    request.responseBlock([request createResponse]);
                }
                
                return;
            }
            
            [[NSException exceptionWithName:@"No route for message" reason:@"The router could not handle the message." userInfo:nil] raise];
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

-(void)passStaticEvent:(WSPREvent *)event
{
    [self.remoteObjectClass rpcHandleStaticEvent:event];
}

-(void)passInstanceEvent:(WSPREvent *)event
{
    for (WSPRRemoteObjectEventFunctionRouterInstanceModel *instanceModel in self.remoteObjectInstances)
    {
        if ([instanceModel.remoteObject.instanceIdentifier isEqualToString:event.instanceIdentifier])
        {
            [instanceModel.remoteObject rpcHandleInstanceEvent:event];
            return;
        }
    }
    [[NSException exceptionWithName:@"No instance for event" reason:@"The router could not handle the message." userInfo:nil] raise];
}


#pragma mark - Helpers


@end
