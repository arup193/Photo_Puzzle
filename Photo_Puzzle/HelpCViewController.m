//
//  HelpCViewController.m
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 12/4/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import "HelpCViewController.h"
#import "Tile.h"

@interface HelpCViewController ()

@end

NSTimer *cHTimer1, *cHtimer2;
int cHtimer1Count, cHtimer2Count;
Tile *cLTile, *cBTile, *cMainTile;
CGFloat tileHeightC = 120.0f, tileWidthC = 120.0f, centerSpaceXC, centerSpaceYC;
UIImageView *undoUIImgV;

@implementation HelpCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resetHelpC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)StartHandsForC {
    cHtimer1Count++;
    if ( cHtimer1Count == 2 ) {
        UIImageView *hand = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"finger.png"]];
        hand.frame = CGRectMake(tileWidthC * 2.0, tileHeightC * 3.0, 128, 196);
        hand.tag = 5015;
        [self.view addSubview:hand];
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationDuration:1.0];
        hand.frame = CGRectMake(tileWidthC + centerSpaceXC + 30, tileHeightC + centerSpaceYC + 40, 128, 196);
        [UIView commitAnimations];
    }
    if ( cHtimer1Count == 3 ) {
        cHtimer2Count = 0;
        cHtimer2 = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(StartMoveForC) userInfo:nil repeats:YES];
    }
}

- (void)StartMoveForC {
    cHtimer2Count++;
    if ( cHtimer2Count == 1 ) {
        UIView *cir = [[UIView alloc] initWithFrame:CGRectMake(40, 40, 30, 30)];
        cir.alpha = 0.5;
        cir.layer.cornerRadius = 15;
        float r = ((float)((0x4981CE & 0xFF0000) >> 16))/255.0;
        float g = ((float)((0x4981CE & 0x00FF00) >> 8))/255.0;
        float b = ((float)((0x4981CE & 0x0000FF) >> 0))/255.0;
        cir.backgroundColor = [UIColor colorWithRed:r green:g  blue:b alpha:1.0];
        [cBTile addSubview:cir];
    }
    if ( cHtimer2Count == 2 ) {
        [[[cBTile subviews] objectAtIndex:0] removeFromSuperview];
        CGRect bFrame = cBTile.frame;
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationDuration:1.5];
        cBTile.frame = cMainTile.frame;
        cMainTile.frame = bFrame;
        [UIView commitAnimations];
    }
    if ( cHtimer2Count == 7 ) {
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationDuration:1.5];
        [self.view viewWithTag:5015].frame = CGRectMake(315, 470, 128, 196);
        [UIView commitAnimations];
    }
    if ( cHtimer2Count == 11 ) {
        UIView *cir = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
        cir.alpha = 0.5;
        cir.layer.cornerRadius = 15;
        float r = ((float)((0x4981CE & 0xFF0000) >> 16))/255.0;
        float g = ((float)((0x4981CE & 0x00FF00) >> 8))/255.0;
        float b = ((float)((0x4981CE & 0x0000FF) >> 0))/255.0;
        cir.backgroundColor = [UIColor colorWithRed:r green:g  blue:b alpha:1.0];
        [undoUIImgV addSubview:cir];
    }
    if ( cHtimer2Count == 12 ) {
        [[[undoUIImgV subviews] objectAtIndex:0] removeFromSuperview];
        CGRect bFrame = cBTile.frame;
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationDuration:1.5];
        cBTile.frame = cMainTile.frame;
        cMainTile.frame = bFrame;
        [UIView commitAnimations];
    }
    if ( cHtimer2Count == 17 ) {
        [self resetHelpC];
    }
}

- (void)resetHelpC {
    [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    if ( cHTimer1 != nil ) {
        [cHTimer1 invalidate];
        cHTimer1 = nil;
        cHtimer1Count = 0;
    }
    if ( cHtimer2 != nil ) {
        [cHtimer2 invalidate];
        cHtimer2 = nil;
        cHtimer2Count = 0;
    }
    
    [self setTilesForHelpC];
    UILabel *infoHelpCLabel = [[UILabel alloc] init];
    infoHelpCLabel.frame = CGRectMake(62, 525, 250, 30);
    infoHelpCLabel.font = [UIFont fontWithName:@"GoodDog" size:35];
    infoHelpCLabel.textAlignment = NSTextAlignmentCenter;
    infoHelpCLabel.text = @"Undo Move";
    [self.view addSubview:infoHelpCLabel];
    if ( cHTimer1 == nil ) {
        cHTimer1 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(StartHandsForC) userInfo:nil repeats:YES];
    }
}

