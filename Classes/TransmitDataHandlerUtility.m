//
//  TransmitDataUtility.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 14-08-09.
//

#import "TransmitDataHandlerUtility.h"


@implementation TDHUHelper

+ (NSString *)getCommandFromMessage:(NSData *)message {
	// The 4 first bytes of the message represent the command
	NSRange r = {0,4};
	NSData *sub = [message subdataWithRange:r];
	NSString *strMsg = [[[NSString alloc] initWithData:sub encoding:NSUTF8StringEncoding] autorelease];	
	return [strMsg substringToIndex:4];
}

+ (NSData *)getDataFromString:(NSString *)str {
	return [str dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)getValueFromMessage:(NSData *)message {
	// All the data after the first 4 bytes are considered the value
	NSString *strMsg = [[[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding] autorelease];
	return [strMsg substringFromIndex:4];
}

+ (NSData *)getDataFromMessage:(NSData *)message{
	// All the data after the first 4 bytes are considered the value
	NSRange r;
	r.location = 4;
	r.length = [message length] - 4;
	NSData *msgData = [message subdataWithRange:r];
	return msgData;
}

+ (NSData *)dataFromString:(NSString *)str {
	return [str dataUsingEncoding:NSUTF8StringEncoding];
}

@end
