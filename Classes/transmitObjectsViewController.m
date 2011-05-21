//
//  transmitObjectsViewController.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 15-08-09.
//

#import "transmitObjectsViewController.h"
#import "TransmitObjectCell.h"
#import "ABRecordSerializer.h"

@implementation transmitObjectsViewController
@synthesize transmitObjects;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"transmitObjectsViewController_MAIN_TITLE",@"transmitObjectsViewController Main Title");

	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"transmitObjectsViewController_BUTTON_SAVE_ALL",@"transmitObjectsViewController_BUTTON_SAVE_ALL") style:UIBarButtonItemStylePlain target:self action:@selector(saveAll:)];
	self.navigationItem.rightBarButtonItem = button;
	[button release];
	UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	self.navigationItem.leftBarButtonItem = btn;
	[btn release];
	
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [transmitObjects.objects count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    TransmitObjectCell *cell = (TransmitObjectCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TransmitObjectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	TransmitObject *currentObject = [transmitObjects.objects objectAtIndex:indexPath.row];
	
	cell.object = currentObject;
	
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	TransmitObject *object = [transmitObjects.objects objectAtIndex:indexPath.row];
	switch (object.type) {
		case TMOTContact: {
			currentIndexPath = [indexPath retain];
			ABRecordRef newPerson = [ABRecordSerializer newPersonFromData:object.data];
			if(newPerson != NULL) {						
				ABUnknownPersonViewController *addPersonViewController = [[ABUnknownPersonViewController alloc] init];
				addPersonViewController.unknownPersonViewDelegate = self;
				addPersonViewController.displayedPerson = newPerson;
				addPersonViewController.allowsActions = NO;
				addPersonViewController.allowsAddingToAddressBook = YES;
				
				addPersonViewController.navigationItem.title = NSLocalizedString(@"transmitObjectsViewController_ADDCONTACT_VIEWCONTROLLER_TITLE",@"transmitObjectsViewController_ADDCONTACT_VIEWCONTROLLER_TITLE");
				UIBarButtonItem *cancelButton =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																							   target:self action:@selector(cancelContact:)];
				addPersonViewController.navigationItem.leftBarButtonItem = cancelButton;
				[self.navigationController pushViewController:addPersonViewController animated:YES];
				
				[cancelButton release];
				[addPersonViewController release];
				CFRelease(newPerson);
			}
		}
			break;
		case TMOTImage:
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark ModalView actions
- (void)cancelContact:(id)sender {
	[currentIndexPath release];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark ABUnknownPersonViewControllerDelegate
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person {
	
	[transmitObjects.objects removeObjectAtIndex:currentIndexPath.row];
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:currentIndexPath] withRowAnimation:YES];
	[currentIndexPath release];

	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark SaveAll
- (void)saveAll:(id)sender{
	ABAddressBookRef ab = ABAddressBookCreate();
	for (TransmitObject *object in transmitObjects.objects){
		ABRecordRef newPerson = [ABRecordSerializer newPersonFromData:object.data];
		ABAddressBookAddRecord(ab, newPerson, nil);
		CFRelease(newPerson);
	}
	ABAddressBookSave(ab, nil);
	CFRelease(ab);
	[[self.navigationController parentViewController] dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Done
- (void)done:(id)sender{
	if ([transmitObjects.objects count]){
		UIAlertView *confirmationView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"transmitObjectsViewController_UNSAVED_CONTACTS_ALERT_TITLE", @"transmitObjectsViewController_UNSAVED_CONTACTS_ALERT_TITLE")
																   message:NSLocalizedString(@"transmitObjectsViewController_UNSAVED_CONTACTS_ALERT_MESSAGE", @"transmitObjectsViewController_UNSAVED_CONTACTS_ALERT_TITLE")
																  delegate:self
														 cancelButtonTitle:NSLocalizedString(@"General_YES", @"Yes")
														 otherButtonTitles:NSLocalizedString(@"General_NO", @"No"),nil];
		
		[confirmationView show];
		[confirmationView release];
		
	}
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex==0){ //Yes
		[[self.navigationController parentViewController] dismissModalViewControllerAnimated:YES];
	}
}

@end

