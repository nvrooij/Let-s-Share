//
//  transmitObjectImageViewcontroller.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 16-08-09.
//

#import <UIKit/UIKit.h>
#import "TransmitObject.h"

@interface transmitObjectImageViewcontroller : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate>{
	IBOutlet UIImageView *imageView;
	IBOutlet UIButton *saveButton;
	TransmitObjects *transmitObjects;
	UIActionSheet *writeToFileSheet;
}
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) TransmitObjects *transmitObjects;

- (IBAction)saveImage:(id)sender;

@end
