//
//  BackGroundPlayer.h
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 11/20/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface BackGroundPlayer : NSObject

+ (AVAudioPlayer *)sharedPlayer;
+ (AVAudioPlayer *)sharedSettingsPlayer;

@end
