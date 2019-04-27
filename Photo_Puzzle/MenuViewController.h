//
//  MenuViewController.h
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 10/26/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameViewController.h"
#import "ScoreHistoryViewController.h"
#import "RootHelpViewController.h"

@interface MenuViewController : UIViewController <GameViewControllerDelegate, ScoreHistoryViewControllerDelegate, RootHelpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *resumeButton;

- (IBAction)newGame:(id)sender;
- (IBAction)scoreHistory:(id)sender;
- (IBAction)resumeGame:(id)sender;
- (IBAction)showHelp:(id)sender;
@end
