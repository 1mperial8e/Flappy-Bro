//
//  FBGameManager.m
//  FlappyBro
//
//  Created by Stas Volskyi on 28.08.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "FBGameManager.h"

static NSString *const FBFirstLaunchKey = @"firstLaunch";
static NSString *const FBDifficultyKey = @"difficulty";
static NSString *const FBSoundKey = @"enableSound";
static NSString *const FBHighScoreKey = @"highScore";
static NSString *const FBRankKey = @"rank";

static NSString *const FBRankCadet = @"Cadet";
static NSString *const FBRankSergeant = @"Sergeant";
static NSString *const FBRankLieutenant = @"Lieutenant";
static NSString *const FBRankMajor = @"Major";
static NSString *const FBRankChiefOfPolice = @"Chief of Police";

@interface FBGameManager ()

@end

@implementation FBGameManager

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupGameSettings];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t dispatchOnceT;
    dispatch_once(&dispatchOnceT, ^{
    sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - CustomAccessors

- (void)setEnableSound:(BOOL)enableSound
{
    _enableSound = enableSound;
    [[NSUserDefaults standardUserDefaults] setBool:enableSound forKey:FBSoundKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setDifficulty:(FBGameDifficulty)difficulty
{
    _difficulty = difficulty;
    [[NSUserDefaults standardUserDefaults] setInteger:difficulty forKey:FBDifficultyKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setHighScore:(NSInteger)highScore
{
    if (_highScore < highScore) {
        _highScore = highScore;
        [[NSUserDefaults standardUserDefaults] setInteger:highScore forKey:FBHighScoreKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self checkForNewRank];
    }
}

#pragma mark - Private

- (void)checkForNewRank
{
    if (self.highScore > 100) {
        self.rank = FBRankChiefOfPolice;
    } else if (self.highScore > 50) {
        self.rank = FBRankMajor;
    } else if (self.highScore > 20) {
        self.rank = FBRankLieutenant;
    } else if (self.highScore > 10) {
        self.rank = FBRankSergeant;
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.rank forKey:FBRankKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setupGameSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults integerForKey:FBFirstLaunchKey]) {
        [defaults setInteger:1 forKey:FBFirstLaunchKey];
        [defaults setBool:YES forKey:FBSoundKey];
        [defaults setInteger:FBGameDifficultyEasy forKey:FBDifficultyKey];
        [defaults setInteger:0 forKey:FBHighScoreKey];
        [defaults setObject:FBRankCadet forKey:FBRankKey];
        [defaults synchronize];
        
        self.enableSound = YES;
        self.difficulty = FBGameDifficultyEasy;
        self.rank = FBRankCadet;
        self.highScore = 0;
        
    } else {
        self.enableSound = [defaults boolForKey:FBSoundKey];
        self.difficulty = [defaults integerForKey:FBDifficultyKey];
        self.rank = [defaults objectForKey:FBRankKey];
        self.highScore = [defaults integerForKey:FBHighScoreKey];
    }
}

@end
