//
//  logTableViewController.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 11-08-09.
//

#import "logTableViewController.h"
#import "SendReceiveLogger.h"
#import "LogFileEntryCell.h"

@interface logTableViewController()
- (void)logHasChanged;
@end


@implementation logTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.tableView.allowsSelection = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"logTableViewController_MAIN_TITLE",@"logTableViewController Main Title");
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logHasChanged) name:kNotificationLogHasChanged object:nil];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:kNotificationLogHasChanged];
}


#pragma mark Table view methods

/*
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
	return [NSArray arrayWithObjects:@"up",@"down",nil];
}
*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	SendReceiveLogger *l = [SendReceiveLogger sharedSendReceiveLogger];	
	if(section==0){		
		if([l.logEntriesSend count])
			return NSLocalizedString(@"logTableViewController_UITABLEVIEWHEADER_SEND",@"LOG UITABLEVIEWHEADER SEND");
		else
			return nil;
	}else{
		if([l.logEntriesReceived count])
			return NSLocalizedString(@"logTableViewController_UITABLEVIEWHEADER_RECEIVED",@"LOG UITABLEVIEWHEADER RECEIVED");
		else
			return nil;
	}
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	SendReceiveLogger *l = [SendReceiveLogger sharedSendReceiveLogger];
	NSArray *n;
	if (section==0){
		n = l.logEntriesSend;		
	} else{
		n = l.logEntriesReceived;		
	}
	return [n count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    LogFileEntryCell *cell = (LogFileEntryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[LogFileEntryCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
       // cell = [[[LogFileEntryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		//cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	LogFileEntry *entry;
	if (indexPath.section==0){
		entry = (LogFileEntry *)[[SendReceiveLogger sharedSendReceiveLogger].logEntriesSend objectAtIndex:indexPath.row];
	} else{
		entry = (LogFileEntry *)[[SendReceiveLogger sharedSendReceiveLogger].logEntriesReceived objectAtIndex:indexPath.row];
	}
    
    // Set up the cell...
	cell.logFileEntry = entry;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)logHasChanged{
	[self.tableView reloadData];
}

- (void)dealloc {
    [super dealloc];
}


@end

