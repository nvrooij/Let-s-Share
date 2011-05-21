//
//  transmitObjectImageViewcontroller.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 16-08-09.
//

#import "transmitObjectImageViewcontroller.h"


@implementation transmitObjectImageViewcontroller
@synthesize imageView;
@synthesize transmitObjects;
@synthesize saveButton;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	TransmitObject *object = [transmitObjects.objects objectAtIndex:0];
	self.title = NSLocalizedString(@"transmitObjectImageViewcontroller_MAIN_TITLE",@"transmitObjectImageViewcontroller_MAIN_TITLE");
	self.navigationItem.prompt = [NSString stringWithFormat:NSLocalizedString(@"transmitObjectImageViewcontroller_PROMT_IMAGE_SIZE",@"transmitObjectImageViewcontroller_PROMT_IMAGE_SIZE"), object.title];
	saveButton.titleLabel.text = NSLocalizedString(@"transmitObjectImageViewcontroller_BUTTON_SAVE_PHOTO", @"transmitObjectImageViewcontroller_BUTTON_SAVE_PHOTO");
	
	imageView.image = [transmitObjects scaleImage:[UIImage imageWithData:object.data] maxWidth:480 maxHeight:640];
	UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	self.navigationItem.leftBarButtonItem = btn;
	[btn release];
	
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

- (IBAction)saveImage:(id)sender{
	TransmitObject *object = [transmitObjects.objects objectAtIndex:0];
	writeToFileSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"transmitObjectImageViewcontroller_ACTIONSHEET_SAVING_FILE", "transmitObjectImageViewcontroller_ACTIONSHEET_SAVING_FILE"), object.title]
														 delegate:self 
												cancelButtonTitle:nil
										   destructiveButtonTitle:nil
												otherButtonTitles:nil];
	writeToFileSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	
	[writeToFileSheet showInView:[self.navigationController parentViewController].view];

	UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:object.data], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	[[self.navigationController topViewController] dismissModalViewControllerAnimated:YES];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
	[writeToFileSheet dismissWithClickedButtonIndex:1 animated:YES];
	[writeToFileSheet release];
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Done
- (void)done:(id)sender{
	if ([transmitObjects.objects count]){
		UIAlertView *confirmationView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"transmitObjectImageViewcontroller_UNSAVED_PHOTO_ALERT_TITLE", @"transmitObjectImageViewcontroller_UNSAVED_PHOTO_ALERT_TITLE")
																   message:NSLocalizedString(@"transmitObjectImageViewcontroller_UNSAVED_PHOTO_ALERT_MESSAGE", @"transmitObjectImageViewcontroller_UNSAVED_PHOTO_ALERT_MESSAGE")
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
