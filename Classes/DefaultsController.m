//
//  DefaultsController.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 18-08-09.
//

#import "DefaultsController.h"

#define MY_CONTACT_ID_PROP @"MY_CONTACT_ID"

#define EDIT_PHOTO_BEFORE_SENDING @"EDIT_PHOTO_BEFORE_SENDING"
#define AUTO_ROTATE_PHOTO_BEFORE_SENDING @"AUTO_ROTATE_PHOTO_BEFORE_SENDING"

#define MAX_LOG_FILE_ITEMS_PROP @"MAX_LOG_FILE_ITEMS"

#define MAX_LOG_FILE_ITEMS 10

static DefaultsController *gDefaultsController = nil;

@implementation DefaultsController

#pragma mark -
#pragma mark Initializer

- (id)init{
	if(self = [super init]){
		NSString *contactID = [[NSUserDefaults standardUserDefaults] objectForKey:MY_CONTACT_ID_PROP];
		if (contactID)
			myContactID = [contactID intValue];
		else
			myContactID = 0;

		editBeforeSendingPhoto = [[NSUserDefaults standardUserDefaults] boolForKey:EDIT_PHOTO_BEFORE_SENDING];
		
		MaxLogFileSize = [[NSUserDefaults standardUserDefaults] integerForKey:MAX_LOG_FILE_ITEMS_PROP];
		if (MaxLogFileSize == 0)
			MaxLogFileSize = MAX_LOG_FILE_ITEMS;
	}
	return self;
}

#pragma mark -
#pragma mark Public

- (ABRecordID)getMyContactID {
	return myContactID;
}
- (NSString *)getMyContactIDStr{
	return [NSString stringWithFormat:@"%d", myContactID];
}

- (void)saveMyContactID:(ABRecordID)recordID {
	myContactID = recordID;
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", recordID] forKey:MY_CONTACT_ID_PROP];
}

- (BOOL)contactIsSet{
	if (myContactID != 0)
		return YES;
	else
		return NO;
}

- (NSString *)getMyContactDisplayName {
	NSString *output;
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, myContactID);
	if (person != NULL) {
		output = (NSString *)ABRecordCopyValue(person, kABPersonCompositeNameFormatFirstNameFirst);
	} else {
		// My contact was removed, reset settings
		myContactID = 0;
		[self saveMyContactID:myContactID];
		output = [[NSString alloc] initWithString:@""];
	}
	CFRelease(addressBook);
	return [output autorelease];
}

- (void)configureMyContactAndReplyTo:(id)delegate selector:(SEL)contactConfigured errorSelector:(SEL)contactNotConfigured inMainWindow:(UIViewController *)viewController{	
	mainViewController = viewController;
	
	delegateToCallWhenContactIsConfigured = delegate;
	selectorToPerformWhenContactIsConfigured = contactConfigured;
	selectorToPerformWhenContactWasNotConfigured = contactNotConfigured;
	
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	picker.navigationBar.topItem.title = NSLocalizedString(@"DefaultsController_SELECT_MY_CONTACT_TITLE", @"Select my contact picker title.");
	[mainViewController presentModalViewController:picker animated:YES];
	[picker release];
}

- (NSString *)getAppVersion{
	CFBundleRef bundle = CFBundleGetMainBundle();
	CFStringRef versStr = (CFStringRef)CFBundleGetValueForInfoDictionaryKey(bundle,kCFBundleVersionKey);
	return [NSString stringWithFormat:@"%@",versStr];	
}

// Photo
- (BOOL)editBeforeSendingPhoto{
	return editBeforeSendingPhoto;
}

- (void)setEditBeforeSendingPhoto:(BOOL)value{
	[[NSUserDefaults standardUserDefaults] setBool:value forKey:EDIT_PHOTO_BEFORE_SENDING];
	editBeforeSendingPhoto = value;
}

// Log file

- (NSInteger)getMaxLogFileItems{
	return MaxLogFileSize;
}
- (void)setMaxLogFileItems:(NSInteger)newSize{
	MaxLogFileSize = newSize;
	[[NSUserDefaults standardUserDefaults] setInteger:newSize forKey:MAX_LOG_FILE_ITEMS_PROP];
}



#pragma mark -
#pragma mark peoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [mainViewController dismissModalViewControllerAnimated:YES];
	if (delegateToCallWhenContactIsConfigured && [delegateToCallWhenContactIsConfigured respondsToSelector:selectorToPerformWhenContactWasNotConfigured])
		[delegateToCallWhenContactIsConfigured performSelector:selectorToPerformWhenContactWasNotConfigured];
}
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	ABRecordID contactId = ABRecordGetRecordID(person);
	[self saveMyContactID:contactId];
	
	[mainViewController dismissModalViewControllerAnimated:YES];
	if (delegateToCallWhenContactIsConfigured && [delegateToCallWhenContactIsConfigured respondsToSelector:selectorToPerformWhenContactIsConfigured])
		[delegateToCallWhenContactIsConfigured performSelector:selectorToPerformWhenContactIsConfigured];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}


#pragma mark -
#pragma mark Singlton methods
+ (DefaultsController *)sharedDefaultsController{
    @synchronized(self) {
        if (gDefaultsController == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return gDefaultsController;
}
+ (id)allocWithZone:(NSZone *)zone{
    @synchronized(self) {
        if (gDefaultsController == nil) {
            gDefaultsController = [super allocWithZone:zone];
            return gDefaultsController;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}
- (id)copyWithZone:(NSZone *)zone{
    return self;
}
- (id)retain{
    return self;
}
- (unsigned)retainCount{
    return UINT_MAX;  //denotes an object that cannot be released
}
- (void)release{
    //do nothing
}
- (id)autorelease{
    return self;
}

@end
