//
//  GameViewController.m
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 10/26/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import "AppDelegate.h"
#import "GameViewController.h"
#import "ScoreHistoryDB.h"
#import <AVFoundation/AVFoundation.h>
#define MULTIPLIER 11

#define TILE_SPACING    0

@interface GameViewController ()

@end

@implementation GameViewController

AVAudioPlayer *settingPlayer, *movePlayer, *noMovePlayer, *starPlayer, *topRankPlayer;
BOOL playGameMusic;

@synthesize tiles, mainTile, gameType, scoreL;
@synthesize delegate = _delegate;
@synthesize movesLabel, timesLabel, remindButton, resetButton, optionsButton, undoButton, pausePlayButton;

NSUserDefaults *prefs;

int NUM_OF_PIECES = 2;
int SHUFFLE_NUMBER = 0;
int countmove = 0, shuffletimes = 0;
int thetime = 0, ty = 0, topRankCounter = 0;
CGFloat centerSpaceX, centerSpaceY;
Tile *oldShuffle;

CGFloat tileWidth;
CGFloat tileHeight;

CGPoint blankPosition;
NSMutableArray *undoArray = nil;

BOOL touchAllowed, paused = NO;

NSTimer *timer, *tim, *shuffleTimer, *topRankTimer;

- (void)viewWillAppear:(BOOL)animated {
    playGameMusic = [[NSUserDefaults standardUserDefaults] boolForKey:@"SoundEffects"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    prefs = [NSUserDefaults standardUserDefaults];
    
    self.tiles = [[NSMutableArray alloc] init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"mp3"];
    NSError *err;
    settingPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath:path] error:&err];
    if ( err ) {
        //error occurred.
    } else {
        settingPlayer.currentTime = 0;
        settingPlayer.volume = 0.85;
    }
    
    path = [[NSBundle mainBundle] pathForResource:@"move" ofType:@"mp3"];
    movePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath:path] error:&err];
    if ( err ) {
        //error occurred.
    } else {
        movePlayer.currentTime = 0;
        movePlayer.volume = 0.85;
    }
    
    path = [[NSBundle mainBundle] pathForResource:@"nomove" ofType:@"mp3"];
    noMovePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath:path] error:&err];
    if ( err ) {
        //error occurred.
    } else {
        noMovePlayer.currentTime = 0;
        noMovePlayer.volume = 0.85;
    }
    
    //NSString *Pic = [NSString stringWithFormat:@"picture%ld.png", (long)[prefs integerForKey:@"PuzzlePicture"]];
    NUM_OF_PIECES = (int)[prefs integerForKey:@"PuzzleLayout"] + 2;
    
    touchAllowed = NO;
    if ( [gameType isEqualToString:@"new"] ) {
        [self initPuzzle];
    }
    else if ( [gameType isEqualToString:@"resume"] ) {
        NSMutableArray *tilePositions = [prefs objectForKey:@"TilePositions"];
        undoArray = [[prefs objectForKey:@"UndoArray"] mutableCopy];
        if ( [undoArray count] == 0 || undoArray == nil ) {
            [undoButton setEnabled:NO];
        }
        else {
            [undoButton setEnabled:YES];
        }
        int mainTileIndex = (int)[prefs integerForKey:@"MainTileIndex"];
        thetime = (int)[prefs integerForKey:@"TimePlayed"] - 1;
        countmove = (int)[prefs integerForKey:@"MovesPlayed"];
        [self onTimer];
        movesLabel.text = [@"Moves: " stringByAppendingString:[NSString stringWithFormat:@"%d", countmove]];
        //UIImage *orgImage = [UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage.png"]];
        [self setTilesWithMainTilesIndex:mainTileIndex TilePosition:tilePositions];
        
        [self pauseOrPlayGame:nil];
    }
}

