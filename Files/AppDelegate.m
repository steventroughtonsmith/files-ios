//
//  AppDelegate.m
//  Files
//
//  Created by Steven Troughton-Smith on 11/06/2016.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import "AppDelegate.h"
#import "FBColumnViewController.h"
#import "FBFilesTableViewController.h"
#import "FBColumnNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.highcaffeinecontent.Files"];	
	NSInteger sortingFilter = [defaults integerForKey:@"FBSortingFilter"];
	
	self.window = [[UIWindow alloc] init];
	
	FBFilesTableViewController *tc = [[FBFilesTableViewController alloc] initWithPath:@"/"];
	
	FBColumnNavigationController *cnc = [[FBColumnNavigationController alloc] initWithRootViewController:tc];
	
	FBColumnViewController *columnViewController = [[FBColumnViewController alloc] initWithRootViewController:cnc];
	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:columnViewController];
	
	UISegmentedControl *filterSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Name", @"Kind"]];
	filterSegmentedControl.apportionsSegmentWidthsByContent = NO;
	filterSegmentedControl.frame = CGRectMake(0, 0, 240, 32);
	filterSegmentedControl.selectedSegmentIndex = sortingFilter;
	columnViewController.navigationItem.titleView = filterSegmentedControl;
	
	[filterSegmentedControl addTarget:self action:@selector(filterChanged:) forControlEvents:UIControlEventValueChanged];
	
	columnViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(goToFolder:)];
	
	[self.window makeKeyAndVisible];
	
	self.window.rootViewController = nc;
	self.columnViewController = columnViewController;
	
	[self becomeFirstResponder];
	
	return YES;
}

-(void)filterChanged:(UISegmentedControl *)sender
{
	NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.highcaffeinecontent.Files"];
	
	[defaults setInteger:sender.selectedSegmentIndex forKey:@"FBSortingFilter"];
}

-(void)navigateToPath:(NSString *)path
{
	[self.columnViewController popToRootViewController];
	
	__block NSString *composedPath = @"/";
	
	NSArray *components = [path pathComponents];
	
	[components enumerateObjectsUsingBlock:^(NSString * _Nonnull component, NSUInteger idx, BOOL * _Nonnull stop) {
		if (idx == 0)
			return;
		
		NSString *highlightedComponent = (idx < components.count-1) ? components[idx+1] : nil;
		
		composedPath = [composedPath stringByAppendingPathComponent:component];
		
		FBFilesTableViewController *vc = [[FBFilesTableViewController alloc] initWithPath:composedPath];
		
		FBColumnNavigationController *detailNavController = [[FBColumnNavigationController alloc] initWithRootViewController:vc];
		[self.columnViewController pushViewController:detailNavController];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[vc highlightPathComponent:highlightedComponent];
		});
	}];
	
}

#pragma mark - Key Commands

-(NSArray <UIKeyCommand *>*)keyCommands
{
	return @[
			 [UIKeyCommand keyCommandWithInput:@"g" modifierFlags:UIKeyModifierShift|UIKeyModifierCommand action:@selector(goToFolder:) discoverabilityTitle:NSLocalizedString(@"Go to Folder…", nil)]
			 ];
}

#pragma mark -

-(void)goToFolder:(id)sender
{
	
	UIAlertController * alert = [UIAlertController
								 alertControllerWithTitle:NSLocalizedString(@"Go to the folder…", nil)
								 message:nil
								 preferredStyle:UIAlertControllerStyleAlert];
	
	[alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
	}];
	
	UIAlertAction* goAction = [UIAlertAction
						 actionWithTitle:NSLocalizedString(@"Go", nil)
						 style:UIAlertActionStyleDefault
						 handler:^(UIAlertAction * action)
						 {
							 NSString *path = alert.textFields.firstObject.text;
							 
							 if (path.length > 0)
							 {
								 [self navigateToPath:path];
							 }
							 
							 [alert dismissViewControllerAnimated:YES completion:nil];
							 
						 }];
	UIAlertAction* cancelAction = [UIAlertAction
							 actionWithTitle:NSLocalizedString(@"Cancel", nil)
							 style:UIAlertActionStyleCancel
							 handler:^(UIAlertAction * action)
							 {
								 [alert dismissViewControllerAnimated:YES completion:nil];
							 }];
	
	[alert addAction:cancelAction];
	[alert addAction:goAction];

	[self.columnViewController presentViewController:alert animated:YES completion:nil];
}

@end
