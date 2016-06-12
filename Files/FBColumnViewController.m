//
//  FBColumnViewController.m
//  Files
//
//  Created by Steven Troughton-Smith on 11/06/2016.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import "FBColumnViewController.h"
#import "FBFilesTableViewController.h"
#import "FBColumnNavigationController.h"

@implementation FBColumnViewController
@dynamic view;

- (instancetype)initWithRootViewController:(UIViewController <FBColumnViewControllerChild>*)vc
{
	self = [super init];
	if (self) {
		self.viewControllers = @[vc];
		self.columnWidth = 320.;
		
		vc.columnViewController = self;
		UIScrollView *sv = [[UIScrollView alloc] initWithFrame:self.view.frame];
		sv.autoresizingMask = self.view.autoresizingMask;
		sv.backgroundColor = [UIColor groupTableViewBackgroundColor];
		
		self.view = sv;
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
		{
			self.columnWidth = [UIScreen mainScreen].bounds.size.width;
			
			self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:vc.childViewControllers.firstObject];
#ifdef APP_EXTENSION
			self.rootNavigationController.view.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-64);
#else
			self.rootNavigationController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44-_FBStatusBarDelta());
#endif
			self.rootNavigationController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

			[self.rootNavigationController setToolbarHidden:NO];

			[self.view addSubview:self.rootNavigationController.view];
		}
		else
		{
			[self layout];
		}
		
	}
	return self;
}

-(void)pushDetailViewController:(UIViewController <FBColumnViewControllerChild>*)vc
{
	_isDetailViewController = YES;
	[self pushViewController:vc];
	_isDetailViewController = NO;
}

-(void)pushViewController:(UIViewController <FBColumnViewControllerChild>*)vc
{
	self.viewControllers = [self.viewControllers arrayByAddingObject:vc];
	vc.columnViewController = self;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		[self.rootNavigationController pushViewController:vc.childViewControllers.firstObject animated:YES];
		[self.rootNavigationController setToolbarHidden:NO];
	}
	else
	{
		[self layout];
		
		self.view.contentSize = CGSizeMake(self.viewControllers.lastObject.view.frame.origin.x+self.viewControllers.lastObject.view.frame.size.width, self.view.frame.size.height-44-_FBStatusBarDelta());
		[self.view scrollRectToVisible:vc.view.frame animated:YES];
	}
}

-(void)popViewController
{
	if (self.viewControllers.count > 1)
	{
		self.viewControllers = [self.viewControllers subarrayWithRange:NSMakeRange(0, self.viewControllers.count-2)];
	}
	else
	{
		self.viewControllers = @[];
	}
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		[self.rootNavigationController popViewControllerAnimated:YES];
	}
	else
	{
		[self layout];
		
		self.view.contentSize = CGSizeMake(self.viewControllers.lastObject.view.frame.origin.x+self.viewControllers.lastObject.view.frame.size.width, self.view.frame.size.height-44-_FBStatusBarDelta());
		[self.view scrollRectToVisible:self.viewControllers.lastObject.view.frame animated:YES];
	}
}

-(void)popToRootViewController
{
	self.viewControllers = @[[self.viewControllers firstObject]];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		[self.rootNavigationController popToRootViewControllerAnimated:YES];
	}
	else
	{
		[self layout];
		
		self.view.contentSize = CGSizeMake(self.viewControllers.lastObject.view.frame.origin.x+self.viewControllers.lastObject.view.frame.size.width, self.view.frame.size.height-44-_FBStatusBarDelta());
		[self.view scrollRectToVisible:self.viewControllers.lastObject.view.frame animated:YES];
	}
}

-(void)popToViewController:(UIViewController *)vc
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
	}
	else
	{
		NSUInteger idx = [self.viewControllers indexOfObject:vc];
		
		if (idx < self.viewControllers.count)
		{
			self.viewControllers = [self.viewControllers subarrayWithRange:NSMakeRange(0, idx+1)];
			
			[self layout];
		}
		
		[self.view scrollRectToVisible:vc.view.frame animated:YES];
	}
}

-(void)layout
{
	if (self.view.subviews.count && self.view.subviews.count > self.viewControllers.count)
	{
		[[self.view.subviews subarrayWithRange:NSMakeRange(self.viewControllers.count, self.view.subviews.count-self.viewControllers.count)] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	}
	
	NSUInteger idx = 0;
	for (UIViewController *vc in self.viewControllers)
	{
		
		CGFloat desiredWidth = self.columnWidth;
		
		if (_isDetailViewController && idx == self.viewControllers.count-1)
		{
			desiredWidth = 512;
		}
		
		vc.view.frame = CGRectMake(idx*self.columnWidth+idx, 0, desiredWidth, self.view.frame.size.height-44-_FBStatusBarDelta());
		
		vc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		[self.view addSubview:vc.view];
		
		idx++;
	}
}

CGFloat _FBStatusBarDelta()
{
	CGFloat statusBarDelta = 20;
	
#ifdef APP_EXTENSION
	statusBarDelta = 0;
#endif
	
	return statusBarDelta;
}

@end
