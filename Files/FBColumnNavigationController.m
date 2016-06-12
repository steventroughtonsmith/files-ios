//
//  FBColumnNavigationController.m
//  Files
//
//  Created by Steven Troughton-Smith on 11/06/2016.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import "FBColumnNavigationController.h"
#import "FBColumnViewController.h"


@implementation FBColumnNavigationController

- (instancetype)initWithRootViewController:(UIViewController <FBColumnViewControllerChild>*)rootViewController
{
	self = [super initWithRootViewController:rootViewController];
	if (self) {
		self.navigationBar.barTintColor = [UIColor whiteColor];
		self.navigationBar.opaque = YES;
		self.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:18]};
		
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_performPop:)];
		
		[self.navigationBar addGestureRecognizer:tap];
		
		[self setToolbarHidden:NO];
	}
	return self;
}

-(void)setColumnViewController:(FBColumnViewController *)columnViewController
{
	for (UIViewController <FBColumnViewControllerChild>*vc in self.viewControllers)
	{
		if ([vc respondsToSelector:@selector(setColumnViewController:)])
			vc.columnViewController = columnViewController;
	}
	_columnViewController = columnViewController;
}

-(void)_performPop:(id)sender
{
	[self.columnViewController popToViewController:self];
}


@end
