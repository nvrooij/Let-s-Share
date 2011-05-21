//
//  TransmitDataUtility.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 14-08-09.
//
// This utility class is a helper for the data handler.
// By placing the helper methods in this class the DataHandler class won't get cluttered.
//

#import <Foundation/Foundation.h>

@interface TDHUHelper : NSObject
+ (NSString *)getCommandFromMessage:(NSData *)message;
+ (NSData *)getDataFromString:(NSString *)str;
+ (NSString *)getValueFromMessage:(NSData *)message;
+ (NSData *)getDataFromMessage:(NSData *)message;
+ (NSData *)dataFromString:(NSString *)str;
@end
