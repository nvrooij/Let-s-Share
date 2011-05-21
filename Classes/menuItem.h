//
//  menuItem.h
//  ShareWithFriends
//
//  Created by Niels van Rooij on 04-08-09.
//

#import <Foundation/Foundation.h>


@interface menuItem : NSObject {
	NSString *title;
	UIImage *icon;	
	NSString *subtitle;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, retain) NSString *subtitle;

+ (menuItem *)newItemWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict; 
@end
