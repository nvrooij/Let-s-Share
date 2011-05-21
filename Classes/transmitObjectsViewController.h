//
//  transmitObjectsViewController.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 15-08-09.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "TransmitObject.h"


@interface transmitObjectsViewController : UITableViewController <ABUnknownPersonViewControllerDelegate, UIAlertViewDelegate>{
	TransmitObjects *transmitObjects;
	NSIndexPath *currentIndexPath;
}
@property (nonatomic, retain) TransmitObjects *transmitObjects;

@end
