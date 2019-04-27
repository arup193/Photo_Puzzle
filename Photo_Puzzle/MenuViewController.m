//
//  MenuViewController.m
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 10/26/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import "MenuViewController.h"
#import "OptionsViewController.h"
#import "BackGroundPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface MenuViewController ()

@end

@implementation MenuViewController

AVAudioPlayer *menuPlayer;
BOOL playMenuMusic;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"Refresh"] == TRUE || [[NSUserDefaults standardUserDefaults] objectForKey:@"TilePositions"] == nil ) {
        [self.resumeButton setHidden:YES];
    }
    else {
        [self.resumeButton setHidden:NO];
    }
    
    playMenuMusic = [[NSUserDefaults standardUserDefaults] boolForKey:@"SoundEffects"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"mp3"];
    NSError *err;
    menuPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath:path] error:&err];
    if ( err ) {
        //error occurred.
    } else {
        menuPlayer.currentTime = 0;
        menuPlayer.volume = 0.85;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*- (IBAction)showOptions:(id)sender {
    OptionsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"OptionsViewController"];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)optionsViewControllerDidFinish:(OptionsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}*/

- (void)gameViewControllerDidFinish:(OptionsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*- (void)scoresViewControllerDidFinish:(OptionsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}*/

- (void)scoreHistoryViewControllerDidFinish:(OptionsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)helpViewControllerDidFinish:(RootHelpViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)newGame:(id)sender {
    int rno = arc4random_uniform(4); //random() % 2;
    [[NSUserDefaults standardUserDefaults] setInteger:rno forKey:@"PuzzlePicture"];
    
    [UIImagePNGRepresentation([UIImage imageNamed:[NSString stringWithFormat:@"picture%d.png", rno]]) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage.png"] atomically:YES];
    
    if ( playMenuMusic == TRUE  && menuPlayer.playing == NO ) {
        [menuPlayer play];
    }
    
    GameViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"GameViewController"];
    controller.gameType = @"new";
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)scoreHistory:(id)sender {
    /*ScoresViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ScoresViewController"];
    controller.delegateScores = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];*/
    
    if ( playMenuMusic == TRUE  && menuPlayer.playing == NO ) {
        [menuPlayer play];
    }
    
    ScoreHistoryViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ScoreHistoryViewController"];
    controller.delegateScoreHistory = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)resumeGame:(id)sender {
    if ( playMenuMusic == TRUE  && menuPlayer.playing == NO ) {
        [menuPlayer play];
    }
    
    GameViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"GameViewController"];
    controller.gameType = @"resume";
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)showHelp:(id)sender {
    if ( playMenuMusic == TRUE  && menuPlayer.playing == NO ) {
        [menuPlayer play];
    }
    
    RootHelpViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"RootHelpViewController"];
    controller.helpDelegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}
@end
