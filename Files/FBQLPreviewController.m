//
//  FBQLPreviewController.m
//  Files
//
//  Created by Steven Troughton-Smith on 12/06/2016.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import "FBQLPreviewController.h"

@implementation FBQLPreviewController

-(BOOL)canBecomeFirstResponder
{
	return NO; // Don't let QLPreviewController interfere with keyboard shortcuts
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:NO];
}
@end
