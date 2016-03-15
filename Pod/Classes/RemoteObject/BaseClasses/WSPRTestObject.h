//
//  WSPRTestObject.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 16/05/14.
//  Copyright (c) 2014 Widespace . All rights reserved.
//

#import "WSPRObject.h"

/**
 Wisper Test object, used by test ad to verify that communication works as intended.
 This class can be seen as an example of how to implement your own Wisper compatible class.
 */
@interface WSPRTestObject : WSPRObject

/**
 Property used for testing events
 */
@property (nonatomic, strong) NSString *testProperty;

@property (nonatomic, weak) WSPRTestObject *testPassByReferenceProperty;
@property (nonatomic, assign) CGPoint testSerializeProperty;

/**
 Test method for the Wisper Gateway to verify that it works correctly.
 @param first The first string that you want to append some other string to.
 @param second The second string that will be appended to the first string.
 @return Second string appended to the first string.
 */
-(NSString *)appendString:(NSString *)first withString:(NSString *)second;

/**
 Test method for the Wisper Gateway to verify that it works correctly.
 @param first The first string that you want to append some other string to.
 @param second The second string that will be appended to the first string.
 @return Second string appended to the first string.
 */
+(NSString *)appendString:(NSString *)first withString:(NSString *)second;

/**
 Static function that will throw an exception when called. The exception should be cought by WSPRRemoteObjectController and convert it into an WSPRError object that is then sent as an event on the Remote Object reserved error event.
 */
+(void)exceptionInMethodCall;

/**
 Method that will throw an exception when called. The exception should be cought by WSPRRemoteObjectController and convert it into an WSPRError object that is then returned to the caller.
 */
-(void)exceptionInMethodCall;

+(NSString *)passByReference:(id<WSPRClassProtocol>)instance;

-(NSString *)passByReference:(id<WSPRClassProtocol>)instance;

+(BOOL)passCaller:(id)caller;

+(void)passAsyncReturnBlock:(WSPRAsyncReturnBlock)asyncReturnBlock;

+(void)passAsyncReturnBlock:(WSPRAsyncReturnBlock)asyncReturnBlock andCaller:(id)caller;


@end
