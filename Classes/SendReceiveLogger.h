//
//  SendReceiveLogger.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 11-08-09.
//

#import <Foundation/Foundation.h>
#import "LogFileEntry.h"
#import "Device.h"

#define kNotificationLogHasChanged @"notif_log_has_changed"

@interface SendReceiveLogger : NSObject {
	NSMutableDictionary *_logFile;
	NSMutableDictionary *_ThreadSaveLogFileCopy;
}

@property(getter=getLogEntriesReceived, readonly) NSArray *logEntriesReceived;
@property(getter=getLogEntriesSend, readonly) NSArray *logEntriesSend;

+ (SendReceiveLogger *)sharedSendReceiveLogger;
- (void)writeReceptionToLog:(NSString *)title fromDevice:(Device *)device wasSuccesful:(BOOL)succes;
- (void)writeTransmissionToLog:(NSString *)title fromDevice:(Device *)device wasSuccesful:(BOOL)succes;;

- (void)clearLogFile;
@end