- (void)onTimAct {
    ty++;
    if ( ty == 2 ) {
        for (Tile *t in tiles) {
            t.layer.borderWidth = 0.5;
        }
        mainTile.layer.borderWidth = 0.5;
    }
    if ( ty == 4 ) {
        UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainTile.frame.size.width, mainTile.frame.size.height)];
        [overlay setBackgroundColor:[UIColor colorWithRed:0.7 green:0.3 blue:0.4 alpha:0.6]];
        [mainTile addSubview:overlay];
    }
    if ( ty == 6 ) {
        ty = 0;
        [tim invalidate];
        tim = nil;
        [self shuffle];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * take an image path, load the image and break it into tiles to use as our puzzle pieces.
 **/
-(void) initPuzzle {
    SHUFFLE_NUMBER = MULTIPLIER * NUM_OF_PIECES;
    
    [remindButton setEnabled:NO];
    [resetButton setEnabled:NO];
    [optionsButton setEnabled:NO];
    
    undoArray = [[NSMutableArray alloc] init];
    [undoArray removeAllObjects];
    
    [undoButton setEnabled:NO];
    
    [pausePlayButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    [pausePlayButton setEnabled:NO];
    if ( paused == YES ) {
        paused = NO;
        [[self.view viewWithTag:1200] removeFromSuperview];
    }
    
    //srandom((unsigned int)time(NULL));
    [self setTilesWithMainTilesIndex:-1 TilePosition:nil];
}

- (void) setTilesWithMainTilesIndex:(int )mainTileIndex TilePosition:(NSMutableArray *)positions {
    UIImage *orgImage = [UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage.png"]];
    if( orgImage == nil ) {
        int rno = arc4random_uniform(3); //random() % 2;
        [prefs setInteger:rno forKey:@"PuzzlePicture"];
        
        [UIImagePNGRepresentation([UIImage imageNamed:[NSString stringWithFormat:@"picture%d.png", rno]]) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage.png"] atomically:YES];
        
        orgImage = [UIImage imageNamed:[NSString stringWithFormat:@"picture%d.png", rno]];
    }
    
    if ( [tiles count] > 0 && [prefs boolForKey:@"Refresh"] == TRUE ) {
        for (Tile *t in tiles) {
            [t removeFromSuperview];
        }
        [mainTile removeFromSuperview];
    }
    [prefs setBool:FALSE forKey:@"Refresh"];
    [prefs synchronize];
    
    [self.tiles removeAllObjects];
    
    if ( orgImage.size.width > 360.0f ) {
        tileHeight = tileWidth = 360.0f / NUM_OF_PIECES;
    }
    else {
        tileHeight = tileWidth = orgImage.size.width/NUM_OF_PIECES;
    }
    
    if ( mainTileIndex == -1 ) {
        //blankPosition = CGPointMake(random() % NUM_OF_PIECES, random() % NUM_OF_PIECES);
        blankPosition = CGPointMake(arc4random_uniform(NUM_OF_PIECES), arc4random_uniform(NUM_OF_PIECES));
    }
    else {
        int mainTileX = mainTileIndex % NUM_OF_PIECES;
        int mainTileY = mainTileIndex / NUM_OF_PIECES;
        blankPosition = CGPointMake(mainTileX, mainTileY);
    }
    
    CGFloat imageDim = orgImage.size.width / NUM_OF_PIECES;
    centerSpaceX = (375.0f - (tileWidth * NUM_OF_PIECES)) / 2.0f;
    centerSpaceY = 67.0f;
    
    UIView *bv = (UIView *)[self.view viewWithTag:1300];
    
    if ( bv != nil ) {
        [bv removeFromSuperview];
    }
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(centerSpaceX - 5.0, centerSpaceY - 5.0, (NUM_OF_PIECES * tileWidth) + 10.0, (NUM_OF_PIECES * tileHeight) + 10.0)];
    borderView.layer.borderColor = [[UIColor colorWithRed:182.0/255.0
                                                   green:155.0/255.0
                                                    blue:76.0/255.0
                                                   alpha:1.0] CGColor];
    borderView.layer.borderWidth = 5.0f;
    borderView.tag = 1300;
    [self.view addSubview:borderView];
    
    for (int i = 0; i < (NUM_OF_PIECES  * NUM_OF_PIECES); i++) {
        int x = i % NUM_OF_PIECES;
        int y = i / NUM_OF_PIECES;
        
        CGPoint orgPosition, curPosition;
        orgPosition = CGPointMake(x,y);
        if ( positions != nil ) {
            curPosition = CGPointFromString([positions objectAtIndex:i]);
        }
        else {
            curPosition = orgPosition;
        }
        
        CGRect imageFrame = CGRectMake(imageDim*x, imageDim*y, imageDim, imageDim);
        CGImageRef tileImageRef = CGImageCreateWithImageInRect(orgImage.CGImage, imageFrame);
        UIImage *tileImage = [UIImage imageWithCGImage:tileImageRef];
        
        CGRect tileFrame =  CGRectMake(((tileWidth + TILE_SPACING) * curPosition.x) + centerSpaceX, ((tileHeight + TILE_SPACING) * curPosition.y) + centerSpaceY, tileWidth, tileHeight );
        
        Tile *tile = [[Tile alloc] initWithImage:tileImage];
        tile.frame = tileFrame;
        tile.originalPosition = orgPosition;
        tile.currentPosition = curPosition;
        
        CGImageRelease( tileImageRef );
        
        if( blankPosition.x == orgPosition.x && blankPosition.y == orgPosition.y ) {
            mainTile = tile;
            [self.view addSubview:tile];
            continue;
        }
        
        [tiles addObject:tile];
        [self.view addSubview:tile];
    }
    blankPosition = mainTile.currentPosition;
    if ( tim == nil && [gameType isEqualToString:@"new"] ) {
        ty = 0;
        tim = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onTimAct) userInfo:nil repeats:YES];
    }
    else {
        for (Tile *t in tiles) {
            t.layer.borderWidth = 0.5;
        }
        mainTile.layer.borderWidth = 0.5;
        UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainTile.frame.size.width, mainTile.frame.size.height)];
        [overlay setBackgroundColor:[UIColor colorWithRed:0.7 green:0.3 blue:0.4 alpha:0.6]];
        [mainTile addSubview:overlay];
        touchAllowed = YES;
    }
}

