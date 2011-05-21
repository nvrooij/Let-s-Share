//
//  settingsTableViewController.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 04-08-09.
//

#import "settingsTableViewController.h"
#import "SendReceiveLogger.h"
#import "DefaultsController.h"

@interface settingsTableViewController()
- (void)settingsChangedReloadTable;
@end


@implementation settingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:UITableViewStylePlain]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.title = NSLocalizedString(@"settingsTableViewController_MAIN_TITLE",@"settingsTableViewController Main Title");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if (section == 0){
		// Title for Contact selector
		return NSLocalizedString(@"settingsTableViewController_SETTING_1_TITLE_HEADER",@"settingsTableViewController Setting 1 Title Header");
	}else if (section == 1){
		return NSLocalizedString(@"settingsTableViewController_SETTING_2_TITLE_HEADER",@"settingsTableViewController Setting 2 Title Header");
	}else if (section == 2){
		return NSLocalizedString(@"settingsTableViewController_SETTING_3_TITLE_HEADER",@"settingsTableViewController Setting 3 Title Header");
	}else if (section == 3){
		return NSLocalizedString(@"settingsTableViewController_SETTING_4_TITLE_HEADER",@"settingsTableViewController Setting 4 Title Header");
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	if (section == 0){
		return NSLocalizedString(@"settingsTableViewController_SETTING_1_TITLE_FOOTER",@"settingsTableViewController Setting 1 Title Footer");
	}else if (section == 1){
		return NSLocalizedString(@"settingsTableViewController_SETTING_2_TITLE_FOOTER",@"settingsTableViewController Setting 2 Title Footer");
	}else if (section == 2){
		return NSLocalizedString(@"settingsTableViewController_SETTING_3_TITLE_FOOTER",@"settingsTableViewController Setting 3 Title Footer");
	}else if (section == 3){
		return NSLocalizedString(@"settingsTableViewController_SETTING_4_TITLE_FOOTER",@"settingsTableViewController Setting 4 Title Footer");
	}
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	if((indexPath.row == 0) && (indexPath.section == 0)){
		cell.textLabel.text = NSLocalizedString(@"settingsTableViewController_SETTING_1_TITLE",@"settingsTableViewController Setting 1 Title");
		cell.detailTextLabel.text = [[DefaultsController sharedDefaultsController] getMyContactDisplayName];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if ((indexPath.row == 0) && (indexPath.section == 1)){
		cell.textLabel.text = NSLocalizedString(@"settingsTableViewController_SETTING_2_TITLE",@"settingsTableViewController Setting 2 Title");

		
        CGRect frame = CGRectMake(218.0, 8.0, 94.0, 27.0);
        UISwitch *editBeforeSending = [[UISwitch alloc] initWithFrame:frame];
        [editBeforeSending addTarget:self action:@selector(switchActionEditBeforeSending:) forControlEvents:UIControlEventValueChanged];
        editBeforeSending.on = [[DefaultsController sharedDefaultsController] editBeforeSendingPhoto];
        // in case the parent view draws with a custom color or gradient, use a transparent color
        editBeforeSending.backgroundColor = [UIColor clearColor];
		
		[cell.contentView addSubview:editBeforeSending];
		[editBeforeSending release];
		
		cell.detailTextLabel.text = nil;
		cell.accessoryType = UITableViewCellAccessoryNone;		
	} else if((indexPath.row == 0) && (indexPath.section == 2)){		
		cell.textLabel.text = NSLocalizedString(@"settingsTableViewController_SETTING_3_TITLE",@"settingsTableViewController Setting 3 Title");
		cell.detailTextLabel.text = nil;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if((indexPath.row == 0) && (indexPath.section == 3)){		
		cell.textLabel.text = NSLocalizedString(@"settingsTableViewController_SETTING_4_TITLE",@"settingsTableViewController Setting 4 Title");
		cell.detailTextLabel.text = [[DefaultsController sharedDefaultsController] getAppVersion];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0 && indexPath.row == 0){
		[[DefaultsController sharedDefaultsController] configureMyContactAndReplyTo:self selector:@selector(settingsChangedReloadTable) errorSelector:nil inMainWindow:[self.navigationController parentViewController]];
	}else if(indexPath.section == 2 && indexPath.row == 0){
		[[SendReceiveLogger sharedSendReceiveLogger] clearLogFile];
	}else if(indexPath.section == 3 && indexPath.row == 0){
		if(!aboutScreenViewController)
			aboutScreenViewController = [[AboutScreenViewController alloc] initWithNibName:@"AboutScreenViewController" bundle:[NSBundle mainBundle]];
		[[self.view window] addSubview:aboutScreenViewController.view];
		aboutScreenViewController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:1];
		aboutScreenViewController.view.alpha = 1.0;
		[UIView commitAnimations];	
	}
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];	
}

- (void)dealloc {
	[aboutScreenViewController release];
	aboutScreenViewController = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Helper
- (void)settingsChangedReloadTable{
	[self.tableView reloadData];
}

- (void)switchActionEditBeforeSending:(id)sender
{
	[[DefaultsController sharedDefaultsController] setEditBeforeSendingPhoto:[sender isOn]];
}

@end

