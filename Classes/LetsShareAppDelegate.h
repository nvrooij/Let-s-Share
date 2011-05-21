//
//  ShareWithFriendsAppDelegate.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 04-08-09.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "AudioToolbox/AudioToolbox.h"
#import "SessionManager.h"
#import "DevicesManager.h"
#import "TransmitDataHandler.h"

@interface LetsShareAppDelegate : NSObject <UIApplicationDelegate, TransmitDataHandlerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	
	SessionManager *sessionManager;
	TransmitDataHandler *dataHandler;
	DevicesManager *devicesManager;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) SessionManager *sessionManager;
@property (nonatomic, retain) TransmitDataHandler *dataHandler;
@property (nonatomic, retain) DevicesManager *devicesManager;

- (ABRecordID)getMyContactID;
- (void)handleReceivedData;

@end

