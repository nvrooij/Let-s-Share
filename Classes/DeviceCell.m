/*

 */

#import "DeviceCell.h"

@implementation DeviceCell

@synthesize device;

- (void)setDevice:(Device *)d {
	if(d){
		device = d;
		self.accessoryView = nil;
		self.textLabel.text = device.deviceName;
		self.textLabel.textColor = [UIColor blackColor];
		self.detailTextLabel.text = device.peerID;
		
	}else{
		UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[activity startAnimating];
		self.accessoryView = activity;
		[activity release];
		self.textLabel.textColor = [UIColor grayColor];
		self.textLabel.text = NSLocalizedString(@"DeviceCell_WAITING_FOR_DEVICES", @"DeviceCell_WAITING_FOR_DEVICES");		
	}
}

@end
