//
//  FBCustomPreviewController.m
//  FileBrowser
//
//  Created by Steven Troughton-Smith on 29/09/2014.
//  Copyright (c) 2014 High Caffeine Content. All rights reserved.
//

#import "FBCustomPreviewController.h"

@implementation FBCustomPreviewController

- (instancetype)initWithFile:(NSString *)file
{
	self = [super init];
	if (self) {
		
		textView = [[UITextView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		textView.editable = NO;
		textView.backgroundColor = [UIColor whiteColor];
		
		imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		
		imageView.backgroundColor = [UIColor whiteColor];

		[self loadFile:file];

	}
	return self;
}

+(BOOL)canHandleExtension:(NSString *)fileExt
{
	if ((int)UI_USER_INTERFACE_IDIOM() != 4) // Don't use QuickLook for images on watchOS
		return ([fileExt isEqualToString:@"txt"] || [fileExt isEqualToString:@"plist"] || [fileExt isEqualToString:@"strings"] || [fileExt isEqualToString:@"xcconfig"] );

	return ([fileExt isEqualToString:@"txt"] || [fileExt isEqualToString:@"plist"] || [fileExt isEqualToString:@"strings"] || [fileExt isEqualToString:@"png"] || [fileExt isEqualToString:@"xcconfig"] );
}

-(void)loadFile:(NSString *)file
{
	if ([file.pathExtension isEqualToString:@"plist"] || [file.pathExtension isEqualToString:@"strings"])
	{
		NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:file];
		[textView setText:[d description]];
		self.view = textView;
	}
	else if ([file.pathExtension isEqualToString:@"xcconfig"])
	{
		NSString *d = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
		[textView setText:d];
		self.view = textView;
	}
	else
	{
		imageView.image = [UIImage imageWithContentsOfFile:file];
		self.view = imageView;
	}
	
	self.title = file.lastPathComponent;
}

@end
