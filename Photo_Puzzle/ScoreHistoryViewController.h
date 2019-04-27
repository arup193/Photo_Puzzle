//
//  ScoreHistoryViewController.h
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 10/27/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScoreHistoryViewController;

@protocol ScoreHistoryViewControllerDelegate
- (void)scoreHistoryViewControllerDidFinish:(ScoreHistoryViewController *)controller;
@end

@interface ScoreHistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (assign, nonatomic) IBOutlet id <ScoreHistoryViewControllerDelegate> delegateScoreHistory;
- (IBAction)scoreHistoryToMenu:(id)sender;
@end
