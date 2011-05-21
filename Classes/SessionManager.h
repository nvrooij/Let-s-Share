/*
 */

#import <GameKit/GameKit.h>
#import "TransmitDataHandler.h"
#import "DevicesManager.h"
#import "Device.h"
#import <AudioToolbox/AudioToolbox.h>

#define LETS_SHARE_SESSION_ID @"letsshare_uid"

#define NOTIFICATION_DEVICE_AVAILABLE @"notification_device_available"
#define NOTIFICATION_DEVICE_UNAVAILABLE @"notification_device_unavailable"
#define NOTIFICATION_DEVICE_CONNECTED @"notification_device_connected"
#define NOTIFICATION_DEVICE_CONNECTION_FAILED @"notification_device_connection_failed"
#define NOTIFICATION_DEVICE_DISCONNECTED @"notification_device_disconnected"

#define DEVICE_KEY @"Device"

@interface SessionManager : NSObject<GKSessionDelegate> {
	GKSession *letsShare;
	DevicesManager *devicesManager;
	SystemSoundID availableSound;
	SystemSoundID unavailableSound;
}
@property(getter=getVisibility, readonly) BOOL isStarted;

- (id)initWithDataHandler:(TransmitDataHandler *)handler devicesManager:(DevicesManager *)manager;
- (void)start;
- (void)stop;

@end