-(ShuffleMove) validMove:(Tile *) tile{
    // blank spot above current piece
    if( tile.currentPosition.x == blankPosition.x && tile.currentPosition.y == blankPosition.y+1 ){
        return UP; //Current Tile Moved UP
    }
    
    // bank splot below current piece
    if( tile.currentPosition.x == blankPosition.x && tile.currentPosition.y == blankPosition.y-1 ){
        return DOWN; //Current Tile Moved DOWN
    }
    
    // bank spot left of the current piece
    if( tile.currentPosition.x == blankPosition.x+1 && tile.currentPosition.y == blankPosition.y ){
        return LEFT; //Current Tile Moved LEFT
    }
    
    // bank spot right of the current piece
    if( tile.currentPosition.x == blankPosition.x-1 && tile.currentPosition.y == blankPosition.y ){
        return RIGHT; //Current Tile Moved RIGHT
    }
    
    return NONE;
}

-(void) movePiece:(Tile *) tile withAnimation:(BOOL) animate{
    switch ( [self validMove:tile] ) {
        case UP:
            [self movePiece:tile inDirectionX:0 inDirectionY:-1 withAnimation:animate WithDuration:0.3];
            break;
        case DOWN:
            [self movePiece:tile inDirectionX:0 inDirectionY:1 withAnimation:animate WithDuration:0.3];
            break;
        case LEFT:
            [self movePiece:tile inDirectionX:-1 inDirectionY:0 withAnimation:animate WithDuration:0.3];
            break;
        case RIGHT:
            [self movePiece:tile inDirectionX:1 inDirectionY:0 withAnimation:animate WithDuration:0.3];
            break;
        default:
            break;
    }
}

-(void) movePiece:(Tile *) tile inDirectionX:(NSInteger) dx inDirectionY:(NSInteger) dy withAnimation:(BOOL) animate WithDuration: (NSTimeInterval) duration {
    tile.currentPosition = CGPointMake( tile.currentPosition.x+dx, tile.currentPosition.y+dy);
    blankPosition = CGPointMake( blankPosition.x-dx, blankPosition.y-dy );
    mainTile.currentPosition = blankPosition;
    
    int x = tile.currentPosition.x;
    int y = tile.currentPosition.y;
    
    if( animate ){
        [UIView beginAnimations:@"frame" context:nil];
        [UIView setAnimationDuration:duration];
    }
    tile.frame = CGRectMake(((tileWidth+TILE_SPACING)*x) + centerSpaceX, ((tileHeight+TILE_SPACING)*y) + centerSpaceY, tileWidth, tileHeight );
    mainTile.frame = CGRectMake(((tileWidth+TILE_SPACING)*blankPosition.x) + centerSpaceX, ((tileHeight+TILE_SPACING)*blankPosition.y) + centerSpaceY, tileWidth, tileHeight);
    if( animate ){
        [UIView commitAnimations];
    }
}

