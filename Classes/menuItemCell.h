//
//  menuItemCell.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 18-08-09.
//

#import <UIKit/UIKit.h>
#import "menuItem.h"


@interface menuItemCell : UITableViewCell {
	menuItem *item;
	UIImageView *imgView;
	UILabel *lblTitle;
	UILabel *lblDescription;
}
@property (nonatomic, retain) menuItem *item;
@property (nonatomic, retain) UILabel *lblTitle;
@property (nonatomic, retain) UILabel *lblDescription;
@property (nonatomic, retain) UIImageView *imgView;

@end
