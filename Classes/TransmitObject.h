//
//  TransmitObject.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 14-08-09.
//

#import <Foundation/Foundation.h>

typedef enum  {
	TMOTContact = 0,
	TMOTImage = 1
} TransmitObjectType;

@interface TransmitObjects : NSObject <NSCoding> {
	NSMutableArray *objects;
	UIViewController *_mainViewController;
}
@property (getter=getTitle,readonly) NSString *title;
@property (nonatomic, retain) NSMutableArray *objects;
- (BOOL)addContact:(NSString *)recordID;
- (BOOL)addImage:(UIImage *)image;
- (UIImage *)scaleImage:(UIImage *) image maxWidth:(float) maxWidth maxHeight:(float) maxHeight;
@end

@interface TransmitObject : NSObject <NSCoding>{
	NSString *_title;
	TransmitObjectType _type;
	NSData *_data;
}

@property (getter=getTitle,readonly) NSString *title;
@property (getter=getType,readonly) TransmitObjectType type;
@property (getter=getData,readonly) NSData *data;

- (id)initWithTitle:(NSString *)title ofType:(TransmitObjectType)type withData:(NSData *)data;

@end
