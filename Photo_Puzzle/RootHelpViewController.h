//
//  RootHelpViewController.h
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 12/4/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpAViewController.h"
#import "HelpBViewController.h"
#import "HelpCViewController.h"

@class RootHelpViewController;

@protocol RootHelpViewControllerDelegate
- (void)helpViewControllerDidFinish:(RootHelpViewController *)controller;
@end

@interface RootHelpViewController : UIViewController <UIPageViewControllerDataSource>

@property (nonatomic,strong) UIPageViewController *PageViewController;
@property (assign, nonatomic) IBOutlet id <RootHelpViewControllerDelegate> helpDelegate;

- (IBAction)goBackFromHelpToMenu:(id)sender;

- (UIViewController *)viewControllerForIndex: (int)index;

@end