-(void) shuffle{
    if ( shuffleTimer != nil ) {
        [shuffleTimer invalidate];
        shuffleTimer = nil;
    }
    oldShuffle = nil;
    shuffletimes = 0;
    shuffleTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(ShuffleTimer) userInfo:nil repeats:YES];
    
    /*NSMutableArray *validMoves = [[NSMutableArray alloc] init];
    
    for( int i=0; i<SHUFFLE_NUMBER; i++ ){
        [validMoves removeAllObjects];
        
        int possibleMoveCount = 4;
        
        int mainTileX = mainTile.currentPosition.x, mainTileY = mainTile.currentPosition.y;
        if ( mainTileX == 0 || mainTileX == NUM_OF_PIECES - 1 ) {
            possibleMoveCount--;
        }
        if ( mainTileY == 0 || mainTileY == NUM_OF_PIECES - 1 ) {
            possibleMoveCount--;
        }
        
        // get all of the pieces that can move
        for( Tile *t in tiles ){
            if( [self validMove:t] != NONE ){
                [validMoves addObject:t];
                if ( [validMoves count] == possibleMoveCount ) {
                    break;
                }
            }
        }
        
        if ( [validMoves count] == 0 ) {
            break;
        }
        
        // randomly select a piece to move
        NSInteger pick = random()%[validMoves count];
        //NSLog(@"shuffleRandom using pick: %d from array of size %d", pick, [validMoves count]);
        [self movePiece:(Tile *)[validMoves objectAtIndex:pick] withAnimation:YES];
    }*/
}

- (void) ShuffleTimer {
    if ( shuffletimes < SHUFFLE_NUMBER ) {
        shuffletimes++;
        NSMutableArray *validMoves = [[NSMutableArray alloc] init];
        [validMoves removeAllObjects];
        
        int possibleMoveCount = 4;
        
        int mainTileX = mainTile.currentPosition.x, mainTileY = mainTile.currentPosition.y;
        if ( mainTileX == 0 || mainTileX == NUM_OF_PIECES - 1 ) {
            possibleMoveCount--;
        }
        if ( mainTileY == 0 || mainTileY == NUM_OF_PIECES - 1 ) {
            possibleMoveCount--;
        }
        
        // get all of the pieces that can move
        for( Tile *t in tiles ){
            if( [self validMove:t] != NONE ){
                [validMoves addObject:t];
                if ( [validMoves count] == possibleMoveCount ) {
                    break;
                }
            }
        }
        
        if ( [validMoves count] == 0 ) {
            shuffletimes = SHUFFLE_NUMBER;
        }
        else {
            NSInteger pick = arc4random_uniform((int)[validMoves count]); //random() % [validMoves count];
            Tile *tile = [validMoves objectAtIndex:pick];
            if ( oldShuffle == tile ) {
                [validMoves removeObjectAtIndex:pick];
                pick = arc4random_uniform((int)[validMoves count]); //random() % [validMoves count];
                tile = [validMoves objectAtIndex:pick];
            }
            oldShuffle = tile;
            
            switch ( [self validMove:tile] ) {
                case UP:
                    [self movePiece:tile inDirectionX:0 inDirectionY:-1 withAnimation:YES WithDuration:0.1];
                    break;
                case DOWN:
                    [self movePiece:tile inDirectionX:0 inDirectionY:1 withAnimation:YES WithDuration:0.1];
                    break;
                case LEFT:
                    [self movePiece:tile inDirectionX:-1 inDirectionY:0 withAnimation:YES WithDuration:0.1];
                    break;
                case RIGHT:
                    [self movePiece:tile inDirectionX:1 inDirectionY:0 withAnimation:YES WithDuration:0.1];
                    break;
                default:
                    break;
            }
        }
    }
    else {
        touchAllowed = YES;
        if ( shuffleTimer != nil ) {
            [shuffleTimer invalidate];
            shuffleTimer = nil;
        }
        oldShuffle = nil;
        
        [remindButton setEnabled:YES];
        [resetButton setEnabled:YES];
        [optionsButton setEnabled:YES];
    }
}

