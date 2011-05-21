//
//  menuItemCell.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 18-08-09.
//

#import "menuItemCell.h"

@interface menuItemCell()
-(UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;
@end


@implementation menuItemCell
@synthesize lblTitle, lblDescription, imgView;
@synthesize item;

#pragma mark -
#pragma mark Initializer

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ((self = [super initWithStyle:style reuseIdentifier: reuseIdentifier])){
        // Initialization code
        
		//Title
		self.lblTitle = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:[UIFont labelFontSize] bold:YES];
		self.lblTitle.textAlignment = UITextAlignmentLeft;
		[self addSubview:self.lblTitle];
		[self.lblTitle release];
        
		//Description
		self.lblDescription = [self newLabelWithPrimaryColor:[UIColor grayColor] selectedColor:[UIColor whiteColor] fontSize:[UIFont systemFontSize]-2 bold:NO];
		self.lblDescription.textAlignment = UITextAlignmentLeft;
		self.lblDescription.numberOfLines = 2;
		[self addSubview:self.lblDescription];
		[self.lblDescription release];		
		
		self.imgView = [[UIImageView alloc] init];
		self.imgView.contentMode = UIViewContentModeCenter;
		[self addSubview:imgView];
		[self.imgView release];
    }
    return self;
}

#pragma mark -
#pragma mark Layout
- (void)layoutSubviews {
	
    [super layoutSubviews];
	
	// getting the cell size
    CGRect contentRect = self.contentView.bounds;
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
    if (!self.editing) {
		
		// get the X pixel spot
        CGFloat boundsX = contentRect.origin.x;
		CGRect frame;
		
		frame = CGRectMake(boundsX + 10, 15, 50, 50);
		self.imgView.frame = frame;
		
		frame = CGRectMake(boundsX + 75, 6, 200, 30);
		self.lblTitle.frame = frame;
		
		frame = CGRectMake(boundsX + 75, 34, 200, 40);
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


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
#pragma mark Setters
- (void)setItem:(menuItem *)i {
	self.lblTitle.text = NSLocalizedString([i title], [i title]);
	self.lblDescription.text = NSLocalizedString([i subtitle], [item subtitle]);
	self.imgView.image = i.icon;
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

}

- (void)dealloc {
	[imgView release];
	[lblTitle release];
	[lblDescription release];
    [super dealloc];
}


@end
