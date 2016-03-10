//
//  WSPRFunctionRouter.h
//  Pods
//
//  Created by Patrik Nyblad on 10/03/16.
//
//

#import <Wisper/WSPRRouter.h>
#import "WSPRClassMethod.h"

@interface WSPRFunctionRouter : WSPRRouter

+(_Nonnull instancetype)routerWithBlock:( void(^ _Nonnull )(WSPRFunctionRouter * _Nonnull caller, WSPRMessage * _Nonnull message))block;
-(_Nonnull instancetype)initWithBlock:( void(^ _Nonnull )(WSPRFunctionRouter * _Nonnull caller, WSPRMessage * _Nonnull message))block;

@end
