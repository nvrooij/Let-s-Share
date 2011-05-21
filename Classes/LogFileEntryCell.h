//
//  LogFileEntryCell.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 12-08-09.
//

#import <UIKit/UIKit.h>
#import "LogFileEntry.h"

@interface LogFileEntryCell : UITableViewCell {
	LogFileEntry *logFileEntry;
	UILabel *lblTitle;
	UILabel *lblDescription;
	UILabel *lblDate;
	UILabel *lblTime;
}
@property (nonatomic, retain) LogFileEntry *logFileEntry;
@property (nonatomic, retain) UILabel *lblTitle;
@property (nonatomic, retain) UILabel *lblDescription;
@property (nonatomic, retain) UILabel *lblDate;
@property (nonatomic, retain) UILabel *lblTime;

@end