- (void) setTilesForHelpC {
    UIImage *orgImage = [UIImage imageNamed:@"picture1.png"];
    
    if ( orgImage.size.width > 360.0f ) {
        tileHeightC = tileWidthC = 360.0f / 3;
    }
    else {
        tileHeightC = tileWidthC = orgImage.size.width/3;
    }
    
    cMainTile = [[Tile alloc] init];
    cMainTile.originalPosition = CGPointMake(2.0, 1.0);
    cLTile = [[Tile alloc] init];
    cLTile.originalPosition = CGPointMake(1.0, 1.0);
    cBTile = [[Tile alloc] init];
    cBTile.originalPosition = CGPointMake(1.0, 2.0);
    
    CGFloat imageDim = orgImage.size.width / 3;
    centerSpaceXC = (375.0f - (tileWidthC * 3)) / 2.0f;
    centerSpaceYC = 67.0f;
    
    UIView *bv = (UIView *)[self.view viewWithTag:1300];
    
    if ( bv != nil ) {
        [bv removeFromSuperview];
    }
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(centerSpaceXC - 5.0, centerSpaceYC - 5.0, (3 * tileWidthC) + 10.0, (3 * tileHeightC) + 10.0)];
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
        
        CGRect tileFrame =  CGRectMake((tileWidthC * curPosition.x) + centerSpaceXC, (tileHeightC * curPosition.y) + centerSpaceYC, tileWidthC, tileHeightC );
        
        Tile *tile = [[Tile alloc] initWithImage:tileImage];
        tile.frame = tileFrame;
        tile.layer.borderWidth = 0.5;
        tile.tag = 5001 + i;
        tile.originalPosition = orgPosition;
        tile.currentPosition = curPosition;
        
        CGImageRelease( tileImageRef );
        
        if( cMainTile.originalPosition.x == orgPosition.x && cMainTile.originalPosition.y == orgPosition.y ) {
            cMainTile = tile;
            curPosition = CGPointMake(1.0, 2.0);
            cMainTile.currentPosition = curPosition;
            cMainTile.frame = CGRectMake((tileWidthC * curPosition.x) + centerSpaceXC, (tileHeightC * curPosition.y) + centerSpaceYC, tileWidthC, tileHeightC );
        }
        else if( cLTile.originalPosition.x == orgPosition.x && cLTile.originalPosition.y == orgPosition.y ) {
            cLTile = tile;
            curPosition = CGPointMake(2.0, 1.0);
            cLTile.currentPosition = curPosition;
            cLTile.frame = CGRectMake((tileWidthC * curPosition.x) + centerSpaceXC, (tileHeightC * curPosition.y) + centerSpaceYC, tileWidthC, tileHeightC );
        }
        else if( cBTile.originalPosition.x == orgPosition.x && cBTile.originalPosition.y == orgPosition.y ) {
            cBTile = tile;
            curPosition = CGPointMake(1.0, 1.0);
            cBTile.currentPosition = curPosition;
            cBTile.frame = CGRectMake((tileWidthC * curPosition.x) + centerSpaceXC, (tileHeightC * curPosition.y) + centerSpaceYC, tileWidthC, tileHeightC );
        }
        
        [self.view addSubview:tile];
    }
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cMainTile.frame.size.width, cMainTile.frame.size.height)];
    [overlay setBackgroundColor:[UIColor colorWithRed:0.7 green:0.3 blue:0.4 alpha:0.6]];
    [cMainTile addSubview:overlay];
    
    undoUIImgV = [[UIImageView alloc] initWithFrame:CGRectMake(323, 470, 50, 50)];
    [undoUIImgV setImage:[UIImage imageNamed:@"undo.png"]];
    [self.view addSubview:undoUIImgV];
}

- (Tile *)getTileFromHelpCAtPoint: (CGPoint)point {
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
    if ( cHTimer1 != nil ) {
        [cHTimer1 invalidate];
        cHTimer1 = nil;
        cHtimer1Count = 0;
    }
    if ( cHtimer2 != nil ) {
        [cHtimer2 invalidate];
        cHtimer2 = nil;
        cHtimer2Count = 0;
    }
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
