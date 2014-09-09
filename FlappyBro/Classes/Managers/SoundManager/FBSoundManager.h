//
//  FBSoundManager.h
//  FlappyBro
//
//  Created by Stas Volskyi on 29.08.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

typedef NS_ENUM(NSInteger, FBSound) {
    FBSoundPoint,
    FBSoundCrash
};

@interface FBSoundManager:NSObject

+ (instancetype)sharedInstance;

- (void)playMusic:(BOOL)play;
- (void)playSound:(FBSound)sound;

@end
