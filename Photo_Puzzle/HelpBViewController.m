//
//  HelpBViewController.m
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 12/4/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import "HelpBViewController.h"
#import "Tile.h"

@interface HelpBViewController ()

@end

NSTimer *bHTimer1;
int bHtimer1Count;
Tile *bLTile, *bBTile, *bMainTile;
CGFloat tileHeightB = 120.0f, tileWidthB = 120.0f, centerSpaceXB, centerSpaceYB;
UIImageView *remindUIImgV;
NSMutableArray *bhArr;

@implementation HelpBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self resetHelpB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)StartHandsForB {
    bHtimer1Count++;
    if ( bHtimer1Count == 2 ) {
        UIImageView *hand = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"finger.png"]];
        hand.frame = CGRectMake(tileWidthB * 2.0, tileHeightB * 3.0, 128, 196);
        [self.view addSubview:hand];
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationDuration:1.0];
        hand.frame = CGRectMake(0, 470, 128, 196);
        [UIView commitAnimations];
    }
    if ( bHtimer1Count == 3 ) {
        UIView *cir = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
        cir.alpha = 0.5;
        cir.layer.cornerRadius = 15;
        float r = ((float)((0x4981CE & 0xFF0000) >> 16))/255.0;
        float g = ((float)((0x4981CE & 0x00FF00) >> 8))/255.0;
        float b = ((float)((0x4981CE & 0x0000FF) >> 0))/255.0;
        cir.backgroundColor = [UIColor colorWithRed:r green:g  blue:b alpha:1.0];
        [remindUIImgV addSubview:cir];
        
        bhArr = [[NSMutableArray alloc] init];
        for (int i = 5001; i < 5010; i++) {
            Tile *t = (Tile *)[self.view viewWithTag:i];
            [bhArr addObject:t];
            [t removeFromSuperview];
        }
        UIImageView *orgImV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture2.png"]];
        orgImV.frame = CGRectMake(centerSpaceXB, centerSpaceYB, 3 * tileWidthB, 3 * tileHeightB);
        orgImV.tag = 5011;
        [self.view addSubview:orgImV];
    }
    
    if ( bHtimer1Count == 5 ) {
        [[[remindUIImgV subviews] objectAtIndex:0] removeFromSuperview];
        [[self.view viewWithTag:5011] removeFromSuperview];
        for (Tile *t in bhArr) {
            [self.view addSubview:t];
        }
    }
    
    if ( bHtimer1Count == 6 ) {
        [self resetHelpB];
    }
}

- (void)resetHelpB {
    [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    if ( bHTimer1 != nil ) {
        [bHTimer1 invalidate];
        bHTimer1 = nil;
        bHtimer1Count = 0;
    }
    
    [self setTilesForHelpB];
    UILabel *infoHelpBLabel = [[UILabel alloc] init];
    infoHelpBLabel.frame = CGRectMake(62, 525, 250, 30);
    infoHelpBLabel.font = [UIFont fontWithName:@"GoodDog" size:35];
    infoHelpBLabel.textAlignment = NSTextAlignmentCenter;
    infoHelpBLabel.text = @"Remind Picture";
    [self.view addSubview:infoHelpBLabel];
    if ( bHTimer1 == nil ) {
        bHTimer1 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(StartHandsForB) userInfo:nil repeats:YES];
    }
}

- (void) setTilesForHelpB {
    UIImage *orgImage = [UIImage imageNamed:@"picture2.png"];
    
    if ( orgImage.size.width > 360.0f ) {
        tileHeightB = tileWidthB = 360.0f / 3;
    }
    else {
        tileHeightB = tileWidthB = orgImage.size.width/3;
    }
    
    bMainTile = [[Tile alloc] init];
    bMainTile.originalPosition = CGPointMake(2.0, 1.0);
    bLTile = [[Tile alloc] init];
    bLTile.originalPosition = CGPointMake(1.0, 1.0);
    bBTile = [[Tile alloc] init];
    bBTile.originalPosition = CGPointMake(1.0, 2.0);
    
    CGFloat imageDim = orgImage.size.width / 3;
    centerSpaceXB = (375.0f - (tileWidthB * 3)) / 2.0f;
    centerSpaceYB = 67.0f;
    
    UIView *bv = (UIView *)[self.view viewWithTag:1300];
    
    if ( bv != nil ) {
        [bv removeFromSuperview];
    }
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(centerSpaceXB - 5.0, centerSpaceYB - 5.0, (3 * tileWidthB) + 10.0, (3 * tileHeightB) + 10.0)];
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
        
        CGRect tileFrame =  CGRectMake((tileWidthB * curPosition.x) + centerSpaceXB, (tileHeightB * curPosition.y) + centerSpaceYB, tileWidthB, tileHeightB );
        
        Tile *tile = [[Tile alloc] initWithImage:tileImage];
        tile.frame = tileFrame;
        tile.layer.borderWidth = 0.5;
        tile.tag = 5001 + i;
        tile.originalPosition = orgPosition;
        tile.currentPosition = curPosition;
        
        CGImageRelease( tileImageRef );
        
        if( bMainTile.originalPosition.x == orgPosition.x && bMainTile.originalPosition.y == orgPosition.y ) {
            bMainTile = tile;
            curPosition = CGPointMake(1.0, 2.0);
            bMainTile.currentPosition = curPosition;
            bMainTile.frame = CGRectMake((tileWidthB * curPosition.x) + centerSpaceXB, (tileHeightB * curPosition.y) + centerSpaceYB, tileWidthB, tileHeightB );
        }
        else if( bLTile.originalPosition.x == orgPosition.x && bLTile.originalPosition.y == orgPosition.y ) {
            bLTile = tile;
            curPosition = CGPointMake(2.0, 1.0);
            bLTile.currentPosition = curPosition;
            bLTile.frame = CGRectMake((tileWidthB * curPosition.x) + centerSpaceXB, (tileHeightB * curPosition.y) + centerSpaceYB, tileWidthB, tileHeightB );
        }
        else if( bBTile.originalPosition.x == orgPosition.x && bBTile.originalPosition.y == orgPosition.y ) {
            bBTile = tile;
            curPosition = CGPointMake(1.0, 1.0);
            bBTile.currentPosition = curPosition;
            bBTile.frame = CGRectMake((tileWidthB * curPosition.x) + centerSpaceXB, (tileHeightB * curPosition.y) + centerSpaceYB, tileWidthB, tileHeightB );
        }
        
        [self.view addSubview:tile];
    }
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bMainTile.frame.size.width, bMainTile.frame.size.height)];
    [overlay setBackgroundColor:[UIColor colorWithRed:0.7 green:0.3 blue:0.4 alpha:0.6]];
    [bMainTile addSubview:overlay];
    
    remindUIImgV = [[UIImageView alloc] initWithFrame:CGRectMake(4, 470, 50, 50)];
    [remindUIImgV setImage:[UIImage imageNamed:@"remind.png"]];
    [self.view addSubview:remindUIImgV];
}

- (Tile *)getTileFromHelpBAtPoint: (CGPoint)point {
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
    if ( bHTimer1 != nil ) {
        [bHTimer1 invalidate];
        bHTimer1 = nil;
        bHtimer1Count = 0;
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
