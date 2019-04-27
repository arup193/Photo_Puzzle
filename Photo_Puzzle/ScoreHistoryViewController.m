//
//  ScoreHistoryViewController.m
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 10/27/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "ScoreHistoryViewController.h"
#import "ScoreHistoryDB.h"
#import "ScoreCellTableViewCell.h"

NSMutableArray *scoreHistoryArray;

@interface ScoreHistoryViewController ()

@end

@implementation ScoreHistoryViewController

AVAudioPlayer *scorePlayer;
BOOL playScoreMusic;

@synthesize delegateScoreHistory = _delegate;

- (void)viewWillAppear:(BOOL)animated {
    playScoreMusic = [[NSUserDefaults standardUserDefaults] boolForKey:@"SoundEffects"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"mp3"];
    NSError *err;
    scorePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath:path] error:&err];
    if ( err ) {
        //error occurred.
    } else {
        scorePlayer.currentTime = 0;
        scorePlayer.volume = 0.85;
    }
    
    [self fetchScoreHistory];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [scoreHistoryArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScoreCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"scoreCell" forIndexPath:indexPath];
    
    // Configure the cell...
    int rowNum = (int)[indexPath row];
    if ( rowNum > 0 ) {
        ScoreHistoryDB *sch = [scoreHistoryArray objectAtIndex:[indexPath row] - 1];
        
        cell.rankL.text = [NSString stringWithFormat:@"%ld", [indexPath row]];
        cell.matLevelL.text = [NSString stringWithFormat:@"%@", sch.matlevel];
        cell.scoreL.text = [NSString stringWithFormat:@"%@", sch.score];
        /*int time = sch.timeinsec.intValue;
        int hour, min, sec;
        NSString *timeString = @"";
        if ( time >= 3600 ) {
            hour = time / 3600;
            time %= 3600;
            timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%d H:", hour]];
        }
        if ( time >= 60 ) {
            min = time / 60;
            time %= 60;
            timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%d M:", min]];
        }
        if ( time >= 0) {
            sec = time;
            timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%d S", sec]];
        }
        cell.timeL.text = timeString;*/
    } else {
        cell.rankL.text = @"RANK";
        cell.matLevelL.text = @"LEVEL";
        cell.scoreL.text = @"SCORE";
    }
    return cell;
}

- (BOOL) fetchScoreHistory
{
    BOOL retval = FALSE;
    
    //AppDelegate *appD = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *mds = [[[UIApplication sharedApplication] delegate] performSelector:@selector(managedObjectContext)];
    
    // Define our table/entity to use
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ScoreHistoryDB" inManagedObjectContext:mds];
    // Setup the fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    // Define how we will sort the records
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    // Fetch the records and handle an error
    NSError *error;
    scoreHistoryArray = [[mds executeFetchRequest:request error:&error] mutableCopy];
    if (!scoreHistoryArray)
    {
        //Error Handling
    }
    else
    {
        if([scoreHistoryArray count] > 0)
        {
            retval = TRUE;
        }
    }
    return retval;
}

- (IBAction)scoreHistoryToMenu:(id)sender {
    if ( playScoreMusic == TRUE  && scorePlayer.playing == NO ) {
        [scorePlayer play];
    }
    
    [self.delegateScoreHistory scoreHistoryViewControllerDidFinish:self];
}
@end
