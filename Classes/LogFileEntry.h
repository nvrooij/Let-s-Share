//
//  LogFileEntry.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 11-08-09.
//

#import <Foundation/Foundation.h>
typedef enum 
	{
		SRLReceived = 0,
		SRLSend = 1
	} logEntryType;

@interface LogFileEntry : NSObject <NSCoding>{
	NSDate *_logDate;
	logEntryType _logType;
	NSString *_logDeviceName;
	NSString *_logTitle;
	BOOL _logWasSuccesful;
}

@property (getter=getDateStr, readonly) NSString *date;
@property (getter=getTimeStr, readonly) NSString *time;
@property (getter=getLogType, readonly) logEntryType type;
@property (getter=getDeviceName, readonly) NSString *deviceName;
@property (getter=getTitle, readonly) NSString *title;
@property (getter=getSucces, readonly) BOOL succesful;

- (id)initLogEntryWithType:(logEntryType)initType andDeviceName:(NSString *)initDeviceName andTitle:(NSString *)initTitle  andWasSuccessful:(BOOL)succes;

@end
