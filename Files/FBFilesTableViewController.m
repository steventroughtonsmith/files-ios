//
//  FBFilesTableViewController.m
//  FileBrowser
//
//  Created by Steven Troughton-Smith on 18/06/2013.
//  Copyright (c) 2013 High Caffeine Content. All rights reserved.
//

#import "FBFilesTableViewController.h"
#import "FBCustomPreviewController.h"
#import "FBColumnViewController.h"
#import "FBColumnNavigationController.h"
#import "FBQLPreviewController.h"

@implementation FBFilesTableViewController



- (id)initWithPath:(NSString *)path
{
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		
		self.path = path;
		
		self.title = [path lastPathComponent];
		
		NSError *error = nil;
		NSArray *tempFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
		
		if (error)
		{
			NSLog(@"ERROR: %@", error);
			
			if ([path isEqualToString:@"/System"])
				tempFiles = @[@"Library"];
			
			if ([path isEqualToString:@"/Library"])
				tempFiles = @[@"Preferences"];
			
			if ([path isEqualToString:@"/var"])
				tempFiles = @[@"mobile"];
			
			if ([path isEqualToString:@"/usr"])
				tempFiles = @[@"lib", @"libexec", @"bin"];
		}
		
		self.files = [tempFiles sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(NSString* file1, NSString* file2) {
			NSString *newPath1 = [self.path stringByAppendingPathComponent:file1];
			NSString *newPath2 = [self.path stringByAppendingPathComponent:file2];
			
			BOOL isDirectory1, isDirectory2;
			[[NSFileManager defaultManager ] fileExistsAtPath:newPath1 isDirectory:&isDirectory1];
			[[NSFileManager defaultManager ] fileExistsAtPath:newPath2 isDirectory:&isDirectory2];
			
			if (isDirectory1 && !isDirectory2)
				return NSOrderedDescending;
			
			return  NSOrderedAscending;
		}];
		
		
		
		[[NSNotificationCenter defaultCenter]  addObserverForName:@"FBFileTableViewControllerNavigateUp" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
			[self navigateUp:self];
		}];
		
		
		[[NSNotificationCenter defaultCenter]  addObserverForName:@"FBFileTableViewControllerNavigateDown" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
			[self navigateDown:self];
		}];
		
		
		UIBarButtonItem *itemCountBarItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%lu item%@", (unsigned long)self.files.count, ((self.files.count == 0) || (self.files.count > 1)) ? @"s" : @""] style:UIBarButtonItemStylePlain target:nil action:nil];
		UIBarButtonItem *flexibleSpace =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		
		itemCountBarItem.tintColor = [UIColor blackColor];
		[itemCountBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} forState:UIControlStateNormal];
		
		[self setToolbarItems:@[flexibleSpace,itemCountBarItem,flexibleSpace]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(defaultsChanged:)
													 name:NSUserDefaultsDidChangeNotification
												   object:nil];
		
		[self sortFiles];
	}
	return self;
}

- (void)defaultsChanged:(NSNotification *)notification {
	[self sortFiles];
}

