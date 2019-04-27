//
//  HelpAViewController.m
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 12/4/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import "HelpAViewController.h"
#import "Tile.h"

@interface HelpAViewController ()

@end

NSTimer *aHTimer1, *aHtimer2;
int aHtimer1Count, aHtimer2Count;
Tile *aLTile, *aBTile, *aMainTile;
CGFloat tileHeightA = 120.0f, tileWidthA = 120.0f, centerSpaceXA, centerSpaceYA;

@implementation HelpAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resetHelpA];
}

- (void)StartHands {
    aHtimer1Count++;
    if ( aHtimer1Count == 2 ) {
        UIImageView *tick1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick.png"]];
        UIImageView *tick2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick.png"]];
        UIImageView *tick3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick.png"]];
        tick1.frame = tick2.frame = tick3.frame = CGRectMake(tileWidthA - 30, 0, 30, 30);
        CGPoint tcur = aMainTile.currentPosition;
        [[self getTileFromHelpAAtPoint:CGPointMake((tcur.x - 1.0) * tileWidthA + centerSpaceXA, (tcur.y) * tileHeightA + centerSpaceYA)] addSubview:tick1];
        [[self getTileFromHelpAAtPoint:CGPointMake((tcur.x + 1.0) * tileWidthA + centerSpaceXA, (tcur.y) * tileHeightA + centerSpaceYA)] addSubview:tick2];
        [[self getTileFromHelpAAtPoint:CGPointMake((tcur.x) * tileWidthA + centerSpaceXA, (tcur.y - 1.0) * tileHeightA + centerSpaceYA)] addSubview:tick3];
    }
    if ( aHtimer1Count == 3 ) {
        UIImageView *hand = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"finger.png"]];
        hand.frame = CGRectMake(tileWidthA * 2.0, tileHeightA * 3.0, 128, 196);
        [self.view addSubview:hand];
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationDuration:1.0];
        hand.frame = CGRectMake(tileWidthA + centerSpaceXA + 30, tileHeightA + centerSpaceYA + 40, 128, 196);
        [UIView commitAnimations];
        
        aHtimer2Count = 0;
        aHtimer2 = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(StartMove) userInfo:nil repeats:YES];
    }
}

- (void)StartMove {
    aHtimer2Count++;
    if ( aHtimer2Count == 2 ) {
        Tile *t = [self getTileFromHelpAAtPoint:CGPointMake(tileWidthA + centerSpaceXA, tileHeightA + centerSpaceYA)];
        UIView *cir = [[UIView alloc] initWithFrame:CGRectMake(40, 40, 30, 30)];
        cir.alpha = 0.5;
        cir.layer.cornerRadius = 15;
        float r = ((float)((0x4981CE & 0xFF0000) >> 16))/255.0;
        float g = ((float)((0x4981CE & 0x00FF00) >> 8))/255.0;
        float b = ((float)((0x4981CE & 0x0000FF) >> 0))/255.0;
        cir.backgroundColor = [UIColor colorWithRed:r green:g  blue:b alpha:1.0];
        [t addSubview:cir];
    }
    if ( aHtimer2Count == 3 ) {
        Tile *t = [self getTileFromHelpAAtPoint:CGPointMake(tileWidthA + centerSpaceXA, tileHeightA + centerSpaceYA)];
        [[[t subviews] objectAtIndex:1] removeFromSuperview];
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationDuration:1.5];
        t.frame = aMainTile.frame;
        aMainTile.frame = CGRectMake(tileWidthA + centerSpaceXA, tileHeightA + centerSpaceYA, tileWidthA, tileHeightA);
        [UIView commitAnimations];
    }
    if ( aHtimer2Count == 8 ) {
        [self resetHelpA];
    }
}

