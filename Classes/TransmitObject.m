//
//  TransmitObject.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 14-08-09.
//

#import "TransmitObject.h"
#import <AddressBook/AddressBook.h>
#import "ABRecordSerializer.h"
#import "transmitObjectsViewController.h"
#import "DefaultsController.h"

@interface TransmitObjects ()
- (NSString *)getTitle;
@end

@interface TransmitObject ()
- (NSString *)getTitle;
- (TransmitObjectType)getType;
- (NSData *)getData;
@end

@implementation TransmitObjects
@synthesize objects;

- (id)init{
	if (self = [super init]){		
		objects = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return self;
}

- (NSString *)getTitle{
	int countContacts = 0;
	int countImages = 0;
	NSMutableString *tmpStr = [[NSMutableString alloc] initWithCapacity:0];
	for (TransmitObject *tmpObj in objects){
		switch (tmpObj.type) {
			case TMOTContact:
				countContacts += 1;
				break;
			case TMOTImage:
				countImages += 1;
				break;
			default:
				break;
		}
	}
	if (countContacts>0){
		[tmpStr appendFormat:@"%i %@", countContacts, [NSString stringWithFormat:NSLocalizedString(@"TransmitObject_CONTACT_LBL",@"TransmitObject_CONTACT_LBL"), (countContacts>1)?NSLocalizedString(@"TransmitObject_CONTACT_LBL_MULTIPLIER",@"TransmitObject_CONTACT_LBL_MULTIPLIER"):@""]];	
	}else if (countImages>0){
		[tmpStr appendFormat:@"%i %@", countImages, [NSString stringWithFormat:NSLocalizedString(@"TransmitObject_IMAGE_LBL",@"TransmitObject_IMAGE_LBL"), (countImages>1)?NSLocalizedString(@"TransmitObject_IMAGE_LBL_MULTIPLIER",@"TransmitObject_IMAGE_LBL_MULTIPLIER"):@""]];
	}
	return [tmpStr autorelease];
}

- (BOOL)addContact:(NSString *)recordID{
	BOOL success = FALSE;
	if(recordID){
		ABAddressBookRef addressBook = ABAddressBookCreate();
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [recordID intValue]);
		if(person){
			NSString *recordCompositeName = (NSString*)ABRecordCopyCompositeName(person);
			
			// Create a new TransmitObject
			TransmitObject *newTransmitObject = [[TransmitObject alloc] initWithTitle:recordCompositeName ofType:TMOTContact withData:[ABRecordSerializer personToData:person]];
			if(newTransmitObject){
				[objects addObject:newTransmitObject];
				[newTransmitObject release];
				success = TRUE;
			}
			[recordCompositeName release];
		}
		CFRelease(addressBook);																
	}
	return success;
}

- (BOOL)addImage:(UIImage *)image{
	BOOL success = FALSE;	
	if(image){

		TransmitObject *newTransmitObject = [[TransmitObject alloc] initWithTitle:[NSString stringWithFormat:@"%i x %i", (int)image.size.width, (int)image.size.height] ofType:TMOTImage withData:UIImagePNGRepresentation(image)];
		if(newTransmitObject){
			[objects addObject:newTransmitObject];
			[newTransmitObject release];
			success = TRUE;
		}
	}
	return success;
}

#pragma mark -
#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)coder{
	objects = [[coder decodeObjectForKey:@"objects"] retain];
	return self;
}
- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:objects forKey:@"objects"];
}

- (void)dealloc{
	[objects release];
	[super dealloc];
}

#pragma mark -
#pragma mark Image Resizing
- (UIImage *)scaleImage:(UIImage *) image maxWidth:(float) maxWidth maxHeight:(float) maxHeight
{
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	if (width <= maxWidth && height <= maxHeight)
	{
		return image;
	}
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > maxWidth || height > maxHeight)
	{
		CGFloat ratio = width/height;
		if (ratio > 1)
		{
			bounds.size.width = maxWidth;
			bounds.size.height = bounds.size.width / ratio;
		}
		else
		{
			bounds.size.height = maxHeight;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextScaleCTM(context, scaleRatio, -scaleRatio);
	CGContextTranslateCTM(context, 0, -height);
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}
@end

@implementation TransmitObject

#pragma mark -
#pragma mark TransmitObject initializer
- (id)initWithTitle:(NSString *)title ofType:(TransmitObjectType)type withData:(NSData *)data{
	if (self = [super init]){
		_title = [title copy];
		_type = type;
		_data = [data copy];
	}
	return self;
}

#pragma mark -
#pragma mark Dealloc
- (void)dealloc{
	[_title release];
	[_data release];
	[super dealloc];
}

#pragma mark -
#pragma mark Hidden Category
- (NSString *)getTitle{
	return _title;
}
- (TransmitObjectType)getType{
	return _type;
}
- (NSData *)getData{
	return _data;
}

#pragma mark -
#pragma mark Description
- (NSString *)description{
	NSString *output;
	switch (_type) {
		case TMOTContact:
			output = [NSString stringWithFormat:NSLocalizedString(@"TransmitObject_DESCRIPTION_CONTACT",@"TransmitObject_DESCRIPTION_CONTACT"), _title];
			break;
		case TMOTImage:
			output = [NSString stringWithFormat:NSLocalizedString(@"TransmitObject_DESCRIPTION_PHOTO",@"TransmitObject_DESCRIPTION_PHOTO"), _title];
			break;
		default:
			output = [NSString string];
			break;
	}
	return output;
}

#pragma mark -
#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)coder{
	_title = [[coder decodeObjectForKey:@"title"] retain];
	_type = (TransmitObjectType)[coder decodeIntForKey:@"type"];
	_data = [[coder decodeObjectForKey:@"data"] retain];
	
	return self;
}
- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:_title forKey:@"title"];
	[coder encodeInt:(int)_type forKey:@"type"];
	[coder encodeObject:_data forKey:@"data"];
}

@end
