//
//  WSPRClassRouter.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 11/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRClassRouter.h"

@interface WSPRClassRouter ()

@property (nonatomic, strong) WSPRClass *classModel;
@property (nonatomic, strong) NSMutableDictionary *instanceMap;

@end

@implementation WSPRClassRouter

#pragma mark - Life cycle
-(instancetype)initWithClass:(Class<WSPRClassProtocol>)aClass
{
    WSPRClass *wisperClass = [aClass rpcRegisterClass];
    self = [self initWithNameSpace:wisperClass.mapName];
    if (self)
    {
        self.classModel = wisperClass;
    }
    return self;
}

@end
