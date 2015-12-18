//
//  WSPRObjectRouter.m
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 07/10/15.
//  Copyright © 2015 Widespace . All rights reserved.
//

#import "WSPRObjectRouter.h"

@implementation WSPRObjectRouter

-(void)route:(WSPRMessage *)message toPath:(NSString *)path
{
    NSArray *splitPath = [[self class] splitPath:path];
    NSString *step = [splitPath firstObject];
    NSString *rest = [splitPath lastObject];

    if (!rest)
    {
        //Handle route
        
        return;
    }
    
    //If we could not handle it let super class handle it.
    [super route:message toPath:path];
}

@end
