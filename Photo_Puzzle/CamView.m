//
//  CamView.m
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 11/6/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "CamView.h"

CGFloat cropX, cropY, cropW, cropH, viewX, viewY, viewW, viewH, scalingFactor;

@implementation CamView

AVAudioPlayer *camPlayer;
BOOL playCamMusic;

- (void)viewWillAppear:(BOOL)animated {
    playCamMusic = [[NSUserDefaults standardUserDefaults] boolForKey:@"SoundEffects"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"mp3"];
    NSError *err;
    camPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath:path] error:&err];
    if ( err ) {
        //error occurred.
    } else {
        camPlayer.currentTime = 0;
        camPlayer.volume = 0.85;
    }
    
    CGFloat widthFactor = 375.0f / _image.size.width;
    CGFloat heightFactor = 600.0f / _image.size.height;
    
    if ( widthFactor < heightFactor ) {
        scalingFactor = widthFactor;
    }
    else {
        scalingFactor = heightFactor;
    }
    viewW = _image.size.width * scalingFactor;
    viewH = _image.size.height * scalingFactor;
    _resultImageView.frame = CGRectMake(0.0f, 0.0f, viewW, viewH);
    _resultImageView.center = CGPointMake(187.5f, 333.5f);
    
    _resultImageView.image = _image;
    _resultImageView.layer.borderWidth = 1;
    
    cropX = viewX = _resultImageView.frame.origin.x;
    cropY = viewY = _resultImageView.frame.origin.y;
    
    if ( _image.size.width < _image.size.height ) {
        int len = _image.size.width / 60;
        if ( len > 12 ) {
            len = 12;
        }
        cropH = cropW = len * 60.0f * scalingFactor;
    }
    else {
        int len = _image.size.height / 60;
        if ( len > 12 ) {
            len = 12;
        }
        cropH = cropW = len * 60.0f* scalingFactor;
    };
    _cropBounds.frame = CGRectMake(cropX, cropY, cropW, cropH);
    _cropBounds.center = CGPointMake(187.5f, 333.5f);
}

//- (void)viewWillAppear:(BOOL)animated
//{
//	[super viewWillAppear:animated];
//
//	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
//	[self.navigationController setNavigationBarHidden:YES animated:NO];
//}

- (IBAction)handlePanGestures:(UIPanGestureRecognizer *)sender {
    switch ( sender.state ) {
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [sender translationInView:self.view];
            
            sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
            [sender setTranslation:CGPointMake(0, 0) inView:self.view];
            
            float leftX = CGRectGetMinX(_cropBounds.frame);
            float rightX = CGRectGetMaxX(_cropBounds.frame);
            float topY = CGRectGetMinY(_cropBounds.frame);
            float bottomY = CGRectGetMaxY(_cropBounds.frame);
            
            CGRect frameVal = _cropBounds.frame;
            if ( topY <= viewY ) {
                frameVal.origin.y = viewY;
            }
            if ( bottomY >= (viewY + viewH) ) {
                frameVal.origin.y = viewY + viewH - cropH;
            }
            if ( leftX <= viewX ) {
                frameVal.origin.x = viewX;
            }
            if ( rightX >= (viewX + viewW) ) {
                frameVal.origin.x = viewX + viewW - cropW;
            }
            _cropBounds.frame = frameVal;
            
            break;
         
        }
        default:
            break;
    }
}

- (IBAction)getCropRegion:(id)sender {
    if ( playCamMusic == TRUE  && camPlayer.playing == NO ) {
        [camPlayer play];
    }
    
    CGFloat cropRegionX = (_cropBounds.frame.origin.x - _resultImageView.frame.origin.x) / scalingFactor;
    CGFloat cropRegionY = (_cropBounds.frame.origin.y - _resultImageView.frame.origin.y) / scalingFactor;
    CGFloat cropRegionW = _cropBounds.frame.size.width / scalingFactor;
    CGFloat cropRegionH = _cropBounds.frame.size.height / scalingFactor;
    UIImage *image = _resultImageView.image;
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(cropRegionX, cropRegionY, cropRegionW, cropRegionH));
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    [UIImagePNGRepresentation(croppedImage) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/savedImage.png"] atomically:YES];
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"Refresh"];
    [_delegateCamView camViewControllerDidFinish:self WithStatus:YES];
}

- (IBAction)cancelImage:(id)sender {
    if ( playCamMusic == TRUE  && camPlayer.playing == NO ) {
        [camPlayer play];
    }
    
    [_delegateCamView camViewControllerDidFinish:self WithStatus:NO];
}
@end
