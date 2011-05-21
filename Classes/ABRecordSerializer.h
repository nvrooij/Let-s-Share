#import <AddressBookUI/AddressBookUI.h>

@interface ABRecordSerializer : NSObject {

}

+ (NSData *)personToData:(ABRecordRef)person;
+ (ABRecordRef)newPersonFromData:(NSData *)data;
+ (ABMutableMultiValueRef)newMultiValuePropertyFromDictionary:(NSDictionary*)dictionary;
+ (NSDictionary*)dictionaryFromMultiValueProperty:(ABMutableMultiValueRef)prop;
+ (void)copyProperty:(ABPropertyID)prop ofPerson:(ABRecordRef)person toDictionary:(NSMutableDictionary*)dict;

@end