- (void)resetHelpA {
    [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    if ( aHTimer1 != nil ) {
        [aHTimer1 invalidate];
        aHTimer1 = nil;
        aHtimer1Count = 0;
    }
    if ( aHtimer2 != nil ) {
        [aHtimer2 invalidate];
        aHtimer2 = nil;
        aHtimer2Count = 0;
    }
    
    [self setTilesForHelpA];
    UILabel *infoHelpALabel = [[UILabel alloc] init];
    infoHelpALabel.frame = CGRectMake(62, 525, 250, 30);
    infoHelpALabel.font = [UIFont fontWithName:@"GoodDog" size:35];
    infoHelpALabel.textAlignment = NSTextAlignmentCenter;
    infoHelpALabel.text = @"Valid Move";
    [self.view addSubview:infoHelpALabel];
    if ( aHTimer1 == nil ) {
        aHTimer1 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(StartHands) userInfo:nil repeats:YES];
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

- (void) setTilesForHelpA {
    UIImage *orgImage = [UIImage imageNamed:@"picture1.png"];
    
    if ( orgImage.size.width > 360.0f ) {
        tileHeightA = tileWidthA = 360.0f / 3;
    }
    else {
        tileHeightA = tileWidthA = orgImage.size.width/3;
    }
    
    aMainTile = [[Tile alloc] init];
    aMainTile.originalPosition = CGPointMake(2.0, 1.0);
    aLTile = [[Tile alloc] init];
    aLTile.originalPosition = CGPointMake(1.0, 1.0);
    aBTile = [[Tile alloc] init];
    aBTile.originalPosition = CGPointMake(1.0, 2.0);
    
    CGFloat imageDim = orgImage.size.width / 3;
    centerSpaceXA = (375.0f - (tileWidthA * 3)) / 2.0f;
    centerSpaceYA = 67.0f;
    
    UIView *bv = (UIView *)[self.view viewWithTag:1300];
    
    if ( bv != nil ) {
        [bv removeFromSuperview];
    }
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(centerSpaceXA - 5.0, centerSpaceYA - 5.0, (3 * tileWidthA) + 10.0, (3 * tileHeightA) + 10.0)];
    borderView.layer.borderColor = [[UIColor colorWithRed:182.0/255.0
                                                    green:155.0/255.0
                                                     blue:76.0/255.0
                                                    alpha:1.0] CGColor];
    borderView.layer.borderWidth = 5.0f;
    borderView.tag = 1300;
    [self.view addSubview:borderView];
    
    for (int i = 0; i < 9; i++) {
        int x = i % 3;
        int y = i / 3;
        
        CGPoint orgPosition, curPosition;
        orgPosition = CGPointMake(x,y);
        curPosition = orgPosition;
        
        CGRect imageFrame = CGRectMake(imageDim*x, imageDim*y, imageDim, imageDim);
        CGImageRef tileImageRef = CGImageCreateWithImageInRect(orgImage.CGImage, imageFrame);
        UIImage *tileImage = [UIImage imageWithCGImage:tileImageRef];
        
        CGRect tileFrame =  CGRectMake((tileWidthA * curPosition.x) + centerSpaceXA, (tileHeightA * curPosition.y) + centerSpaceYA, tileWidthA, tileHeightA );
        
        Tile *tile = [[Tile alloc] initWithImage:tileImage];
        tile.frame = tileFrame;
        tile.layer.borderWidth = 0.5;
        tile.tag = 5001 + i;
        tile.originalPosition = orgPosition;
        tile.currentPosition = curPosition;
        
        CGImageRelease( tileImageRef );
        
        if( aMainTile.originalPosition.x == orgPosition.x && aMainTile.originalPosition.y == orgPosition.y ) {
            aMainTile = tile;
            curPosition = CGPointMake(1.0, 2.0);
            aMainTile.currentPosition = curPosition;
            aMainTile.frame = CGRectMake((tileWidthA * curPosition.x) + centerSpaceXA, (tileHeightA * curPosition.y) + centerSpaceYA, tileWidthA, tileHeightA );
        }
        else if( aLTile.originalPosition.x == orgPosition.x && aLTile.originalPosition.y == orgPosition.y ) {
            aLTile = tile;
            curPosition = CGPointMake(2.0, 1.0);
            aLTile.currentPosition = curPosition;
            aLTile.frame = CGRectMake((tileWidthA * curPosition.x) + centerSpaceXA, (tileHeightA * curPosition.y) + centerSpaceYA, tileWidthA, tileHeightA );
        }
        else if( aBTile.originalPosition.x == orgPosition.x && aBTile.originalPosition.y == orgPosition.y ) {
            aBTile = tile;
            curPosition = CGPointMake(1.0, 1.0);
            aBTile.currentPosition = curPosition;
            aBTile.frame = CGRectMake((tileWidthA * curPosition.x) + centerSpaceXA, (tileHeightA * curPosition.y) + centerSpaceYA, tileWidthA, tileHeightA );
        }
        
        [self.view addSubview:tile];
    }
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, aMainTile.frame.size.width, aMainTile.frame.size.height)];
    [overlay setBackgroundColor:[UIColor colorWithRed:0.7 green:0.3 blue:0.4 alpha:0.6]];
    [aMainTile addSubview:overlay];
}

- (Tile *)getTileFromHelpAAtPoint: (CGPoint)point {
    CGRect touchRect = CGRectMake(point.x + 2.0, point.y + 2.0, 3.0, 3.0);
    
    for (int i = 0; i < 9; i++) {
        Tile *t = (Tile *)[self.view viewWithTag:(5001 + i)];
        if( CGRectIntersectsRect(t.frame, touchRect) ){
            return t;
        }
    }
    return nil;
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    if ( aHTimer1 != nil ) {
        [aHTimer1 invalidate];
        aHTimer1 = nil;
        aHtimer1Count = 0;
    }
    if ( aHtimer2 != nil ) {
        [aHtimer2 invalidate];
        aHtimer2 = nil;
        aHtimer2Count = 0;
    }
}

@end
