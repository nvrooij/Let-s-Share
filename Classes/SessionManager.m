/*
 
*/

#import "SessionManager.h"

#define AVAILABLE_SOUND_FILE_NAME "available"
#define UNAVAILABLE_SOUND_FILE_NAME "unavailable"

@interface SessionManager (HelperMethods)

- (Device *)addDevice:(NSString *)peerID;
- (void)removeDevice:(Device *)device;
- (NSDictionary *)getDeviceInfo:(Device *)device;
- (BOOL)getVisibility;
- (void)loadSounds;
- (void)disposeSounds;

@end


@implementation SessionManager

- (id)initWithDataHandler:(TransmitDataHandler *)handler devicesManager:(DevicesManager *)manager {
	self = [super init];
	
	if (self) {
		[self loadSounds];
		devicesManager = manager;

		letsShare = [[GKSession alloc] initWithSessionID:LETS_SHARE_SESSION_ID displayName:nil sessionMode:GKSessionModePeer];
		letsShare.delegate = self;
		[letsShare setDataReceiveHandler:handler withContext:nil];
	}
	
	return self;
}

- (void)start {
	letsShare.available = YES;
}
- (void)stop {
	letsShare.available = NO;
}

#pragma mark -
#pragma mark SessionDelegateMethods
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	Device *currentDevice = [devicesManager deviceWithID:peerID];
	
	// Instead of trying to respond to the event directly, it delegates the events.
	// The availability is checked by the main ViewController.
	// The connection is verified by each Device.
	switch (state) {
		case GKPeerStateConnected:
			if (currentDevice) {
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_CONNECTED object:nil userInfo:[self getDeviceInfo:currentDevice]];
			}
			break;
		case GKPeerStateConnecting:
		case GKPeerStateAvailable:
			if (!currentDevice) {
				currentDevice = [self addDevice:peerID];
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_AVAILABLE object:nil userInfo:[self getDeviceInfo:currentDevice]];
			}				
			break;
		case GKPeerStateUnavailable:
			if (currentDevice) {
				[currentDevice retain];
				[self removeDevice:currentDevice];
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_UNAVAILABLE object:nil userInfo:[self getDeviceInfo:currentDevice]];
				[currentDevice release];
			}
			break;
		case GKPeerStateDisconnected:
			if (currentDevice) {
				[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_DISCONNECTED object:nil userInfo:[self getDeviceInfo:currentDevice]];
			}
			break;
	}
}
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	[letsShare acceptConnectionFromPeer:peerID error:nil];
}
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	Device *currentDevice = [devicesManager deviceWithID:peerID];
	
	// Does the same thing as the didStateChange method. It tells a Device that the connection failed.
	if (currentDevice) {
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DEVICE_CONNECTION_FAILED object:nil userInfo:[self getDeviceInfo:currentDevice]];
	}
}
- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
}

#pragma mark -
#pragma mark Category Helper Methods
- (Device *)addDevice:(NSString *)peerID {
//	AudioServicesPlaySystemSound(availableSound);
	Device *device = [[Device alloc] initWithSession:letsShare peer:peerID];
	[devicesManager addDevice:device];
	[device release];
	
	return device;
}

- (void)removeDevice:(Device *)device {
//	AudioServicesPlaySystemSound(unavailableSound);
	[devicesManager removeDevice:device];
}

- (NSDictionary *)getDeviceInfo:(Device *)device {
	return [NSDictionary dictionaryWithObject:device forKey:DEVICE_KEY];
}

// Getters
- (BOOL)getVisibility{
	return letsShare.available;
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	exit(0);
}


#pragma mark -
#pragma mark Dealloc
- (void)dealloc{
	[self disposeSounds];
	[letsShare release];
	[super dealloc];
}

#pragma mark -
#pragma mark Sounds
- (void)loadSounds {
	/*
	CFBundleRef mainBundle = CFBundleGetMainBundle();
	
	CFURLRef availableURL = CFBundleCopyResourceURL(mainBundle, CFSTR(AVAILABLE_SOUND_FILE_NAME), CFSTR("aiff"), NULL);
	CFURLRef unavailableURL = CFBundleCopyResourceURL(mainBundle, CFSTR(UNAVAILABLE_SOUND_FILE_NAME), CFSTR("aiff"), NULL);
	
	AudioServicesCreateSystemSoundID(availableURL, &availableSound);
	AudioServicesCreateSystemSoundID(unavailableURL, &unavailableSound);
	
	CFRelease(availableURL);
	CFRelease(unavailableURL);
	 */
}
- (void)disposeSounds{
	/*
	AudioServicesDisposeSystemSoundID(availableSound);
	AudioServicesDisposeSystemSoundID(unavailableSound);
	 */
}

@end
