//
//  FBGameManager.h
//  FlappyBro
//
//  Created by Stas Volskyi on 28.08.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "FBSoundManager.h"

typedef NS_ENUM(NSInteger, FBGameDifficulty)  {
    FBGameDifficultyEasy,
    FBGameDifficultyMedium,
    FBGameDifficultyHard
};

@interface FBGameManager:NSObject

@property (assign, nonatomic) BOOL enableSound;
@property (assign, nonatomic) FBGameDifficulty difficulty;
@property (assign, nonatomic) NSInteger highScore;
@property (strong ,nonatomic) NSString *rank;

+ (instancetype)sharedInstance;

@end