-(Tile *) getPieceAtPoint:(CGPoint) point {
    CGRect touchRect = CGRectMake(point.x, point.y, 1.0, 1.0);
    
    for( Tile *t in tiles ){
        if( CGRectIntersectsRect(t.frame, touchRect) ){
            return t;
        }
    }
    return nil;
}

-(BOOL) puzzleCompleted{
    for( Tile *t in tiles ){
        if( t.originalPosition.x != t.currentPosition.x || t.originalPosition.y != t.currentPosition.y ){
            return NO;
        }
    }
    
    return YES;
}

- (IBAction)showOptions:(id)sender {
    if ( playGameMusic == TRUE  && settingPlayer.playing == NO ) {
        [settingPlayer play];
    }
    
    [prefs setInteger:thetime forKey:@"TimePlayed"];
    [prefs setInteger:countmove forKey:@"MovesPlayed"];
    OptionsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"OptionsViewController"];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)goBack:(id)sender {
    if ( playGameMusic == TRUE  && settingPlayer.playing == NO ) {
        [settingPlayer play];
    }
    
    [self.delegate gameViewControllerDidFinish:self];
}

- (IBAction)resetGame:(id)sender {
    if ( playGameMusic == TRUE  && settingPlayer.playing == NO ) {
        [settingPlayer play];
    }
    
    NUM_OF_PIECES = (int)[prefs integerForKey:@"PuzzleLayout"] + 2;
    
    [prefs setBool:YES forKey:@"Refresh"];
    movesLabel.text = @"";
    timesLabel.text = @"";
    scoreL.text = @"";
    countmove = 0;
    thetime = 0;
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    for (int i = 1; i <= 4; i++) {
        int itagNo = 1400 + i;
        UIImageView *tView = (UIImageView *)[self.view viewWithTag:itagNo];
        if ( tView != nil ) {
            [tView removeFromSuperview];
        }
    }
    touchAllowed = NO;
    //NSString *Pic = [NSString stringWithFormat:@"picture%ld.png", [prefs integerForKey:@"PuzzlePicture"]];
    /*int rno = arc4random_uniform(2); //random() % 2;
    [[NSUserDefaults standardUserDefaults] setInteger:rno forKey:@"PuzzlePicture"];
    
    [UIImagePNGRepresentation([UIImage imageNamed:[NSString stringWithFormat:@"picture%d.png", rno]]) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage.png"] atomically:YES];*/
    gameType = @"new";
    [self initPuzzle];
}

