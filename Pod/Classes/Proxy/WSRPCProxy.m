//
//  RPCProxy.m
//  SDK5Test
//
//  Created by Patrik Nyblad on 10/02/15.
//  Copyright (c) 2015 Widespace AB. All rights reserved.
//

#import "WSRPCProxy.h"
#import "WSRPCRemoteObjectController.h"

@implementation WSRPCProxy

-(void)handleRequest:(WSRPCRequest *)request
{
    NSString *transformedMethod = [self transformMethodToReceiver:request.method];
    
    __block WSRPCRequest *blockRequest = request;
    WSRPCRequest *proxiedRequest = [[WSRPCRequest alloc] init];
    proxiedRequest.method = transformedMethod;
    proxiedRequest.params = request.params;
    [proxiedRequest setResponseBlock:^(WSRPCResponse *response){
        __strong WSRPCRequest *strongRequest = blockRequest;
        WSRPCResponse *proxiedReponse = [strongRequest createResponse];
        proxiedReponse.result = response.result;
        proxiedReponse.error = response.error;
        strongRequest.responseBlock(proxiedReponse);
    }];
    [_receiver makeRequestWithRequest:proxiedRequest];
}

-(void)handleNotification:(WSRPCNotification *)notification
{
    NSString *transformedMethod = [self transformMethodToReceiver:notification.method];
    
    WSRPCNotification *proxiedNotification = [[WSRPCNotification alloc] init];
    proxiedNotification.method = transformedMethod;
    proxiedNotification.params = notification.params;
    [_receiver makeNotificationWithNotification:proxiedNotification];
}


-(NSString *)transformMethodToReceiver:(NSString *)method
{
    NSRange rangeOfMapName = [method rangeOfString:_mapName];
    if (rangeOfMapName.location == NSNotFound)
    {
        //Throw exception!
        return nil;
    }
    
    NSString *transformedMethod = [NSString stringWithFormat:@"%@%@", _receiverMapName, [method substringFromIndex:rangeOfMapName.length]];
    
    return transformedMethod;
}


#pragma mark - WSRPCProxyToProxyProtocol

-(void)setupReverseProxy
{
    WSRPCProxy *reverseProxy = [[WSRPCProxy alloc] init];
    reverseProxy.receiver = _controller;
    reverseProxy.receiverMapName = _mapName;
    reverseProxy.mapName = _receiverMapName;
    
    [self.receiver addProxyObject:reverseProxy];
}

-(void)removeReverseProxy
{
    if (!_reverseProxy)
        return;
    
    //Retain the reverse proxy before removing it so that we are not facing any dangling pointers in the process
    WSRPCProxy *reverseProxy = self.reverseProxy;
    self.reverseProxy = nil;
    
    //Remove the other proxy´s reverse connection
    reverseProxy.reverseProxy = nil;
    [self.receiver removeProxyObject:reverseProxy];
}


#pragma mark - Description

-(NSString *)description
{
    return [@{
              @"receiver" : _receiver ? : @"",
              @"controller" : _controller ? : @"",
              @"reverseProxy" : _reverseProxy ? : @"",
              @"receiverMapName" : _receiverMapName ? : @"",
              @"mapName" : _mapName ? : @""
              } description];
}


@end
