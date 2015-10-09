//
//  WSPRProxy.m
//  SDK5Test
//
//  Created by Patrik Nyblad on 10/02/15.
//  Copyright (c) 2015 Widespace AB. All rights reserved.
//

#import "WSPRProxy.h"
#import "WSPRRemoteObjectController.h"

@implementation WSPRProxy

-(void)handleRequest:(WSPRRequest *)request
{
    NSString *transformedMethod = [self transformMethodToReceiver:request.method];
    
    __block WSPRRequest *blockRequest = request;
    WSPRRequest *proxiedRequest = [[WSPRRequest alloc] init];
    proxiedRequest.method = transformedMethod;
    proxiedRequest.params = request.params;
    [proxiedRequest setResponseBlock:^(WSPRResponse *response){
        __strong WSPRRequest *strongRequest = blockRequest;
        WSPRResponse *proxiedReponse = [strongRequest createResponse];
        proxiedReponse.result = response.result;
        proxiedReponse.error = response.error;
        strongRequest.responseBlock(proxiedReponse);
    }];
    [_receiver sendMessage:proxiedRequest];
}

-(void)handleNotification:(WSPRNotification *)notification
{
    NSString *transformedMethod = [self transformMethodToReceiver:notification.method];
    
    WSPRNotification *proxiedNotification = [[WSPRNotification alloc] init];
    proxiedNotification.method = transformedMethod;
    proxiedNotification.params = notification.params;
    [_receiver sendMessage:proxiedNotification];
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


#pragma mark - WSPRProxyToProxyProtocol

-(void)setupReverseProxy
{
    WSPRProxy *reverseProxy = [[WSPRProxy alloc] init];
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
    WSPRProxy *reverseProxy = self.reverseProxy;
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
