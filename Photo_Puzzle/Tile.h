//
//  Tile.h
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 10/26/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Tile : UIImageView

@property (nonatomic,readwrite) CGPoint originalPosition;
@property (nonatomic,readwrite) CGPoint currentPosition;

@end
