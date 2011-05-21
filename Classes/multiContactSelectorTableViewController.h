//
//  multiContactSelectorTableViewController.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 14-08-09.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface multiContactSelectorTableViewController : UITableViewController <ABPeoplePickerNavigationControllerDelegate> {\
	UIToolbar *toolbar;
	NSMutableArray *selectedRecordList;
}

@end
