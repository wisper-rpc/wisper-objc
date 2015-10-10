//
//  WSPRMessage.h
//  Widespace-SDK-iOS
//
//  Created by Patrik Nyblad on 04/08/15.
//  Copyright (c) 2015 Widespace . All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Wisper abstract message class. All message types must subclass this class.
 */
@interface WSPRMessage : NSObject

/**
 Convenience method for creating a message without calling alloc + -init
 */
+(instancetype)message;

/**
 Convenience method for creating a message without calling alloc + -initWithDictionary:
 @param dictionary An NSDictionary containing keys and values for the properties to set.
 */
+(instancetype)messageWithDictionary:(NSDictionary *)dictionary;

/**
 Initialize with a provided dictionary.
 @param dictionary An NSDictionary containing keys and values for the properties to set.
 */
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 Create a dictionary representation of this message.
 */
-(NSDictionary *)asDictionary;

/**
 Create a JSON string representation of this message.
 */
-(NSString *)asJSONString;


@end
