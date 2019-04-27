//
//  CamView.h
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 11/6/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CamView;

@protocol CamViewDelegate
- (void)camViewControllerDidFinish:(CamView *)controller WithStatus:(BOOL)status;
@end

@interface CamView : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (weak, nonatomic) IBOutlet UIView *cropBounds;
@property (nonatomic) UIImage *image;

@property (assign, nonatomic) IBOutlet id <CamViewDelegate> delegateCamView;

- (IBAction)handlePanGestures:(UIPanGestureRecognizer *)sender;
- (IBAction)getCropRegion:(id)sender;
- (IBAction)cancelImage:(id)sender;
@end
