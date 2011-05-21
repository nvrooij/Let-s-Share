//
//  AboutScreen.m
//  LetsShare
//
//  Created by Niels van Rooij on 05-09-09.
//

#import "AboutScreenViewController.h"
#import "DefaultsController.h"

@implementation AboutScreenViewController
@synthesize version;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	version.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"settingsTableViewController_SETTING_4_TITLE",@"settingsTableViewController Setting 4 Title"),[[DefaultsController sharedDefaultsController] getAppVersion]];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	self.view.alpha = 1.0;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:1];
	[UIView setAnimationDidStopSelector:@selector(doneAnimation:)];
	self.view.alpha = 0.0;
	[UIView commitAnimations];	
}

- (void)doneAnimation:(id)sender{
	[self.view removeFromSuperview];	
}

- (void)dealloc {
    [super dealloc];
}


@end
