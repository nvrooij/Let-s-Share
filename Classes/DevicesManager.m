/*
 */

#import "DevicesManager.h"

@interface DevicesManager() 
- (BOOL)duplicateDevicenamesInArray;
@end



@implementation DevicesManager
@synthesize duplicateDeviceNamesFound;

- (id)init {
	if (self = [super init]){
		devices = [[NSMutableArray alloc] init];
		duplicateDeviceNamesFound = NO;
	}
	return self;
}

- (NSArray *)sortedDevices {
	return devices;
}

- (void)addDevice:(Device *)device {
	[devices addObject:device];
	// Start Sorting
	NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deviceName" ascending:YES];
	[devices sortUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
	[nameDescriptor release];
	duplicateDeviceNamesFound = [self duplicateDevicenamesInArray];
}

- (void)removeDevice:(Device *)device {
	if (device) 
		[devices removeObject:device];
	duplicateDeviceNamesFound = [self duplicateDevicenamesInArray];
}

- (Device *)deviceWithID:(NSString *)peerID {
	for (Device *d in devices)
		if ([d.peerID isEqual:peerID]) 
			return d;
	
	return nil;
}

- (void)dealloc {
	[devices release];
	[super dealloc];
}

#pragma mark -
#pragma mark Private

// V1.1
- (BOOL)duplicateDevicenamesInArray{
	for (int i=1;i<[devices count];i++){
		Device *d1 = [devices objectAtIndex:i-1];
		Device *d2 = [devices objectAtIndex:i];
		if ([d1.deviceName isEqualToString:d2.deviceName]) {
			return YES;
		}
	}	
	return NO;
}


@end
