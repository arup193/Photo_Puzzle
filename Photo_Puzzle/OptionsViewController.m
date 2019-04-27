//
//  OptionsViewController.m
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 10/26/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import "OptionsViewController.h"
#import "BackGroundPlayer.h"

@interface OptionsViewController ()

@end

@implementation OptionsViewController

AVAudioPlayer *optionPlayer;
BOOL playOptionMusic;

@synthesize delegate = _delegate;
@synthesize BackgroundMusic, SoundEffect;
@synthesize PuzzleLayout;
@synthesize cameraImageButton, galleryImageButton;

int PuzzlePictureLocal, SelectedPuzzlePicture, PuzzleLayoutLocal;
NSUserDefaults *prefsSettings;

- (void)viewWillAppear:(BOOL)animated {
    playOptionMusic = [prefsSettings boolForKey:@"SoundEffects"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    prefsSettings = [NSUserDefaults standardUserDefaults];
    SelectedPuzzlePicture = PuzzlePictureLocal = (int)[prefsSettings integerForKey:@"PuzzlePicture"];
    PuzzleLayoutLocal = (int)[prefsSettings integerForKey:@"PuzzleLayout"];
    
    if ( PuzzlePictureLocal >= 0 ) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:(90 + PuzzlePictureLocal)];
        UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btn.frame.size.width, btn.frame.size.height)];
        overlay.layer.cornerRadius = 3.0f;
        [overlay setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.6]];
        [btn addSubview:overlay];
    }
    PuzzleLayout.selectedSegmentIndex = PuzzleLayoutLocal;
    
    [prefsSettings setBool:FALSE forKey:@"Refresh"];
    
    BackgroundMusic.on = [prefsSettings boolForKey:@"PlayBackgroundMsic"];
    SoundEffect.on = [prefsSettings boolForKey:@"SoundEffects"];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"mp3"];
    NSError *err;
    optionPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath:path] error:&err];
    if ( err ) {
        //error occurred.
    } else {
        optionPlayer.currentTime = 0;
        optionPlayer.volume = 0.85;
    }
    
    if ( ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ) {
        [galleryImageButton setEnabled:NO];
    }
    else {
        [galleryImageButton setEnabled:YES];
    }
    
    if ( ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
        [cameraImageButton setEnabled:NO];
    }
    else {
        [cameraImageButton setEnabled:YES];
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

- (IBAction)PuzzleLayouted:(id)sender {
    if ( playOptionMusic == TRUE  && optionPlayer.playing == NO ) {
        [optionPlayer play];
    }
    
    [prefsSettings setInteger:PuzzleLayout.selectedSegmentIndex forKey:@"PuzzleLayout"];
}

- (IBAction)Back:(id)sender {
    if ( playOptionMusic == TRUE  && optionPlayer.playing == NO ) {
        [optionPlayer play];
    }
    
    if ( SelectedPuzzlePicture != PuzzlePictureLocal || PuzzleLayout.selectedSegmentIndex != PuzzleLayoutLocal ) {
        [prefsSettings setBool:TRUE forKey:@"Refresh"];
    }
    
    [self.delegate optionsViewControllerDidFinish:self WithAnimation:YES];
}

- (IBAction)PickFromGallery:(id)sender {
    if ( playOptionMusic == TRUE  && optionPlayer.playing == NO ) {
        [optionPlayer play];
    }
    
    UIImagePickerController *galleryPicker = [[UIImagePickerController alloc] init];
    galleryPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    galleryPicker.delegate = self;
    galleryPicker.allowsEditing = NO;
    galleryPicker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:galleryPicker animated:YES completion:NULL];
}

- (IBAction)ImageFromCamera:(id)sender {
    if ( playOptionMusic == TRUE  && optionPlayer.playing == NO ) {
        [optionPlayer play];
    }
    
    UIImagePickerController *cameraPicker = [[UIImagePickerController alloc] init];
    cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraPicker.delegate = self;
    cameraPicker.allowsEditing = NO;
    cameraPicker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:cameraPicker animated:YES completion:NULL];
}

- (IBAction)BackgroundMusicChanged:(id)sender {
    if ( playOptionMusic == TRUE  && optionPlayer.playing == NO ) {
        [optionPlayer play];
    }
    
    [prefsSettings setBool:BackgroundMusic.on forKey:@"PlayBackgroundMsic"];
    AVAudioPlayer *sharedPlayer = [BackGroundPlayer sharedPlayer];
    if ( BackgroundMusic.on == TRUE ) {
        if ( sharedPlayer.playing == NO ) {
            [sharedPlayer play];
        }
    }
    else {
        if ( sharedPlayer.playing == YES ) {
            [sharedPlayer stop];
        }
    }
}

- (IBAction)SoundEffectsChanged:(id)sender {
    if ( playOptionMusic == TRUE  && optionPlayer.playing == NO ) {
        [optionPlayer play];
    }
    [prefsSettings setBool:SoundEffect.on forKey:@"SoundEffects"];
    playOptionMusic = SoundEffect.on;
}

- (IBAction)choosePicture:(id)sender {
    int previousTagNo = (int)[prefsSettings integerForKey:@"PuzzlePicture"];
    if ( previousTagNo >= 0 ) {
        UIButton *oldBtn = (UIButton *)[self.view viewWithTag:(90 + previousTagNo)];
        [[oldBtn.subviews objectAtIndex:1] removeFromSuperview];
    }
    
    UIButton *btn = (UIButton *)sender;
    int tagNo = (int)btn.tag;
    tagNo -= 90;
    SelectedPuzzlePicture = tagNo;
    [prefsSettings setInteger:tagNo forKey:@"PuzzlePicture"];
    
    [UIImagePNGRepresentation([UIImage imageNamed:[NSString stringWithFormat:@"picture%d.png", tagNo]]) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage.png"] atomically:YES];
    
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btn.frame.size.width, btn.frame.size.height)];
    overlay.layer.cornerRadius = 3.0f;
    [overlay setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.6]];
    [btn addSubview:overlay];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:NO completion:nil];
    CamView *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CamView"];
    controller.delegateCamView = self;
    controller.image = info[UIImagePickerControllerOriginalImage];
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:NO completion:nil];
}

- (void)camViewControllerDidFinish:(CamView *)controller WithStatus:(BOOL)status {
    if ( status == YES ) {
        [prefsSettings setBool:TRUE forKey:@"Refresh"];
        [prefsSettings setInteger:-1 forKey:@"PuzzlePicture"];
        [self dismissViewControllerAnimated:NO completion:nil];
        [self.delegate optionsViewControllerDidFinish:self WithAnimation:NO];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
@end
