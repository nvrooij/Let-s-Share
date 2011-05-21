//
//  DefaultsController.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 18-08-09.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface DefaultsController : NSObject <ABPeoplePickerNavigationControllerDelegate>{
	ABRecordID myContactID;
	NSInteger MaxLogFileSize;
	BOOL editBeforeSendingPhoto;
	
	// PeoplePickerHelperFunctions
	UIViewController *mainViewController;	
	id delegateToCallWhenContactIsConfigured;
	SEL selectorToPerformWhenContactIsConfigured;
	SEL selectorToPerformWhenContactWasNotConfigured;
}

+ (DefaultsController *)sharedDefaultsController;

// My Contact
- (ABRecordID)getMyContactID;
- (NSString *)getMyContactIDStr;
- (BOOL)contactIsSet;
- (NSString *)getMyContactDisplayName;
- (void)configureMyContactAndReplyTo:(id)delegate selector:(SEL)contactConfigured errorSelector:(SEL)contactNotConfigured inMainWindow:(UIViewController *)viewController;
- (NSString *)getAppVersion;

//Photo
- (BOOL)editBeforeSendingPhoto;
- (void)setEditBeforeSendingPhoto:(BOOL)value;

//Log file
- (NSInteger)getMaxLogFileItems;
@end
