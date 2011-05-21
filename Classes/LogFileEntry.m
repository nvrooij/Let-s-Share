//
//  LogFileEntry.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 11-08-09.
//

#import "LogFileEntry.h"

@interface LogFileEntry()
- (NSString *)getDateStr;
- (NSString *)getTimeStr;
- (logEntryType)getLogType;
- (NSString *)getDeviceName;
- (NSString *)getTitle;
- (BOOL)getSucces;
@end

@implementation LogFileEntry

- (id)initLogEntryWithType:(logEntryType)initType andDeviceName:(NSString *)initDeviceName andTitle:(NSString *)initTitle andWasSuccessful:(BOOL)succes{
	if(self = [super init]){
		_logDate = [[NSDate date] retain];
		_logType = initType;
		_logDeviceName = [initDeviceName copy];
		_logTitle = [initTitle copy];
		_logWasSuccesful = succes;
	}
	return self;
}

- (void)dealloc{
	[_logDate release];
	[_logDeviceName release];
	[_logTitle release];
	[super dealloc];
}

- (BOOL)isEqual:(id)object {
	// Basically, compares the peerIDs
	return object && ([object isKindOfClass:[LogFileEntry class]]) && ([((LogFileEntry *) object).date isEqual:_logDate]);
}

#pragma mark -
#pragma mark Category methods
- (NSString *)getDateStr{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	NSDate *date =_logDate;
	return [dateFormatter stringFromDate:date];		
}
- (NSString *)getTimeStr{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSDate *date =_logDate;
	return [dateFormatter stringFromDate:date];			
}

- (logEntryType)getLogType{
	return _logType;
}

- (NSString *)getDeviceName{
	return _logDeviceName;
}

- (NSString *)getTitle{
	return _logTitle;
}

- (BOOL)getSucces{
	return _logWasSuccesful;
}


#pragma mark -
#pragma mark NSCoding protocol methods

- (id)initWithCoder:(NSCoder *)coder{
	[super init];
	_logDate = [[coder decodeObjectForKey:@"logDate"] retain];
	_logType = (logEntryType)[coder decodeIntForKey:@"logType"];
	_logDeviceName = [[coder decodeObjectForKey:@"logDeviceName"] retain];
	_logTitle = [[coder decodeObjectForKey:@"logTitle"] retain];
	_logWasSuccesful = [coder decodeBoolForKey:@"logWasSuccesful"];
	return self;
}
- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:_logDate forKey:@"logDate"];
	[coder encodeInt:_logType forKey:@"logType"];
	[coder encodeObject:_logDeviceName forKey:@"logDeviceName"];
	[coder encodeObject:_logTitle forKey:@"logTitle"];
	[coder encodeBool:_logWasSuccesful forKey:@"logWasSuccesful"];
}
@end