- (IBAction)remindShow:(id)sender {
    if ( playGameMusic == TRUE  && settingPlayer.playing == NO ) {
        [settingPlayer play];
    }
    
    for (Tile *t in tiles) {
        [t removeFromSuperview];
    }
    [mainTile removeFromSuperview];
    
    UIImageView *fullImage = [[UIImageView alloc] initWithFrame:CGRectMake(centerSpaceX, centerSpaceY, tileWidth * NUM_OF_PIECES, tileHeight * NUM_OF_PIECES)];
    fullImage.tag = 1010;
    fullImage.image = [UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage.png"]];
    [self.view addSubview:fullImage];
}

- (IBAction)remindHide:(id)sender {
    UIImageView *fullImage = (UIImageView *)[self.view viewWithTag:1010];
    [fullImage removeFromSuperview];
    
    for (Tile *t in tiles) {
        [self.view addSubview:t];
    }
    [self.view addSubview:mainTile];
}

- (IBAction)undoMove:(id)sender {
    if ( playGameMusic == TRUE  && settingPlayer.playing == NO ) {
        [settingPlayer play];
    }
    
    if ( [undoArray count] > 0 ) {
        CGPoint tilePosition = CGPointFromString([undoArray lastObject]);
        CGPoint tempPosition = CGPointMake(((tileWidth + TILE_SPACING) * tilePosition.x) + centerSpaceX + 15, ((tileHeight + TILE_SPACING) * tilePosition.y) + centerSpaceY + 15);
        Tile *t = [self getPieceAtPoint:tempPosition];
        [self movePiece:t withAnimation:YES];
        [undoArray removeLastObject];
        
        if ( [undoArray count] == 0 ) {
            if ( [undoButton isEnabled] == YES ) {
                [undoButton setEnabled:NO];
            }
        }
    }
}

- (IBAction)pauseOrPlayGame:(id)sender {
    if ( playGameMusic == TRUE  && settingPlayer.playing == NO ) {
        [settingPlayer play];
    }
    
    if ( paused == NO ) {
        if (timer != nil) {
            [timer invalidate];
            timer = nil;
        }
        paused = YES;
        [pausePlayButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        touchAllowed = NO;
        [undoButton setEnabled:NO];
        [remindButton setEnabled:NO];
        UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(centerSpaceX, centerSpaceY, NUM_OF_PIECES * tileWidth, NUM_OF_PIECES * tileHeight)];
        overlay.tag = 1200;
        [overlay setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3]];
        if ( [self.view viewWithTag:1200] == nil ) {
            [self.view addSubview:overlay];
        }
    }
    else {
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
        touchAllowed = YES;
        [remindButton setEnabled:YES];
        if ( [undoArray count] > 0 ) {
            [undoButton setEnabled:YES];
        }
        UIView *overlay = (UIView *)[self.view viewWithTag:1200];
        [overlay removeFromSuperview];
        movesLabel.text = [@"Moves: " stringByAppendingString:[NSString stringWithFormat:@"%d", countmove]];
        paused = NO;
        [pausePlayButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //[self movePiece:(Tile *)[tiles objectAtIndex:0] withAnimation:YES];
    if ( touchAllowed == YES ) {
        UITouch *touch = [touches anyObject];
        CGPoint currentTouch = [touch locationInView:self.view];
        
        Tile *t = [self getPieceAtPoint:currentTouch];
        if( t != nil ){
            //Start the game timer
            //Move the pieces
            if ( [self validMove:t] != NONE ) {
                if (timer == nil) {
                    timesLabel.text = @"Time: 0";
                    scoreL.text = @"Score: 9999";
                    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
                }
                
                if ( playGameMusic == TRUE  && movePlayer.playing == NO ) {
                    [movePlayer play];
                }
                
                countmove++;
                movesLabel.text = [@"Moves: " stringByAppendingString:[NSString stringWithFormat:@"%d", countmove]];
                
                [undoArray addObject:NSStringFromCGPoint(mainTile.currentPosition)];
                if ( [undoArray count] > 0 ) {
                    if ( [undoButton isEnabled] == NO ) {
                        [undoButton setEnabled:YES];
                    }
                }
                
                [self movePiece:t withAnimation:YES];
                
                if ( [pausePlayButton isEnabled] == NO ) {
                    [pausePlayButton setEnabled:YES];
                }
                
                if( [self puzzleCompleted] ){
                    [[mainTile.subviews objectAtIndex:0] removeFromSuperview];
                    mainTile.layer.borderWidth = 0.0;
                    for (Tile *t in tiles) {
                        t.layer.borderWidth = 0.0;
                    }
                    
                    if ( [undoArray count] > 0 ) {
                        [undoArray removeAllObjects];
                    }
                    [undoButton setEnabled:NO];
                    [pausePlayButton setEnabled:NO];
                    [remindButton setEnabled:NO];
                    
                    
                    if (timer != nil) {
                        [timer invalidate];
                        timer = nil;
                    }
                    thetime--;
                    [self onTimer];
                    
                    /* Game Completed Animation Begins */
                    
                    UIImageView *star1, *star2, *star3;
                    star1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star.png"]];
                    star2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star.png"]];
                    star3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star.png"]];
                    star1.frame = CGRectMake(16, 280, 240, 240);
                    star2.frame = CGRectMake(67, 280, 240, 240);
                    star3.frame = CGRectMake(119, 280, 240, 240);
                    star1.alpha = star2.alpha = star3.alpha = 0;
                    star1.tag = 1401;
                    star2.tag = 1402;
                    star3.tag = 1403;
                    
                    [self.view addSubview:star1];
                    [UIView beginAnimations:@"frame" context:nil];
                    [UIView setAnimationDuration:0.4];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                    star1.frame = CGRectMake(117, 380, 40, 40);
                    star1.alpha = 1;
                    [UIView commitAnimations];
                    
                    [self.view addSubview:star2];
                    [UIView beginAnimations:@"frame" context:nil];
                    [UIView setAnimationDuration:0.8];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                    star2.frame = CGRectMake(167, 380, 40, 40);
                    star2.alpha = 1;
                    [UIView commitAnimations];
                    
                    [self.view addSubview:star3];
                    [UIView beginAnimations:@"frame" context:nil];
                    [UIView setAnimationDuration:1.2];
                    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                    star3.frame = CGRectMake(217, 380, 40, 40);
                    star3.alpha = 1;
                    [UIView commitAnimations];
                    
                    if ( playGameMusic == TRUE ) {
                        NSString *path = [[NSBundle mainBundle] pathForResource:@"starSound" ofType:@"mp3"];
                        NSError *err;
                        starPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath:path] error:&err];
                        if ( err ) {
                            //error occurred.
                        } else {
                            starPlayer.currentTime = 0;
                            starPlayer.volume = 0.85;
                        }
                        [starPlayer play];
                    }
                    
                    /* Game Completed Animation Ends */
                    
                    
                    /* Top Rank Animation Begins */
                    
                    if (topRankTimer == nil) {
                        topRankTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(topRankAnimation) userInfo:nil repeats:YES];
                    }
                    
                    /* Top Rank Animation Ends */
                    
                    touchAllowed = NO;
                    [prefs setBool:TRUE forKey:@"Refresh"];
                    [prefs synchronize];
                }
            }
            else {
                if ( playGameMusic == TRUE  && noMovePlayer.playing == NO ) {
                    [noMovePlayer play];
                }
            }
        }
    }
}

