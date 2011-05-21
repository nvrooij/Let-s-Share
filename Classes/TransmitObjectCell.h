//
//  TransmitObjectCell.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 15-08-09.
//

#import <UIKit/UIKit.h>
#import "TransmitObject.h"


@interface TransmitObjectCell : UITableViewCell {
	TransmitObject *object;
}
@property (nonatomic, retain) TransmitObject *object;

@end
