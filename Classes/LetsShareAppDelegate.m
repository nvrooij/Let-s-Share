//
//  ShareWithFriendsAppDelegate.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 04-08-09.
//

#import "LetsShareAppDelegate.h"
#import "rootShareTableViewController.h"
#import "settingsTableViewController.h"
#import "logTableViewController.h"
#import "SendReceiveLogger.h"
#import "TransmitDataHandler.h"
#import "TransmitObject.h"
#import "transmitObjectsViewController.h"
#import "transmitObjectImageViewcontroller.h"

#define MY_CONTACT_ID_PROP @"MY_CONTACT_ID"
#define AVAILABLE_SOUND_FILE_NAME "available"
#define UNAVAILABLE_SOUND_FILE_NAME "unavailable"


@implementation LetsShareAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize devicesManager;
@synthesize sessionManager;
@synthesize dataHandler;

- init {
	if (self = [super init]) {
		// initialize  to nil
		window = nil;
		tabBarController = nil;
		[SendReceiveLogger sharedSendReceiveLogger];
	}
	return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Create the tabbar controller
	
	tabBarController = [[UITabBarController alloc] init];
	NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] initWithCapacity:1];
	
	
	UINavigationController *localNavigationController;
	
	// Create the share viewController
	
	rootShareTableViewController *shareController = [[rootShareTableViewController alloc] init];
	
	localNavigationController = [[UINavigationController alloc] initWithRootViewController:shareController];
	[shareController release];
	
	localNavigationController.tabBarItem.title = NSLocalizedString(@"ShareWithFriendsAppDelegate_TABBAR_ITEM_1_TITLE", @"ShareWithFriendsAppDelegate_TABBAR_ITEM_1_TITLE");
	localNavigationController.tabBarItem.image = [UIImage imageNamed:@"share.png"];
	
	
	[localViewControllersArray addObject:localNavigationController];
	[localNavigationController release];
	
	// Create the log viewController
	logTableViewController *logController = [[logTableViewController alloc] init];
	
	localNavigationController = [[UINavigationController alloc] initWithRootViewController:logController];
	[logController release];
	
	UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:1];
	
	localNavigationController.tabBarItem = tabBarItem;
	[tabBarItem release];	
	
	[localViewControllersArray addObject:localNavigationController];
	[localNavigationController release];
	
	
	// Create the settings viewController
	settingsTableViewController *settingsController = [[settingsTableViewController alloc] init];
	
	localNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsController];
	[settingsController release];
	
	localNavigationController.tabBarItem.title = NSLocalizedString(@"ShareWithFriendsAppDelegate_TABBAR_ITEM_3_TITLE", @"ShareWithFriendsAppDelegate_TABBAR_ITEM_3_TITLE");
	localNavigationController.tabBarItem.image = [UIImage imageNamed:@"settings.png"];	
	
	[localViewControllersArray addObject:localNavigationController];
	[localNavigationController release];
	
	
	// set the tab bar controller view controller array to the localViewControllersArray
	tabBarController.viewControllers = localViewControllersArray;
	
	// the localViewControllersArray data is now retained by the tabBarController
	// so we can release this version
	[localViewControllersArray release];
	
	devicesManager = [[DevicesManager alloc] init];
	dataHandler = [[TransmitDataHandler alloc] initWithDevicesManager:devicesManager andMainViewController:tabBarController];
	dataHandler.delegate = self;
	
	//dataHandler = [[DataHandler alloc] initWithDataProvider:[self createSpecificDataProvider] devicesManager:devicesManager];
	sessionManager = [[SessionManager alloc] initWithDataHandler:dataHandler devicesManager:devicesManager];
	
	[sessionManager start];

	[window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
	[dataHandler release];
	[sessionManager release];
	[devicesManager release];
    [window release];
    [super dealloc];
}

- (ABRecordID)getMyContactID {
	NSString *loadedContactID = [[NSUserDefaults standardUserDefaults] objectForKey:MY_CONTACT_ID_PROP];
	if (loadedContactID)
		return [loadedContactID intValue];
	else
		return 0;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
	UIAlertView *confirmationView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ShareWithFriendsAppDelegate_MEMORY_WARNING_TITLE",@"ShareWithFriendsAppDelegate_MEMORY_WARNING_TITLE")
															   message:NSLocalizedString(@"ShareWithFriendsAppDelegate_MEMORY_WARNING_MESSAGE",@"ShareWithFriendsAppDelegate_MEMORY_WARNING_MESSAGE")
															  delegate:nil
													 cancelButtonTitle:NSLocalizedString(@"General_OK",@"General_OK")
													 otherButtonTitles:nil];
	
	[confirmationView show];
	[confirmationView release];
}

#pragma mark -
#pragma mark TransmitDataHandlerDelegate

- (void)cancel{
	[tabBarController dismissModalViewControllerAnimated:YES];
}

- (void)handleReceivedData{
	[tabBarController dismissModalViewControllerAnimated:NO];
	TransmitObjects *objectsReceived = [dataHandler.transmitObjects retain];
	TransmitObject *firstObject = [objectsReceived.objects objectAtIndex:0];
	UINavigationController *navController;
	switch (firstObject.type) {
		case TMOTContact:{
			transmitObjectsViewController *transViewController = [[transmitObjectsViewController alloc] initWithStyle:UITableViewStylePlain];
			transViewController.transmitObjects = objectsReceived;
			navController = [[UINavigationController alloc] initWithRootViewController:transViewController];
			
			[transViewController release];				
		}
			break;			
		default:{
			transmitObjectImageViewcontroller *transViewImageController = [[transmitObjectImageViewcontroller alloc] initWithNibName:@"transmitObjectImageViewcontroller" bundle:[NSBundle mainBundle]];
			transViewImageController.transmitObjects = objectsReceived;
			navController = [[UINavigationController alloc] initWithRootViewController:transViewImageController];
			
			UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancel)];
			transViewImageController.navigationItem.leftBarButtonItem = btn;
			[btn release];
			[transViewImageController release];				
		}
			break;
	}
	

	[tabBarController presentModalViewController:navController animated:YES];
	
	[navController release];		
	
	[objectsReceived release];
}



@end