-(void)sortFiles
{
	NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.highcaffeinecontent.Files"];
	NSInteger sortingFilter = [defaults integerForKey:@"FBSortingFilter"];
	
	self.files = [self.files sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(NSString* file1, NSString* file2) {
		NSString *newPath1 = [self.path stringByAppendingPathComponent:file1];
		NSString *newPath2 = [self.path stringByAppendingPathComponent:file2];
		
		BOOL isDirectory1, isDirectory2;
		[[NSFileManager defaultManager] fileExistsAtPath:newPath1 isDirectory:&isDirectory1];
		[[NSFileManager defaultManager] fileExistsAtPath:newPath2 isDirectory:&isDirectory2];
		
		if (sortingFilter == 0)
		{
			if (isDirectory1 && !isDirectory2)
				return NSOrderedDescending;
			
			return  NSOrderedAscending;
		}
		else
		{
			if ([[file1 pathExtension] isEqualToString:[file2 pathExtension]])
				return [file1 localizedCaseInsensitiveCompare:file2];

			return [[file1 pathExtension] localizedCaseInsensitiveCompare:[file2 pathExtension]];
		}
	}];
	
	[self.tableView reloadData];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.navigationController setToolbarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard Shortcuts


-(BOOL)canBecomeFirstResponder
{
	return YES;
}

-(NSArray <UIKeyCommand *>*)keyCommands
{
	return @[
			 [UIKeyCommand keyCommandWithInput:UIKeyInputUpArrow modifierFlags:0 action:@selector(navigateUp:)],
			 [UIKeyCommand keyCommandWithInput:UIKeyInputDownArrow modifierFlags:0 action:@selector(navigateDown:)],
			 [UIKeyCommand keyCommandWithInput:@"\r" modifierFlags:0 action:@selector(navigateInto:)],
			 [UIKeyCommand keyCommandWithInput:UIKeyInputEscape modifierFlags:0 action:@selector(navigateBack:)]
			 
			 ];
}



-(BOOL)isDirectoryAtIndexPath:(NSIndexPath *)path
{
	NSString *filePath = [self.path stringByAppendingPathComponent:self.files[path.row]];
	
	BOOL isDirectory;
	[[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
	
	return isDirectory;
}

-(void)navigateBack:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)navigateInto:(id)sender
{
	if (self.files.count == 0)
		return;
	
	NSIndexPath *newPath = [self.tableView indexPathForSelectedRow];
	if ([self isDirectoryAtIndexPath:newPath])
		[self tableView:self.tableView didSelectRowAtIndexPath:newPath];
	
}

-(void)navigateUp:(id)sender
{
	if (self.files.count == 0)
		return;
	
	NSIndexPath *oldPath = [self.tableView indexPathForSelectedRow];
	
	if (oldPath.row > 0)
	{
		NSIndexPath *newPath = [NSIndexPath indexPathForRow:oldPath.row-1 inSection:0];
		[self.tableView selectRowAtIndexPath:newPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
		
		if (![self isDirectoryAtIndexPath:newPath])
			[self tableView:self.tableView didSelectRowAtIndexPath:newPath];
	}
}

-(void)navigateDown:(id)sender
{
	if (self.files.count == 0)
		return;
	
	NSIndexPath *oldPath = [self.tableView indexPathForSelectedRow];
	
	if (oldPath.row < self.files.count-1)
	{
		NSIndexPath *newPath = [NSIndexPath indexPathForRow:oldPath.row+1 inSection:0];
		[self.tableView selectRowAtIndexPath:newPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
		
		if (![self isDirectoryAtIndexPath:newPath])
			[self tableView:self.tableView didSelectRowAtIndexPath:newPath];
		
	}
}

#pragma mark -

-(void)highlightPathComponent:(NSString *)pathComponent
{
	NSUInteger idx = [self.files indexOfObject:pathComponent];
	
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 72.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"FileCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	
	
	NSString *newPath = [self.path stringByAppendingPathComponent:self.files[indexPath.row]];
	
	BOOL isDirectory;
	[[NSFileManager defaultManager ] fileExistsAtPath:newPath isDirectory:&isDirectory];
	
	
	
	
	cell.textLabel.text = self.files[indexPath.row];
	cell.textLabel.textAlignment = NSTextAlignmentLeft;
	if (isDirectory)
	{
		NSUInteger fileCount = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:newPath error:nil].count;
		
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu item%@", (unsigned long)fileCount, ((fileCount == 0) || (fileCount > 1)) ? @"s" : @""];
	}
	else
	{
		NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:newPath error:nil];
		
		cell.detailTextLabel.text = [NSByteCountFormatter stringFromByteCount:[attribs fileSize] countStyle:NSByteCountFormatterCountStyleFile];
	}
	
	cell.detailTextLabel.textColor = [UIColor lightGrayColor];
	
	cell.selectedBackgroundView = [UIView new];
	cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.882 green:0.961 blue:0.996 alpha:1.000];
	
	cell.imageView.tintColor = [UIColor colorWithRed:0.565 green:0.773 blue:0.878 alpha:1.000];
	
	if (isDirectory)
		cell.imageView.image = [UIImage imageNamed:@"Folder"];
	else if ([[newPath pathExtension] isEqualToString:@"png"])
		cell.imageView.image = [UIImage imageNamed:@"Picture"];
	else
		cell.imageView.image = [UIImage imageNamed:@"Document"];
	
#if 0
	if (fileExists && !isDirectory)
		cell.accessoryType = UITableViewCellAccessoryDetailButton;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
#endif
	
	return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	NSString *newPath = [self.path stringByAppendingPathComponent:self.files[indexPath.row]];
	
	NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:newPath.lastPathComponent];
	
	NSError *error = nil;
	
	[[NSFileManager defaultManager] copyItemAtPath:newPath toPath:tmpPath error:&error];
	
	if (error)
		NSLog(@"ERROR: %@", error);
	
	UIActivityViewController *shareActivity = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:tmpPath]] applicationActivities:nil];
	
	shareActivity.completionWithItemsHandler = ^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError)
	{
		[[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
	};
	
	
	UIViewController *vc = [[UIViewController alloc] init];
	UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
	nc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
	
	[self.navigationController presentViewController:nc animated:YES completion:^{
		
	}];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *newPath = [self.path stringByAppendingPathComponent:self.files[indexPath.row]];
	
	
	BOOL isDirectory;
	BOOL fileExists = [[NSFileManager defaultManager ] fileExistsAtPath:newPath isDirectory:&isDirectory];
	
	
	if (fileExists)
	{
		if (isDirectory)
		{
			[self.columnViewController popToViewController:self.parentViewController];
			
			FBFilesTableViewController *vc = [[FBFilesTableViewController alloc] initWithPath:newPath];
			
			FBColumnNavigationController *detailNavController = [[FBColumnNavigationController alloc] initWithRootViewController:vc];
			[self.columnViewController pushViewController:detailNavController];
			
		}
		else
		{
			if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.highcaffeinecontent.Files.FilesDocumentProvider"])
			{
				[[NSNotificationCenter defaultCenter] postNotificationName:@"FBPickedFileURL" object:[NSURL fileURLWithPath:newPath]];
			}
			else
			{
				if ([FBCustomPreviewController canHandleExtension:[newPath pathExtension]])
				{
					[self.columnViewController popToViewController:self.parentViewController];
					
					FBCustomPreviewController *preview = [[FBCustomPreviewController alloc] initWithFile:newPath];

					FBColumnNavigationController *detailNavController = [[FBColumnNavigationController alloc] initWithRootViewController:preview];
					
					[self.columnViewController pushDetailViewController:detailNavController];
				}
				else
				{
					[self.columnViewController popToViewController:self.parentViewController];
					
					FBQLPreviewController *preview = [[FBQLPreviewController alloc] init];
					preview.dataSource = self;

					FBColumnNavigationController *detailNavController = [[FBColumnNavigationController alloc] initWithRootViewController:preview];
					[self.columnViewController pushDetailViewController:detailNavController];
					
				}
			}
		}
		
	}
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
	{
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

#pragma mark - QuickLook

- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item {
	
	return YES;
}

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller {
	return 1;
}

- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index {
	
	NSString *newPath = [self.path stringByAppendingPathComponent:self.files[self.tableView.indexPathForSelectedRow.row]];
	
	return [NSURL fileURLWithPath:newPath];
}

@end
