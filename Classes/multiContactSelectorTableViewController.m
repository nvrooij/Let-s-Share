//
//  multiContactSelectorTableViewController.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 14-08-09.
//

#import "multiContactSelectorTableViewController.h"
#import "TransmitObject.h"
#import "deviceSelectorTableViewController.h"


@implementation multiContactSelectorTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact:)];
	self.navigationItem.rightBarButtonItem = button;
	[button release];
	
	selectedRecordList = [[NSMutableArray alloc] init];
	self.title = NSLocalizedString(@"multiContactSelectorTableViewController_MAIN_TITLE",@"multiContactSelectorTableViewController Main Title");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	//Create a button
	UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
	UIBarButtonItem *infoButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"multiContactSelectorTableViewController_BUTTON_SHARE", @"multiContactSelectorTableViewController_BUTTON_SHARE") style:UIBarButtonItemStyleBordered target:self action:@selector(sendContacts)] autorelease];
//	infoButton.width = rootViewWidth - 15;
	
	[self setToolbarItems:[NSArray arrayWithObjects:flex,infoButton,flex,nil] animated:YES];
	[self.navigationController setToolbarHidden:NO animated:YES];
}
 
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	//Initialize the toolbar
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return UITableViewCellEditingStyleDelete;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [selectedRecordList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	NSDictionary *dict = [selectedRecordList objectAtIndex:indexPath.row];
	
	cell.textLabel.text = [dict objectForKey:@"compositeName"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		[selectedRecordList removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)addContact:(id)sender{
	ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
	peoplePicker.peoplePickerDelegate = self;
	peoplePicker.navigationBar.topItem.title = NSLocalizedString(@"multiContactSelectorTableViewController_CONTACT_PICKER_TITLE", @"multiContactSelectorTableViewController_CONTACT_PICKER_TITLE");
	[self presentModalViewController:peoplePicker animated:YES];
	[peoplePicker release];
	
}

- (void)sendContacts{
	if([selectedRecordList count]){
		
		TransmitObjects *tmObjects = [[TransmitObjects alloc] init];	

		for(NSDictionary *contact in selectedRecordList){
			[tmObjects addContact:[contact objectForKey:@"recordID"]];		
		}
		deviceSelectorTableViewController *selectDevice = [[deviceSelectorTableViewController alloc] initWithTransmitObjects:tmObjects];
		[tmObjects release];
		
		[self.navigationController pushViewController:selectDevice animated:YES];
		[selectDevice release];
	}else{
		UIAlertView *confirmationView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"multiContactSelectorTableViewController_NO_RECORDS_SELECTED_TITLE", @"multiContactSelectorTableViewController_NO_RECORDS_SELECTED_TITLE")
																   message:NSLocalizedString(@"multiContactSelectorTableViewController_NO_RECORDS_SELECTED_MESSAGE", @"multiContactSelectorTableViewController_NO_RECORDS_SELECTED_MESSAGE")
																  delegate:nil
														 cancelButtonTitle:NSLocalizedString(@"General_OK", @"General_OK")
														 otherButtonTitles:nil];
		
		[confirmationView show];
		[confirmationView release];
		
	}
}

#pragma mark -
#pragma mark PeoplePicker Delegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:NO];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	ABRecordID myContactID = ABRecordGetRecordID(person);
	CFStringRef compositeName = ABRecordCopyCompositeName(person);
	NSString *strCompositeName = [NSString stringWithFormat:@"%@",compositeName];
	NSString *strMyContactID = [NSString stringWithFormat:@"%d", myContactID];
	
	NSDictionary *dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:strCompositeName, strMyContactID,nil] 
													   forKeys:[NSArray arrayWithObjects:@"compositeName",@"recordID",nil]];
	if (![selectedRecordList containsObject:dict])
		[selectedRecordList addObject:dict];
	[dict release];
	CFRelease(compositeName);
	
	[self dismissModalViewControllerAnimated:YES];
	[self.tableView reloadData];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}


- (void)dealloc {
	[selectedRecordList release];
	
    [super dealloc];
}


@end