-(void) topRankAnimation {
    topRankCounter++;
    if ( topRankCounter == 2 ) {
        topRankCounter = 0;
        if ( topRankTimer != nil ) {
            [topRankTimer invalidate];
            topRankTimer = nil;
        }
        double timefactor = (NUM_OF_PIECES - 1) / sqrt(thetime);
        double movefactor = NUM_OF_PIECES / (double)(countmove * countmove);
        NSNumber *scr = [NSNumber numberWithInt:(timefactor + movefactor)*1000];
        
        int rank = [self getRankWithScore:scr];
        [self addScoreWithMoves:countmove Time:thetime];
        countmove = 0;
        thetime = 0;
        if ( rank < 4 ) {
            UIImageView *medal = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"rank%d.png", rank]]];
            medal.tag = 1404;
            medal.frame = CGRectMake(12, 50, 350, 490);
            medal.alpha = 0;
            [self.view addSubview:medal];
            [UIView beginAnimations:@"frame" context:nil];
            
            [UIView setAnimationDuration:2.0];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            medal.frame = CGRectMake(315, 355, 50, 70);
            medal.alpha = 1;
            [UIView commitAnimations];
            
            if ( playGameMusic == TRUE ) {
                NSString *path = [[NSBundle mainBundle] pathForResource:@"topRank" ofType:@"mp3"];
                NSError *err;
                topRankPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath:path] error:&err];
                if ( err ) {
                    //error occurred.
                } else {
                    topRankPlayer.currentTime = 0;
                    topRankPlayer.volume = 0.85;
                }
                [topRankPlayer play];
            }
        }
    }
}

-(int) getRankWithScore: (NSNumber *)score {
    NSManagedObjectContext *mds = [[[UIApplication sharedApplication] delegate] performSelector:@selector(managedObjectContext)];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ScoreHistoryDB" inManagedObjectContext:mds];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setFetchLimit:3];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSMutableArray *topPlay = [[mds executeFetchRequest:request error:&error] mutableCopy];
    if ( error != nil )
    {
        //Error Handling
    }
    else
    {
        int rank = 1;
        for (int i = 0; i < [topPlay count]; i++) {
            ScoreHistoryDB *sch = [topPlay objectAtIndex:i];
            if ( [score intValue] > [sch.score intValue] ) {
                return rank;
            }
            rank++;
        }
        return rank;
    }
    return 100;
}

