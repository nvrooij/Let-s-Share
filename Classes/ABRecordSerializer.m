#import "ABRecordSerializer.h"

#define PHOTO_PROPERTY 99999

@implementation ABRecordSerializer

+ (NSData *)personToData:(ABRecordRef)person {
	NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithCapacity:5];
	
	// Copies each ABRecordRef property to a NSMutableDictionary
	[self copyProperty:kABPersonFirstNameProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonLastNameProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonMiddleNameProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonPrefixProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonSuffixProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonNicknameProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonFirstNamePhoneticProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonLastNamePhoneticProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonMiddleNamePhoneticProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonOrganizationProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonJobTitleProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonDepartmentProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonBirthdayProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonNoteProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonEmailProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonAddressProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonDateProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonKindProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonPhoneProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonInstantMessageProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonURLProperty ofPerson:person toDictionary:properties];
	[self copyProperty:kABPersonRelatedNamesProperty ofPerson:person toDictionary:properties];
	
	// Check if person has an image associated and add it to the dictionary with a pre-defined key
	if (ABPersonHasImageData(person)) {
		CFDataRef imgData = ABPersonCopyImageData(person);
		[properties setObject:(NSData*)imgData forKey:[NSNumber numberWithInt:PHOTO_PROPERTY]];
		CFRelease(imgData);
	}
	
	// Uses archiver to serialize the NSMutableDictionary in a binary format
	return [NSKeyedArchiver archivedDataWithRootObject:properties];
}

+ (ABRecordRef)newPersonFromData:(NSData *)data {
	ABRecordRef person = NULL;
	
	// Deserializes the data to a NSDictionary
	NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	if (dictionary) {
		// Creates a new ABRecordRef to be populated
		person = ABPersonCreate();
		CFErrorRef error = NULL;
		
		// Iterates over the dictionary keys and add them with the corresponding value to the new person (ABRecordRef)
		NSArray *keys = [dictionary allKeys];
		for (NSUInteger i = 0; i < [keys count]; i++) {
			NSNumber *key = [keys objectAtIndex:i];
			id value = [dictionary objectForKey:key];
			ABPropertyID prop = [key intValue];
			
			if (prop == PHOTO_PROPERTY) {
				ABPersonSetImageData(person, (CFDataRef)value, &error);
			} else {
				ABPropertyType type = ABPersonGetTypeOfProperty(prop);
				if (type == kABStringPropertyType) {
					ABRecordSetValue(person, prop, value, &error);
				} else if (type == kABIntegerPropertyType) {
					ABRecordSetValue(person, prop, value, &error);
				} else if (type == kABDateTimePropertyType) {
					ABRecordSetValue(person, prop, value, &error);
				} else if (type == kABMultiStringPropertyType 
						   || type == kABMultiDictionaryPropertyType
						   || type == kABMultiDateTimePropertyType) {
					ABMutableMultiValueRef multiValueProp = [self newMultiValuePropertyFromDictionary:(NSDictionary*)value];
					if (multiValueProp != NULL) {
						ABRecordSetValue(person, prop, multiValueProp, &error);
						CFRelease(multiValueProp);
					}
				}
			}
			
			if (error != NULL) {
				CFStringRef errorDescription = CFErrorCopyDescription(error);
				CFRelease(errorDescription);
				CFRelease(error);
				CFRelease(person);
				return NULL;
			}
		}
	} 
	
	return person;
}

+ (ABMutableMultiValueRef)newMultiValuePropertyFromDictionary:(NSDictionary*)dictionary {
	ABMutableMultiValueRef multiValueProp = NULL;
	CFTypeID type = CFGetTypeID([[dictionary allValues] objectAtIndex:0]);
	
	// Transforms a NSDictionary to a ABMutableMultiValueRef
	if (type == CFStringGetTypeID()) {
		multiValueProp = ABMultiValueCreateMutable(kABStringPropertyType);
	} else if (type == CFDateGetTypeID()) {
		multiValueProp = ABMultiValueCreateMutable(kABDateTimePropertyType);
	} else if (type == CFDictionaryGetTypeID()) {
		multiValueProp = ABMultiValueCreateMutable(kABDictionaryPropertyType);
	}
	
	NSArray *keys = [[dictionary allKeys] sortedArrayUsingSelector:@selector(localizedCompare:)];
	for (CFIndex i = 0; i < [keys count]; i++) {
		NSString *key = [keys objectAtIndex:i];
		ABMultiValueAddValueAndLabel(multiValueProp, [dictionary objectForKey:key], (CFStringRef)[key substringFromIndex:3], NULL);
	}
	
	return multiValueProp;
}

+ (NSDictionary*)dictionaryFromMultiValueProperty:(ABMutableMultiValueRef)prop {
	NSMutableDictionary *dictionary = nil;
	CFTypeRef label, value;
	NSString *orderedLabel;
	CFTypeID type;
	
	// Transforms multivalue properties in a NSMutableDictionary to be serialized
	if (ABMultiValueGetCount(prop) > 0) {
		dictionary = [NSMutableDictionary dictionaryWithCapacity:5];
		for (CFIndex i = 0; i < ABMultiValueGetCount(prop); i++) {
			label = ABMultiValueCopyLabelAtIndex(prop, i);
			if (label == NULL)
				label = @"";
			
			orderedLabel = [NSString stringWithFormat:@"%.3d%@", i, label];
			value = ABMultiValueCopyValueAtIndex(prop, i);
			
			if (value != NULL) {
				type = CFGetTypeID(value);
				if (type == CFStringGetTypeID()) {
					[dictionary setObject:(NSString*)value forKey:orderedLabel];
				} else if (type == CFDateGetTypeID()) {
					[dictionary setObject:(NSDate*)value forKey:orderedLabel];
				} else if (type == CFDictionaryGetTypeID()) {
					[dictionary setObject:(NSDictionary*)value forKey:orderedLabel];
				}
				
				CFRelease(value);
			}
			
			CFRelease(label);
		}
	}
	
	return dictionary;
}

+ (void)copyProperty:(ABPropertyID)prop ofPerson:(ABRecordRef)person toDictionary:(NSMutableDictionary*)dict {
	CFTypeRef value = ABRecordCopyValue(person, prop);
	ABPropertyID type;
	
	// Copies the specified property to the NSMutableDictionary considering it's specific type
	if (value != NULL) {
		type = ABPersonGetTypeOfProperty(prop);
		if (type == kABStringPropertyType) {
			[dict setObject:(NSString*)value forKey:[NSNumber numberWithInt:prop]];
		} else if (type == kABIntegerPropertyType) {
			[dict setObject:(NSNumber*)value forKey:[NSNumber numberWithInt:prop]];
		} else if (type == kABDateTimePropertyType) {
			[dict setObject:(NSDate*)value forKey:[NSNumber numberWithInt:prop]];
		} else if (type == kABMultiStringPropertyType 
				   || type == kABMultiDictionaryPropertyType 
				   || type == kABMultiDateTimePropertyType) {
			NSDictionary *propDictionary = [self dictionaryFromMultiValueProperty:value];
			if (propDictionary)
				[dict setObject:propDictionary forKey:[NSNumber numberWithInt:prop]];
		}
		
		CFRelease(value);
	}
}

@end
