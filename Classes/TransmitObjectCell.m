//
//  TransmitObjectCell.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 15-08-09.
//

#import "TransmitObjectCell.h"


@implementation TransmitObjectCell
@synthesize object;

- (void)setObject:(TransmitObject *)o {
	object = o;
	self.textLabel.text = object.title;
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
