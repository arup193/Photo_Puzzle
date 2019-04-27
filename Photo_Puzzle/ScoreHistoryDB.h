//
//  ScoreHistoryDB.h
//  Photo_Puzzle
//
//  Created by Arup Dandapat on 11/29/15.
//  Copyright (c) 2015 Mobile_Application_Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ScoreHistoryDB : NSManagedObject

@property (nonatomic, retain) NSNumber * moves;
@property (nonatomic, retain) NSNumber * timeinsec;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * matlevel;

@end
