//
//  WSPRFunctionRouter.m
//  Pods
//
//  Created by Patrik Nyblad on 10/03/16.
//
//

#import "WSPRFunctionRouter.h"
@interface WSPRFunctionRouter ()

@property (nonatomic, copy) void (^block)(WSPRFunctionRouter *caller, WSPRMessage *message);

@end

@implementation WSPRFunctionRouter

+(instancetype)routerWithBlock:(void (^)(WSPRFunctionRouter *, WSPRMessage *))block
{
    return [[self alloc] initWithBlock:block];
}

-(instancetype)initWithBlock:(void (^)(WSPRFunctionRouter *caller, WSPRMessage *message))block
{
    self = [self init];
    if (self)
    {
        self.block = block;
    }
    return self;
}

-(void)route:(WSPRMessage *)message toPath:(NSString *)path
{
    if (_block)
    {
        //Handle as message to block
        self.block(self, message);
    }
    else
    {
        [super route:message toPath:path];
    }
}



@end
