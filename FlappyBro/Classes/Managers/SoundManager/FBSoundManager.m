//
//  FBSoundManager.m
//  FlappyBro
//
//  Created by Stas Volskyi on 29.08.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "FBSoundManager.h"
#import <AVFoundation/AVFoundation.h>

CGFloat const FBMaxMusicVolume = 0.6f;

@interface FBSoundManager ()

@property (strong, nonatomic) AVAudioPlayer *musicPlayer;
@property (strong, nonatomic) AVAudioPlayer *soundPlayer;
@property (strong, nonatomic) NSTimer *volumeTimer;

@end

@implementation FBSoundManager

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupPlayer];
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

#pragma mark - Custom Accessors

#pragma mark - Public

- (void)playMusic:(BOOL)play
{
    if (play) {
        [self setupPlayer];
        self.musicPlayer.volume = 0;
        [self.musicPlayer play];
        self.volumeTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(changeVolume:) userInfo:@{@"up" : @YES} repeats:YES];
    } else {
        self.musicPlayer.volume = FBMaxMusicVolume;
        self.volumeTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(changeVolume:) userInfo:nil repeats:YES];
    }
}

- (void)playSound:(FBSound)sound
{
    
}

#pragma mark - Private

- (void)changeVolume:(NSTimer *)timer
{
    BOOL play = timer.userInfo ? YES : NO;
    if (play) {
        self.musicPlayer.volume += 0.1;
        if (self.musicPlayer.volume >= FBMaxMusicVolume) {
            [self.volumeTimer invalidate];
        }
    } else {
        self.musicPlayer.volume -= 0.1;
        if (self.musicPlayer.volume <= 0.1) {
            [self.musicPlayer stop];
            [self.volumeTimer invalidate];
        }
    }
}

- (void)setupPlayer
{
    NSError *error;
    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"gameMusic" ofType:@".mp3"]];
    self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.musicPlayer.volume = FBMaxMusicVolume;
    self.musicPlayer.numberOfLoops = -1;
    [self.musicPlayer prepareToPlay];
}

@end
