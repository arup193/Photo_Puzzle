//
//  OptionsViewController.h
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 10/26/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CamView.h"

@class OptionsViewController;

@protocol OptionsViewControllerDelegate
- (void)optionsViewControllerDidFinish:(OptionsViewController *)controller WithAnimation:(BOOL)animate;
@end

@interface OptionsViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, CamViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *PuzzleLayout;
@property (weak, nonatomic) IBOutlet UISwitch *BackgroundMusic;
@property (weak, nonatomic) IBOutlet UISwitch *SoundEffect;

@property (assign, nonatomic) IBOutlet id <OptionsViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *galleryImageButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraImageButton;

- (IBAction)PuzzleLayouted:(id)sender;
- (IBAction)Back:(id)sender;
- (IBAction)PickFromGallery:(id)sender;
- (IBAction)ImageFromCamera:(id)sender;
- (IBAction)BackgroundMusicChanged:(id)sender;
- (IBAction)SoundEffectsChanged:(id)sender;
- (IBAction)choosePicture:(id)sender;
@end