- (void)onTimer {
    thetime++;
    
    int time = thetime;
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
    timesLabel.text = [@"Time: " stringByAppendingString: timeString];
    
    double timefactor = (NUM_OF_PIECES - 1) / sqrt(thetime);
    double movefactor = NUM_OF_PIECES / (double)(countmove * countmove);
    NSNumber *scr = [NSNumber numberWithInt:(timefactor + movefactor)*1000];
    scoreL.text = [@"Score: " stringByAppendingString:[NSString stringWithFormat:@"%@", scr]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)optionsViewControllerDidFinish:(OptionsViewController *)controller WithAnimation:(BOOL)animate
{
    [self dismissViewControllerAnimated:animate completion:nil];
    
    NUM_OF_PIECES = (int)[prefs integerForKey:@"PuzzleLayout"] + 2;
    
    if ([prefs boolForKey:@"Refresh"] == TRUE) {
        movesLabel.text = @"";
        timesLabel.text = @"";
        scoreL.text = @"";
        countmove = 0;
        thetime = 0;
        if (timer != nil) {
            [timer invalidate];
            timer = nil;
        }
        for (int i = 1; i <= 4; i++) {
            int itagNo = 1400 + i;
            UIImageView *tView = (UIImageView *)[self.view viewWithTag:itagNo];
            if ( tView != nil ) {
                [tView removeFromSuperview];
            }
        }
        touchAllowed = YES;
        //NSString *Pic = [NSString stringWithFormat:@"picture%ld.png", [prefs integerForKey:@"PuzzlePicture"]];
        gameType = @"new";
        if ( [self.view viewWithTag:1200] != nil ) {
            [[self.view viewWithTag:1200] removeFromSuperview];
        }
        [self initPuzzle];
    }
    else {
        thetime = (int)[prefs integerForKey:@"TimePlayed"];
        countmove = (int)[prefs integerForKey:@"MovesPlayed"];
        if ( thetime > 0 && countmove > 0 ) {
            /*thetime--;
            [self onTimer];
            movesLabel.text = [@"Moves: " stringByAppendingString:[NSString stringWithFormat:@"%d", countmove]];*/
            [self pauseOrPlayGame:nil];
            movesLabel.text = [@"Moves: " stringByAppendingString:[NSString stringWithFormat:@"%d", countmove]];
        }
    }
}

-(void)addScoreWithMoves:(int)moves Time:(int)time
{
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *md = app.managedObjectContext;
    ScoreHistoryDB *sch = (ScoreHistoryDB *)[NSEntityDescription insertNewObjectForEntityForName:@"ScoreHistoryDB" inManagedObjectContext:md];
    double timefactor = (NUM_OF_PIECES - 1) / sqrt(thetime);
    double movefactor = NUM_OF_PIECES / (double)(countmove * countmove);
    NSNumber *scr = [NSNumber numberWithInt:(timefactor + movefactor)*1000];
    [sch setMoves:[NSNumber numberWithInt:moves]];
    [sch setTimeinsec:[NSNumber numberWithInt:time]];
    [sch setScore:scr];
    [sch setMatlevel:[NSNumber numberWithInt:NUM_OF_PIECES]];
    NSError *error;
    if(![md save:&error])
    {
        // Handle the error.
    }
    else
    {
        // Successfully added the record.
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if ( thetime > 0 && countmove > 0 ) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (int i = 0; i < (NUM_OF_PIECES * NUM_OF_PIECES); i++) {
            [arr addObject:@""];
        }
        for (Tile *t in tiles) {
            int index = t.originalPosition.y*NUM_OF_PIECES + t.originalPosition.x;
            [arr replaceObjectAtIndex:index withObject:NSStringFromCGPoint(t.currentPosition)];
        }
        int mainTileIndex = mainTile.originalPosition.y*NUM_OF_PIECES + mainTile.originalPosition.x;
        [arr replaceObjectAtIndex:mainTileIndex withObject:NSStringFromCGPoint(mainTile.currentPosition)];
        [prefs setObject:arr forKey:@"TilePositions"];
        [prefs setObject:undoArray forKey:@"UndoArray"];
        [prefs setInteger:mainTileIndex forKey:@"MainTileIndex"];
        [prefs setInteger:thetime forKey:@"TimePlayed"];
        [prefs setInteger:countmove forKey:@"MovesPlayed"];
    }
    else {
        [prefs setObject:nil forKey:@"TilePositions"];
    }
    [prefs synchronize];
    
    paused = NO;
    countmove = 0;
    thetime = 0;
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
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
