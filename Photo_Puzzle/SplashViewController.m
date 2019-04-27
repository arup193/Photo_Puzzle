//
//  SplashViewController.m
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 12/4/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import "SplashViewController.h"
#import "MenuViewController.h"

@interface SplashViewController ()

@end

NSTimer *splashTimer;

@implementation SplashViewController

@synthesize wiz, nin;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSMutableArray *wizImages = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 45; i++) {
        [wizImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"wizard%d.gif", i]]];
    }
    wiz.animationImages = wizImages;
    wiz.animationRepeatCount = 1;
    wiz.animationDuration = 6.0;
    
    NSMutableArray *ninImages = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 45; i++) {
        [ninImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"ninja%d.gif", i]]];
    }
    nin.animationImages = ninImages;
    nin.animationRepeatCount = 1;
    nin.animationDuration = 6.0;
    
    [wiz startAnimating];
    [nin startAnimating];
    
    splashTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(onSplashStart) userInfo:nil repeats:YES];
}

- (void)onSplashStart {
    if ( [wiz isAnimating] == false && [nin isAnimating] == false ) {
        [splashTimer invalidate];
        splashTimer = nil;
        MenuViewController *menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
        [self presentViewController:menuViewController animated:NO completion:nil];
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

@end
