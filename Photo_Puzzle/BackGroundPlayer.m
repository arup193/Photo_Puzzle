//
//  BackGroundPlayer.m
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 11/20/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import "BackGroundPlayer.h"

@implementation BackGroundPlayer

+ (AVAudioPlayer *)sharedPlayer {
    //static BackGroundPlayer *sharedPlayer = nil;
    static AVAudioPlayer *backgroundMusicPlayer = nil;
    @synchronized(self) {
        if ( backgroundMusicPlayer == nil ) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"background" ofType:@"mp3"];
            NSError *err;
            backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath:path] error:&err];
            
            if ( err ) {
                //error occurred.
            } else {
                backgroundMusicPlayer.numberOfLoops = -1;
                backgroundMusicPlayer.currentTime = 0;
                backgroundMusicPlayer.volume = 0.3;
            }
        }
    }
    return backgroundMusicPlayer;
}

+ (AVAudioPlayer *)sharedSettingsPlayer {
    static AVAudioPlayer *settingMusicPlayer = nil;
    @synchronized(self) {
        if ( settingMusicPlayer == nil ) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"mp3"];
            NSError *err;
            settingMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath:path] error:&err];
            
            if ( err ) {
                //error occurred.
            } else {
                settingMusicPlayer.currentTime = 0;
                settingMusicPlayer.volume = 0.85;
            }
        }
    }
    return settingMusicPlayer;
}

@end
