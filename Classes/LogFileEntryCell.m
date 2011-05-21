//
//  LogFileEntryCell.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 12-08-09.
//

#import "LogFileEntryCell.h"

@interface LogFileEntryCell()
-(UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;
@end


@implementation LogFileEntryCell
@synthesize logFileEntry;
@synthesize lblTitle, lblDescription, lblDate, lblTime;

#pragma mark -
#pragma mark Initialization
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		
		//Title
		self.lblTitle = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor blackColor] fontSize:[UIFont systemFontSize] bold:YES];
		self.lblTitle.textAlignment = UITextAlignmentLeft;
		[self addSubview:self.lblTitle];
		[self.lblTitle release];
		
		//Description
		self.lblDescription = [self newLabelWithPrimaryColor:[UIColor grayColor] selectedColor:[UIColor grayColor] fontSize:[UIFont systemFontSize]-2 bold:NO];
		self.lblDescription.textAlignment = UITextAlignmentLeft;
		[self addSubview:self.lblDescription];
		[self.lblDescription release];		

		//Date
		self.lblDate = [self newLabelWithPrimaryColor:[UIColor blueColor] selectedColor:[UIColor blueColor] fontSize:[UIFont systemFontSize]-2 bold:NO];
		self.lblDate.textAlignment = UITextAlignmentRight;
		[self addSubview:self.lblDate];
		[self.lblDate release];		

		//Time
		self.lblTime = [self newLabelWithPrimaryColor:[UIColor blueColor] selectedColor:[UIColor blueColor] fontSize:[UIFont systemFontSize]-2 bold:NO];
		self.lblTime.textAlignment = UITextAlignmentRight;
		[self addSubview:self.lblTime];
		[self.lblTime release];		
	}
    return self;
}

#pragma mark -
#pragma mark LayoutSuperviews
- (void)layoutSubviews {
	
    [super layoutSubviews];
	
	// getting the cell size
    CGRect contentRect = self.contentView.bounds;
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
    if (!self.editing) {
		
		// get the X pixel spot
        CGFloat boundsX = contentRect.origin.x;
		CGRect frame;
		
        /*
		 Place the title label.
		 place the label whatever the current X is plus 10 pixels from the left
		 place the label 4 pixels from the top
		 make the label 200 pixels wide
		 make the label 20 pixels high
		 */
		frame = CGRectMake(boundsX + 235, 4, 70, 14);
		self.lblDate.frame = frame;

		frame = CGRectMake(boundsX + 10, 4, 200, 20);
		self.lblTitle.frame = frame;

		frame = CGRectMake(boundsX + 235, 24, 70, 14);
		self.lblTime.frame = frame;

		frame = CGRectMake(boundsX + 10, 24, 200, 14);
		self.lblDescription.frame = frame;
	
	}
}
#pragma mark -
#pragma mark Helpers
-(UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold
{
	/*
	 Create and configure a label.
	 */
	
    UIFont *font;
    if (bold) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    } else {
        font = [UIFont systemFontOfSize:fontSize];
    }
	
    /*
	 Views are drawn most efficiently when they are opaque and do not have a clear background, so set these defaults.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  This is handled in setSelected:animated:.
	 */
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	newLabel.backgroundColor = [UIColor whiteColor];
	newLabel.opaque = YES;
	newLabel.textColor = primaryColor;
	newLabel.highlightedTextColor = selectedColor;
	newLabel.font = font;
	
	return newLabel;
}
#pragma mark -
#pragma mark SetLogEntry

- (void)setLogFileEntry:(LogFileEntry *)e {
	logFileEntry = e;	
	self.lblTitle.text = logFileEntry.title;
	if (e.type == SRLSend)
		self.lblDescription.text  = [NSString stringWithFormat:NSLocalizedString(@"LogFileEntryCell_TO_LBL",@"To: "),logFileEntry.deviceName];
	else
		self.lblDescription.text  = [NSString stringWithFormat:NSLocalizedString(@"LogFileEntryCell_FROM_LBL",@"From: "),logFileEntry.deviceName];
	
	// Date and Time
	self.lblDate.text = e.date;	
	self.lblTime.text = e.time;
	
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:NO animated:NO];

    // Configure the view for the selected state
}


- (void)dealloc {
	[lblTime release];
	[lblDate release];
	[lblTitle release];
	[lblDescription release];
    [super dealloc];
}


@end
