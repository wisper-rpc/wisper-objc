//
//  WSPRGatewayRouter.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 07/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import "WSPRRouter.h"

@interface WSPRGatewayRouter : WSPRRouter <WSPRGatewayDelegate>

@property (nonatomic, readonly) WSPRGateway *gateway;

@end
