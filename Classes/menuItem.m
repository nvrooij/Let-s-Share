//
//  menuItem.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 04-08-09.
//

#import "menuItem.h"


@implementation menuItem

@synthesize title, icon, subtitle;

+ (menuItem *)newItemWithDictionary:(NSDictionary *)dict{
	menuItem *newMenuItem = [[menuItem alloc] init];
	newMenuItem.title = [[dict objectForKey:@"Title"] copy];
	newMenuItem.icon = [UIImage imageNamed:[dict objectForKey:@"Icon"]];
	newMenuItem.subtitle = [[dict objectForKey:@"Subtitle"] copy];
	return newMenuItem;
}

- (id)initWithDictionary:(NSDictionary *)dict{
	if (self = [super init]){
		title = [[dict objectForKey:@"Title"] copy];
		icon = [UIImage imageNamed:[dict objectForKey:@"Icon"]];		
		subtitle = [[dict objectForKey:@"Subtitle"] copy];
	}
	return self;
}

- (void)dealloc{
	[title release];
	[icon release];
	[subtitle release];
	[super dealloc];
}


@end
