//
//  GameViewController.h
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 10/26/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionsViewController.h"
#import "Tile.h"

@class GameViewController;

@protocol GameViewControllerDelegate
- (void)gameViewControllerDidFinish:(GameViewController *)controller;
@end

typedef enum {
    NONE			= 0,
    UP				= 1,
    DOWN			= 2,
    LEFT			= 3,
    RIGHT			= 4
} ShuffleMove;

@interface GameViewController : UIViewController <OptionsViewControllerDelegate>

@property(nonatomic) NSString *gameType;
@property (nonatomic,retain) NSMutableArray *tiles;
@property (nonatomic,retain) Tile *mainTile;

@property (weak, nonatomic) IBOutlet UILabel *movesLabel;
@property (weak, nonatomic) IBOutlet UILabel *timesLabel;


-(void) initPuzzle;

-(ShuffleMove) validMove:(Tile *) tile;
-(void) movePiece:(Tile *) tile withAnimation:(BOOL) animate;
-(void) movePiece:(Tile *) tile inDirectionX:(NSInteger) dx inDirectionY:(NSInteger) dy withAnimation:(BOOL) animate WithDuration: (NSTimeInterval) duration;
-(void) shuffle;

-(Tile *) getPieceAtPoint:(CGPoint) point;
-(BOOL) puzzleCompleted;

@property (assign, nonatomic) IBOutlet id <GameViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *remindButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *pausePlayButton;
@property (weak, nonatomic) IBOutlet UILabel *scoreL;

- (IBAction)showOptions:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)resetGame:(id)sender;
- (IBAction)remindShow:(id)sender;
- (IBAction)remindHide:(id)sender;
- (IBAction)undoMove:(id)sender;
- (IBAction)pauseOrPlayGame:(id)sender;
@end
