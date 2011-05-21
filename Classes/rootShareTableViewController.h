//
//  rootShareTableViewController.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 04-08-09.
//

#import <UIKit/UIKit.h>
#import "LetsShareAppDelegate.h"

@interface rootShareTableViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
	LetsShareAppDelegate *appDelegate;
	NSArray *menuList;
}
@end
