//
//  FBQLPreviewController.h
//  Files
//
//  Created by Steven Troughton-Smith on 12/06/2016.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import <QuickLook/QuickLook.h>

@class FBColumnViewController;

@interface FBQLPreviewController : QLPreviewController
@property (strong) FBColumnViewController *columnViewController;

@end
