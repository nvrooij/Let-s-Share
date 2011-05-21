//
//  rootShareTableViewController.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 04-08-09.
//

#import "rootShareTableViewController.h"
#import "menuItem.h"
#import "deviceSelectorTableViewController.h"
#import "multiContactSelectorTableViewController.h"
#import "menuItemCell.h"
#import "DefaultsController.h"


@interface rootShareTableViewController()
- (void)sendMyContact;
@end


@implementation rootShareTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	appDelegate = (LetsShareAppDelegate *)[[UIApplication sharedApplication] delegate];

	NSString *path = [[NSBundle mainBundle] pathForResource:@"shareMenuList" ofType:@"plist"];
	menuList = [[NSArray alloc] initWithContentsOfFile:path];
	self.title = NSLocalizedString(@"rootShareTableViewController_MAIN_TITLE",@"rootShareTableViewController Main Title");
	/*
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:(appDelegate.sessionManager.isStarted)?@"Visible":@"Invisible" style:UIBarButtonItemStylePlain target:self action:@selector(setVisibility)];
	self.navigationItem.rightBarButtonItem = button;
	[button release];
	 */
//	[self retain];
//	self.view.hidden = YES; // when there's no ad, let our (placeholder) view be unobstructive
	
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:YES animated:YES];
	
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Button Actions
/*
- (void)setVisibility{
	(appDelegate.sessionManager.isStarted)?[appDelegate.sessionManager stop]:[appDelegate.sessionManager start];
	UIBarButtonItem *button = self.navigationItem.rightBarButtonItem;
	button.title = (appDelegate.sessionManager.isStarted)?@"Visible":@"Invisible";
}
 */

#pragma mark -
#pragma mark Table view methods
 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [menuList count];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	// Section title is the region name
	NSDictionary *dict = [menuList objectAtIndex:section];
	NSString *localizedTitleIdentifier = [dict objectForKey:@"Title"];
	NSString *title = NSLocalizedString(localizedTitleIdentifier,localizedTitleIdentifier);
	return title;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSDictionary *dict = [menuList objectAtIndex:section];
	NSArray *menuItems = [dict objectForKey:@"MenuItems"];
	return [menuItems count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    menuItemCell *cell = (menuItemCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell = [[[menuItemCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	NSDictionary *dict = [menuList objectAtIndex:indexPath.section];
	NSArray *menuItems = [dict objectForKey:@"MenuItems"];
	menuItem *item = [menuItem newItemWithDictionary:[menuItems objectAtIndex:indexPath.row]];
	cell.item = item;
	[item release];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row == 0 && indexPath.section == 0){
		// Send my contact
		if ([[DefaultsController sharedDefaultsController] contactIsSet]) {
			[self sendMyContact];
		} else {
			[[DefaultsController sharedDefaultsController] configureMyContactAndReplyTo:self selector:@selector(sendMyContact) errorSelector:nil inMainWindow:[self.navigationController parentViewController]];
		}
	}else if(indexPath.row == 1 && indexPath.section == 0){
		// Send other contacts
		multiContactSelectorTableViewController *selectContacts = [[multiContactSelectorTableViewController alloc] init];
		[self.navigationController pushViewController:selectContacts animated:YES];
		[selectContacts release];
	} else if (indexPath.row == 0 && indexPath.section == 1){
		// Send a photo
		UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.allowsEditing = [[DefaultsController sharedDefaultsController] editBeforeSendingPhoto];
//		imgPicker.allowsImageEditing = [[DefaultsController sharedDefaultsController] editBeforeSendingPhoto];
		imgPicker.delegate = self;
		imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentModalViewController:imgPicker animated:YES];
		[imgPicker release];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 80;
}

- (void)sendMyContact{
	TransmitObjects *tmObjects = [[TransmitObjects alloc] init];
	[tmObjects addContact:[[DefaultsController sharedDefaultsController] getMyContactIDStr]];
	deviceSelectorTableViewController *selectDevice = [[deviceSelectorTableViewController alloc] initWithTransmitObjects:tmObjects];
	[tmObjects release];			
	[self.navigationController pushViewController:selectDevice animated:YES];
	[selectDevice release];
	
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[menuList release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
	TransmitObjects *tmObjects = [[TransmitObjects alloc] init];
	if ([[DefaultsController sharedDefaultsController] editBeforeSendingPhoto])
		 [tmObjects addImage:[info objectForKey:UIImagePickerControllerEditedImage]];
	else
		 [tmObjects addImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
	
	deviceSelectorTableViewController *selectDevice = [[deviceSelectorTableViewController alloc] initWithTransmitObjects:tmObjects];
	[tmObjects release];
	
	[self.navigationController pushViewController:selectDevice animated:YES];
	[selectDevice release];
		
}

/*
- (BOOL)useTestAd {
	return YES;
}
*/

// To receive test ads rather than real ads...
/*
 - (BOOL)useTestAd {
 return YES;
 }
 
 - (NSString *)testAdAction {
 return @"url"; // see AdMobDelegateProtocol.h for a listing of valid values here
 }
 */



@end

