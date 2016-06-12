//
//  FBFilesTableViewController.h
//  FileBrowser
//
//  Created by Steven Troughton-Smith on 18/06/2013.
//  Copyright (c) 2013 High Caffeine Content. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@class FBColumnViewController;

@interface FBFilesTableViewController : UITableViewController <QLPreviewControllerDataSource>

@property (strong) FBColumnViewController *columnViewController;

-(id)initWithPath:(NSString *)path;
-(void)highlightPathComponent:(NSString *)pathComponent;

@property (strong) NSString *path;
@property (strong) NSArray *files;
@end
