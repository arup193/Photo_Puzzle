//
//  RootHelpViewController.m
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 12/4/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "RootHelpViewController.h"

@interface RootHelpViewController ()

@end

@implementation RootHelpViewController

AVAudioPlayer *helpPlayer;
BOOL playHelpMusic;

@synthesize PageViewController;
@synthesize helpDelegate;

- (void)viewWillAppear:(BOOL)animated {
    playHelpMusic = [[NSUserDefaults standardUserDefaults] boolForKey:@"SoundEffects"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    PageViewController.dataSource = self;
    
    NSMutableArray *vcs = [[NSMutableArray alloc] init];
    [vcs addObject:[self viewControllerForIndex:1]];
    
    [PageViewController setViewControllers:vcs direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    PageViewController.view.frame = CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 22);
    [self addChildViewController:PageViewController];
    [self.view addSubview:PageViewController.view];
    [PageViewController didMoveToParentViewController:self];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"mp3"];
    NSError *err;
    helpPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath:path] error:&err];
    if ( err ) {
        //error occurred.
    } else {
        helpPlayer.currentTime = 0;
        helpPlayer.volume = 0.85;
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

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    int index = (int)viewController.view.tag - 4000;
    return [self viewControllerForIndex:(index-1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    int index = (int)viewController.view.tag - 4000;
    return [self viewControllerForIndex:(index+1)];
}

- (IBAction)goBackFromHelpToMenu:(id)sender {
    if ( playHelpMusic == TRUE  && helpPlayer.playing == NO ) {
        [helpPlayer play];
    }
    
    [helpDelegate helpViewControllerDidFinish:self];
}

- (UIViewController *)viewControllerForIndex: (int)index {
    if ( index == 1 ) {
        HelpAViewController *ha = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpAViewController"];
        return ha;
    }
    else if ( index == 2 ) {
        HelpBViewController *hb = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpBViewController"];
        return hb;
    }
    else if ( index == 3 ) {
        HelpCViewController *hc = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpCViewController"];
        return hc;
    }
    
    return nil;
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 3;
}
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
