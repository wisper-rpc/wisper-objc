//
//  WSPRException.h
//  Pods
//
//  Created by Patrik Nyblad on 01/03/16.
//
//

#import <Foundation/Foundation.h>
#import "WSPRError.h"

@interface WSPRException : NSException

@property (nonatomic, assign) WSPRErrorDomain domain;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSException *originalException;

+(instancetype)exceptionWithErrorDomain:(WSPRErrorDomain)domain code:(NSInteger)code originalException:(NSException *)exception andDescription:(NSString *)description;

-(WSPRError *)wisperError;

@end
