/*
 
*/

#import "Device.h"

@interface DevicesManager : NSObject {
	NSMutableArray *devices;
	BOOL duplicateDeviceNamesFound;
}

- (void)addDevice:(Device *)device;
- (void)removeDevice:(Device *)device;
- (Device *)deviceWithID:(NSString *)peerID;

@property (nonatomic, readonly) NSArray *sortedDevices;
@property (readonly) BOOL duplicateDeviceNamesFound;

@end
