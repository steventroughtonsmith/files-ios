//
//  FBColumnViewController.h
//  Files
//
//  Created by Steven Troughton-Smith on 11/06/2016.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBColumnViewController;

@protocol FBColumnViewControllerChild <NSObject>

@property (nonatomic, weak) FBColumnViewController *columnViewController;

@end

@interface FBColumnViewController : UIViewController
{
	BOOL _isDetailViewController;
}

@property (nonatomic, retain) UINavigationController *rootNavigationController;
@property NSArray <UIViewController *>*viewControllers;
@property CGFloat columnWidth;
@property (nonatomic) UIScrollView *view;

-(instancetype)initWithRootViewController:(UIViewController *)vc;
-(void)pushViewController:(UIViewController *)vc;
-(void)pushDetailViewController:(UIViewController *)vc;
-(void)popViewController;
-(void)popToViewController:(UIViewController *)vc;
-(void)popToRootViewController;
@end
