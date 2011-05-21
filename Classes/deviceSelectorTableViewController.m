//
//  deviceSelectorTableViewController.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 05-08-09.
//

#import "deviceSelectorTableViewController.h"
#import "DevicesManager.h"
#import "Device.h"
#import "DeviceCell.h"
#import "SessionManager.h"
#import <AddressBook/AddressBook.h>
#import "rootShareTableViewController.h"

@implementation deviceSelectorTableViewController
@synthesize transmitObjects;

#pragma mark -
#pragma mark Initializers
- (id)initWithTransmitObjects:(TransmitObjects *)objects{
	if(self = [super init]){
		transmitObjects = [objects retain];
	}
	return self;
}

#pragma mark -
#pragma mark Notification Responders
- (void)deviceListChanged:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	appDelegate = (LetsShareAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.title = NSLocalizedString(@"deviceSelectorTableViewController_MAIN_TITLE",@"deviceSelectorTableViewController Main Title");
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceListChanged:) name:NOTIFICATION_DEVICE_AVAILABLE object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceListChanged:) name:NOTIFICATION_DEVICE_UNAVAILABLE object:nil];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:NOTIFICATION_DEVICE_AVAILABLE];
	[[NSNotificationCenter defaultCenter] removeObserver:NOTIFICATION_DEVICE_UNAVAILABLE];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.navigationItem.prompt = [NSString stringWithFormat:NSLocalizedString(@"deviceSelectorTableViewController_UITABLEVIEWHEADER_SENDING", @"deviceSelectorTableViewController_UITABLEVIEWHEADER_SENDING"), transmitObjects.title];
	[self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([appDelegate.devicesManager.sortedDevices count]){
		if ([appDelegate.devicesManager duplicateDeviceNamesFound])
			tableView.allowsSelection = NO;
		else
			tableView.allowsSelection = YES;
		return [appDelegate.devicesManager.sortedDevices count];		
	} else{
		tableView.allowsSelection = FALSE;
		return 1;
	}
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"DeviceCell";
	

	DeviceCell *cell = (DeviceCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[[DeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	if ([appDelegate.devicesManager.sortedDevices count]){
		Device *device = ((Device *) [appDelegate.devicesManager.sortedDevices objectAtIndex:indexPath.row]);
		cell.device = device;		
	}else
		cell.device = nil;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	if ([appDelegate.devicesManager.sortedDevices count]){
		DeviceCell *cell = (DeviceCell *) [tableView cellForRowAtIndexPath:indexPath];
		Device *device = cell.device;

		[appDelegate.dataHandler sendTransmitObjects:transmitObjects toDevice:device];
		[[self navigationController] popToRootViewControllerAnimated:YES];
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

//	[transmitObjects release];
    [super dealloc];
}


@end

