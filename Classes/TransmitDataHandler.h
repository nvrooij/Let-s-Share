//
//  TransmitDataHandler.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 14-08-09.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DevicesManager.h"
#import "Device.h"
#import "TransmitObject.h"
#import <AudioToolbox/AudioToolbox.h>

typedef enum {
	TMDHSNone = 0,
	TMDHSReceiving = 1,
	TMDHSSending = 2
} TransmitDataHandlerState;

@protocol TransmitDataHandlerDelegate <NSObject>
- (void)handleReceivedData;
@end

	
@interface TransmitDataHandler : NSObject <UIActionSheetDelegate, UIAlertViewDelegate>{
	id<TransmitDataHandlerDelegate> delegate;
	TransmitDataHandlerState _currentState;
	DevicesManager *_devicesManager;
	Device *_currentStateRelatedDevice;
	NSString *_lastCommandReceived;
	NSString *_currentStateRelatedReceiveTitle;
	
	NSTimer *connectionTimedOut;
	
	UIViewController *_mainViewController;
	
	TransmitObjects *_tmObjects;

	NSMutableData *_dataReceived;
	NSData *_dataToSend;
	
	int _bytesToReceive;
	int _bytesSend;
	BOOL _cancelled;
	BOOL _cancelledByHost;
	
	UIActionSheet *_currentPopUpSheetView;
	UIProgressView *_progressView;
	NSTimer *timer;
	
	//Sounds
	SystemSoundID errorSound;
	SystemSoundID receivedSound;
	SystemSoundID requestSound;
	SystemSoundID sendSound;
}

@property(assign, nonatomic) id<TransmitDataHandlerDelegate> delegate;
@property(getter=getTransmitObjects,readonly) TransmitObjects *transmitObjects;

- (id)initWithDevicesManager:(DevicesManager *)devicesManager andMainViewController:(UIViewController *)viewController;

- (void)sendTransmitObjects:(TransmitObjects *)objects toDevice:(Device *)device;
						  
@end
