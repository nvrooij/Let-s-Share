//
//  SendReceiveLogger.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 11-08-09.
//

#import "SendReceiveLogger.h"
#import "DefaultsController.h"

#define kLogFileNameAndType @"logFile_v1.archive"

#define kLogDictionarySend @"send"
#define kLogDictionaryReceived @"received"

static SendReceiveLogger *gsharedSendReceiveLogger = nil;

@interface SendReceiveLogger()
- (void)initLogEntries;
- (void)saveLogToFile:(id)object;

- (NSArray *)getLogEntriesSend;
- (NSArray *)getLogEntriesReceived;
- (void)writeToLog:(logEntryType)type withTitle:(NSString *)title fromDevice:(NSString *)deviceName wasSuccesful:(BOOL)succes;
@end


@implementation SendReceiveLogger

- (id)init{
	if(self = [super init]){
		NSMutableArray *_logEntriesSend = [[NSMutableArray alloc] initWithCapacity:0];
		NSMutableArray *_logEntriesReceived = [[NSMutableArray alloc] initWithCapacity:0];
		_logFile = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:_logEntriesSend,_logEntriesReceived,nil] forKeys:[NSArray arrayWithObjects:kLogDictionarySend,kLogDictionaryReceived,nil]];
		[_logEntriesSend release];
		[_logEntriesReceived release];
		[self initLogEntries];
	}
	return self;
}

- (void)initLogEntriesDone:(id)object{
	if(_logFile)
		[_logFile release];
	_logFile = [(NSMutableDictionary *)object retain];
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLogHasChanged object:nil userInfo:nil];
}

- (void)saveLogToFileDone{
	[_ThreadSaveLogFileCopy release];
}
#pragma mark -
#pragma mark Threads

- (void)initLogEntries{	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	
	NSString *logFilePath = [documentsPath stringByAppendingPathComponent:kLogFileNameAndType];
		
	NSMutableDictionary *newMutableDictionary;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:logFilePath]) {
		NSArray *newLogEntriesSend = [[NSMutableArray alloc] initWithCapacity:0];
		NSArray *newLogEntriesReceived = [[NSMutableArray alloc] initWithCapacity:0];
		newMutableDictionary = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:newLogEntriesSend,newLogEntriesReceived,nil] forKeys:[NSArray arrayWithObjects:kLogDictionarySend,kLogDictionaryReceived,nil]];
		[newLogEntriesSend release];
		[newLogEntriesReceived release];
		
	} else{
		newMutableDictionary = [[NSKeyedUnarchiver unarchiveObjectWithFile:logFilePath] retain]; 
	}
		
	[self performSelector:@selector(initLogEntriesDone:) withObject:[newMutableDictionary autorelease]];
}

- (void)saveLogToFile:(id)object{
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	
	NSString *logFilePath = [documentsPath stringByAppendingPathComponent:kLogFileNameAndType];	
	
	NSMutableDictionary *t = (NSMutableDictionary *)object;
	[NSKeyedArchiver archiveRootObject:t toFile:logFilePath];

	[self performSelector:@selector(saveLogToFileDone)];
}

- (void)dealloc{
	[_logFile release];
	[super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (void)writeToLog:(logEntryType)type withTitle:(NSString *)title fromDevice:(NSString *)deviceName wasSuccesful:(BOOL)succes{
	LogFileEntry *newEntry = [[LogFileEntry alloc] initLogEntryWithType:type andDeviceName:deviceName andTitle:title andWasSuccessful:succes];
	NSMutableArray *_logEntriesSend = [_logFile objectForKey:kLogDictionarySend];
	NSMutableArray *_logEntriesReceived = [_logFile objectForKey:kLogDictionaryReceived];
	
	switch (type) {
		case SRLSend:
			if ([_logEntriesSend count]== [[DefaultsController sharedDefaultsController] getMaxLogFileItems])
				[_logEntriesSend removeObjectAtIndex:0];			
			[_logEntriesSend addObject:newEntry];			
			break;
		default:
			if ([_logEntriesReceived count]== [[DefaultsController sharedDefaultsController] getMaxLogFileItems])
				[_logEntriesReceived removeObjectAtIndex:0];
			[_logEntriesReceived addObject:newEntry];
			break;
	}
	[self saveLogToFile:_logFile];
	[newEntry release];
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLogHasChanged object:nil userInfo:nil];
}

- (void)writeReceptionToLog:(NSString *)title fromDevice:(Device *)device wasSuccesful:(BOOL)succes;{
	[self writeToLog:SRLReceived withTitle:title fromDevice:device.deviceName wasSuccesful:succes];
}
- (void)writeTransmissionToLog:(NSString *)title fromDevice:(Device *)device wasSuccesful:(BOOL)succes;{
	[self writeToLog:SRLSend withTitle:title fromDevice:device.deviceName wasSuccesful:succes];
}

- (void)doClearLogFile{
	if(_logFile)
		[_logFile release];
	
	NSMutableArray *_logEntriesSend = [[NSMutableArray alloc] initWithCapacity:0];
	NSMutableArray *_logEntriesReceived = [[NSMutableArray alloc] initWithCapacity:0];
	_logFile = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:_logEntriesSend,_logEntriesReceived,nil] forKeys:[NSArray arrayWithObjects:kLogDictionarySend,kLogDictionaryReceived,nil]];
	[_logEntriesSend release];
	[_logEntriesReceived release];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	
	NSString *logFilePath = [documentsPath stringByAppendingPathComponent:kLogFileNameAndType];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	// If the expected store doesn't exist, copy the default store.
	if ([fileManager fileExistsAtPath:logFilePath]) {
		[fileManager removeItemAtPath:logFilePath error:&error];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLogHasChanged object:nil userInfo:nil];
}

- (void)clearLogFile{
	UIAlertView *confirmationView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SendReceiveLogger_CLEAR_LOG_PROMPT_TITLE", @"Clear log confirmation")
															   message:NSLocalizedString(@"SendReceiveLogger_CLEAR_LOG_PROMPT_MESSAGE", @"Clear log confirmation message")
															  delegate:self
													 cancelButtonTitle:NSLocalizedString(@"General_NO", @"No")
													 otherButtonTitles:NSLocalizedString(@"General_YES", @"Yes"),nil];
	
	[confirmationView show];
	[confirmationView release];

}
- (NSArray *)getLogEntriesSend {
	return [_logFile objectForKey:kLogDictionarySend];
}
- (NSArray *)getLogEntriesReceived{	
	return [_logFile objectForKey:kLogDictionaryReceived];
}

#pragma mark -
#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1) { // YES
		[self doClearLogFile];
	} 
	
}

#pragma mark -
#pragma mark Singlton methods

+ (SendReceiveLogger *)sharedSendReceiveLogger
{
	if (gsharedSendReceiveLogger == nil) {
        gsharedSendReceiveLogger = [[super allocWithZone:NULL] init];
    }
    return gsharedSendReceiveLogger;
	/*	
    @synchronized(self) {
        if (gsharedSendReceiveLogger == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return gsharedSendReceiveLogger;
	 */
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedSendReceiveLogger] retain];
}

/*
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (gsharedSendReceiveLogger == nil) {
            gsharedSendReceiveLogger = [super allocWithZone:zone];
            return gsharedSendReceiveLogger;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}
*/
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}


@end
