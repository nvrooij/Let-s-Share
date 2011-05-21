//
//  deviceSelectorTableViewController.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 05-08-09.
//

#import <UIKit/UIKit.h>

#import "LetsShareAppDelegate.h";
#import "TransmitObject.h"


@interface deviceSelectorTableViewController : UITableViewController {
	LetsShareAppDelegate *appDelegate;
	TransmitObjects *transmitObjects;	
}
@property (nonatomic,readonly) TransmitObjects *transmitObjects;

- (id)initWithTransmitObjects:(TransmitObjects *)objects;

@end
