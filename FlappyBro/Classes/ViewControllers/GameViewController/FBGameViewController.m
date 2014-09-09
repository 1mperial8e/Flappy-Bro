//
//  FBViewController.m
//  FlappyBro
//
//  Created by Stas Volskyi on 27.08.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "FBGameViewController.h"
#import "FBGameManager.h"

static NSString *const FBFontName = @"Prisma";

const CGSize FBBroSize = {35.0f, 29.0f};
const CGFloat FBKickBroDistance = 50.0f;
const CGFloat FBKickBroDuration = 0.3f;
const CGFloat FBBroFallingHalfScreenMSeconds = 40.0f;
const CGFloat FBStickAppearanceTime = 1.8f;
const CGFloat FBCrashBroFallingHalfScreenMSeconds = 20.0f;
const CGFloat FBBroPositionX = 70.0f;
const CGFloat FBStickWidth = 40.0f;
const CGFloat FBDistanceBetweenSticks = 120.0f;
const CGFloat FBStickLeftScreenDuration = 3.5f;
const CGFloat FBCarAnimationDuration = 7.0f;

@interface FBGameViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *groundView;

@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UILabel *gameTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *soundButton;
@property (weak, nonatomic) IBOutlet UILabel *theNewRankLabel;

@property (weak, nonatomic) IBOutlet UIView *endgameView;
@property (weak, nonatomic) IBOutlet UILabel *scoreTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameScoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *tryAgainButton;
@property (weak, nonatomic) IBOutlet UIButton *endGameButton;
@property (weak, nonatomic) IBOutlet UILabel *theNewHighScoreLabel;

@property (strong, nonatomic) UIImageView *broView;
@property (strong, nonatomic) UIImageView *carView;
@property (strong, nonatomic) UIImageView *bonusView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) NSMutableArray *sticks;
@property (strong, nonatomic) NSTimer *stickAppearanceTimer;
@property (strong, nonatomic) NSTimer *broGameTimer;
@property (strong, nonatomic) NSTimer *carTimer;
@property (assign, nonatomic) NSInteger score;
@property (assign, nonatomic) CGFloat gameDuration;
@property (strong, nonatomic) NSArray *groundImages;
@property (strong, nonatomic) UILabel *getReadyLabel;
@property (assign, nonatomic) CATransform3D broUpTransform;
@property (assign, nonatomic) CATransform3D broDownTransform;
@property (assign, nonatomic) CATransform3D broCrashTransform;

@property (assign, nonatomic) NSInteger bonusAppearanceScore;

@property (assign, nonatomic) BOOL startGame;
@property (assign, nonatomic) BOOL isBonus;

@end

@implementation FBGameViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [FBSoundManager sharedInstance];
    [FBGameManager sharedInstance];
    
    [self setupUI];
}

#pragma mark - Private

- (void)setupUI
{
    self.menuView.hidden = NO;
    self.endgameView.hidden = YES;
    self.broUpTransform = CATransform3DMakeRotation(-(M_PI / 2) / 1.5, 0, 0, 1);
    self.broDownTransform = CATransform3DMakeRotation((M_PI / 2) / 1.5, 0, 0, 1);
    self.broCrashTransform = CATransform3DMakeRotation(0, 0, 0, 1);
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:(76.0/255.0) green:(109.0/255.0) blue:(255.0/255.0) alpha:1.0].CGColor, (id)[UIColor colorWithRed:(253.0/255.0) green:(247.0/255.0) blue:(78.0/255.0) alpha:1.0].CGColor, nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [self setupLabels];
    [self setupButtons];
    [self addTapGesture];
    [self applyInterpolationEffect];
    [self createGroundImages];
}

- (void)addTapGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(kickBro:)];
    [self.containerView addGestureRecognizer:tapGesture];
    tapGesture.enabled = NO;
    self.tapGesture = tapGesture;
}

#pragma mark - UICustomization

- (void)setupLabels
{
    UIFont *font = [UIFont fontWithName:FBFontName size:50.0];
    UIColor *fontColor = [UIColor colorWithRed:(19.0/255.0) green:(37.0/255.0) blue:(78.0/255.0) alpha:1.0];
    self.gameTitleLabel.font = font;
    self.gameTitleLabel.textColor = fontColor;
    self.gameTitleLabel.text = @"Flappy\nBro";
    
    self.resultScoreLabel.font = [UIFont fontWithName:FBFontName size:40.0];
    self.resultScoreLabel.textColor = fontColor;
    
    self.scoreTextLabel.font = [UIFont fontWithName:FBFontName size:50.0];;
    self.scoreTextLabel.textColor = fontColor;
    
    self.gameScoreLabel.font = [UIFont fontWithName:FBFontName size:30.0];
    self.gameScoreLabel.textColor = fontColor;
    
    self.theNewRankLabel.font = [UIFont fontWithName:FBFontName size:35.0];
    self.theNewRankLabel.textColor = fontColor;
    
    self.theNewHighScoreLabel.font = [UIFont fontWithName:FBFontName size:20.0];
    self.theNewHighScoreLabel.textColor = fontColor;
}

- (void)setupButtons
{
    UIFont *font = [UIFont fontWithName:FBFontName size:38.0];
    UIColor *fontColor = [UIColor colorWithRed:(19.0/255.0) green:(37.0/255.0) blue:(78.0/255.0) alpha:1.0];
    
    self.playButton.titleLabel.font = font;
    [self.playButton setTitleColor:fontColor forState:UIControlStateNormal];
    self.playButton.backgroundColor = [UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:0.3];
    self.playButton.layer.shadowOffset = CGSizeMake(-2.0f, 2.0f);
    self.playButton.layer.shadowOpacity = 1.0;
    self.playButton.layer.shadowRadius = 1.0;
    self.playButton.layer.shadowColor = [UIColor colorWithRed:(19.0/255.0) green:(37.0/255.0) blue:(78.0/255.0) alpha:1.0].CGColor;
    
    self.endGameButton.titleLabel.font = font;
    [self.endGameButton setTitleColor:fontColor forState:UIControlStateNormal];
    
    self.tryAgainButton.titleLabel.font = font;
    [self.tryAgainButton setTitleColor:fontColor forState:UIControlStateNormal];
    
    UIImage *soundImage = [UIImage imageNamed:[FBGameManager sharedInstance].enableSound ? @"Sound on" : @"Sound off"];
    [self.soundButton setImage:soundImage forState:UIControlStateNormal];
    
}


- (void)applyInterpolationEffect
{
    UIInterpolatingMotionEffect *horisontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horisontal.minimumRelativeValue = @(-20);
    horisontal.maximumRelativeValue = @(20);
    
    UIInterpolatingMotionEffect *vertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    vertical.minimumRelativeValue = @(-20);
    vertical.maximumRelativeValue = @(20);
    
    [self.gameTitleLabel addMotionEffect:horisontal];
    [self.gameTitleLabel addMotionEffect:vertical];
}

- (void)createViews
{
    [self.carView removeFromSuperview];
    UIImageView *car = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"policeCar"]];
    car.frame = CGRectMake(self.view.frame.size.width, CGRectGetMidY(self.containerView.frame), 160, 120);
    car.layer.opacity = 0.8f;
    [self.containerView insertSubview:car atIndex:0];
    self.carView = car;
}

- (void)createGroundImages
{
    self.groundView.backgroundColor = [UIColor colorWithRed:(19.0/255.0) green:(37.0/255.0) blue:(78.0/255.0) alpha:1.0];
    UIImage *image = [UIImage imageNamed:[FBGameManager sharedInstance].rank];
    
    CGSize imageSize = image.size;
    UIImageView *firstImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    firstImage.backgroundColor = [UIColor colorWithRed:(19.0/255.0) green:(37.0/255.0) blue:(78.0/255.0) alpha:1.0];
    firstImage.contentMode = UIViewContentModeCenter;
    [self.groundView addSubview:firstImage];
    
    UIImageView *secondImage = [[UIImageView alloc] initWithFrame:CGRectMake(imageSize.width, 0, imageSize.width, imageSize.height)];
    secondImage.backgroundColor = [UIColor colorWithRed:(19.0/255.0) green:(37.0/255.0) blue:(78.0/255.0) alpha:1.0];
    secondImage.contentMode = UIViewContentModeCenter;
    [self.groundView addSubview:secondImage];
    
    UIImageView *thirtImage = [[UIImageView alloc] initWithFrame:CGRectMake(imageSize.width * 2, 0, imageSize.width, imageSize.height)];
    thirtImage.backgroundColor = [UIColor colorWithRed:(19.0/255.0) green:(37.0/255.0) blue:(78.0/255.0) alpha:1.0];
    thirtImage.contentMode = UIViewContentModeCenter;
    [self.groundView addSubview:thirtImage];
    
    self.groundImages = [NSArray arrayWithObjects:firstImage, secondImage, thirtImage, nil];
    
    [self setRankImages];
}

- (void)setRankImages
{
    for (UIImageView *imageView in self.groundImages) {
        imageView.image = [UIImage imageNamed:[FBGameManager sharedInstance].rank];
    }
}

#pragma mark - Animations

- (void)bounceElement:(UIView *)element animationKey:(NSString *)key
{
    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scale.values = @[@1, @1.3, @1];
    scale.keyTimes = @[@0, @0.5, @1];
    scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    scale.duration = 0.15;
    scale.delegate = self;
    scale.removedOnCompletion = key ? NO : YES;
    [element.layer addAnimation:scale forKey:key];
}

- (void)crashAnimation
{
    CGPoint startPosition = self.view.layer.position;
    CGPoint rightPosition = CGPointMake(startPosition.x + 10, startPosition.y);
    CGPoint leftPosition = CGPointMake(startPosition.x - 10, startPosition.y);
    
    CAKeyframeAnimation *crash = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    crash.values = @[[NSValue valueWithCGPoint:startPosition], [NSValue valueWithCGPoint:rightPosition], [NSValue valueWithCGPoint:leftPosition], [NSValue valueWithCGPoint:startPosition]];
    crash.keyTimes = @[@0, @0.33, @0.66, @1];
    crash.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    crash.removedOnCompletion = YES;
    crash.duration = 0.2;
    
    [self.containerView.layer addAnimation:crash forKey:nil];
    
    UIView *flash = [[UIView alloc] initWithFrame:self.containerView.frame];
    flash.tag = 38;
    flash.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:flash];
    
    CAKeyframeAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacity.duration = 0.05;
    opacity.values = @[@0, @1, @0];
    opacity.keyTimes = @[@0, @0.5, @1];
    opacity.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    opacity.removedOnCompletion = NO;
    opacity.delegate = self;
    
    [flash.layer addAnimation:opacity forKey:@"flash"];
    
    CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
    CALayer *layer = (CALayer *)self.broView.layer.presentationLayer;
    position.fromValue = [NSValue valueWithCGPoint:layer.position];
    CGPoint bottomPosition = layer.position;
    bottomPosition.y = self.view.frame.size.height - FBBroSize.height / 2 - self.groundView.frame.size.height + 5;
    position.toValue = [NSValue valueWithCGPoint:bottomPosition];
    position.duration = ((self.view.frame.size.height - layer.position.y) * (FBCrashBroFallingHalfScreenMSeconds / (self.view.frame.size.height / 2))) / 60;;
    position.removedOnCompletion = YES;
    position.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    self.broView.layer.position = bottomPosition;
    
    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scale.duration = 0.2;
    scale.values = @[@1, @1.4, @1];
    scale.keyTimes = @[@0, @0.3, @1];
    scale.removedOnCompletion = YES;
    scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *animations = [[CAAnimationGroup alloc] init];
    animations.animations = @[position, scale];
    animations.duration = position.duration > scale.duration ? position.duration : scale.duration;
    animations.delegate = self;
    animations.removedOnCompletion = NO;
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotate.fromValue = [NSValue valueWithCATransform3D:self.broView.layer.transform];
    rotate.toValue = [NSValue valueWithCATransform3D:self.broCrashTransform];
    rotate.duration = FBKickBroDuration * 2;
    rotate.removedOnCompletion = YES;
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self.broView.layer addAnimation:rotate forKey:nil];
    self.broView.layer.transform = self.broCrashTransform;

    [self.broView.layer addAnimation:animations forKey:@"broCrashed"];
    
    CALayer *bonusLayer = self.bonusView.layer.presentationLayer;
    self.bonusView.layer.position = bonusLayer.position;
    [self.bonusView.layer removeAnimationForKey:@"bonus"];
}

- (void)startGroundAnimation
{
    UIImageView *firstImage = self.groundImages[0];
    UIImageView *secondImage = self.groundImages[1];
    UIImageView *thirtImage = self.groundImages[2];
    
    CGFloat FBGroundAnimationDuration = (FBStickLeftScreenDuration * firstImage.image.size.width) / (self.view.frame.size.width + FBStickWidth);
    
    CAKeyframeAnimation *firstImageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    firstImageAnimation.duration = FBGroundAnimationDuration;
    NSValue *firstStartValue = [NSValue valueWithCGPoint:firstImage.center];
    NSValue *firstEndValue = [NSValue valueWithCGPoint:CGPointMake(firstImage.center.x - firstImage.image.size.width, firstImage.center.y)];
    firstImageAnimation.values = @[firstStartValue, firstEndValue];
    firstImageAnimation.keyTimes = @[@0, @1];
    firstImageAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    firstImageAnimation.repeatCount = MAXFLOAT;
    [firstImage.layer addAnimation:firstImageAnimation forKey:nil];
    
    CAKeyframeAnimation *secondImageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    secondImageAnimation.duration = FBGroundAnimationDuration;
    NSValue *secondStartValue = [NSValue valueWithCGPoint:secondImage.center];
    NSValue *secondEndValue = [NSValue valueWithCGPoint:CGPointMake(secondImage.center.x - firstImage.image.size.width, secondImage.center.y)];
    secondImageAnimation.values = @[secondStartValue, secondEndValue];
    secondImageAnimation.keyTimes = @[@0, @1];
    secondImageAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    secondImageAnimation.repeatCount = MAXFLOAT;
    [secondImage.layer addAnimation:secondImageAnimation forKey:nil];
    
    CAKeyframeAnimation *thirtImageAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    thirtImageAnimation.duration = FBGroundAnimationDuration;
    NSValue *thirtStartValue = [NSValue valueWithCGPoint:thirtImage.center];
    NSValue *thirtEndValue = [NSValue valueWithCGPoint:CGPointMake(thirtImage.center.x - firstImage.image.size.width, thirtImage.center.y)];
    thirtImageAnimation.values = @[thirtStartValue, thirtEndValue];
    thirtImageAnimation.keyTimes = @[@0, @1];
    thirtImageAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    thirtImageAnimation.repeatCount = MAXFLOAT;
    [thirtImage.layer addAnimation:thirtImageAnimation forKey:nil];

}

#pragma mark - AnimationsDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.broView.layer animationForKey:@"kickBro"]) {
        [self.broView.layer removeAnimationForKey:@"kickBro"];
        [self broFalling];
    } else if (anim == [self.broView.layer animationForKey:@"broFalling"]) {
        [self crashAnimation];
        [self endGame];
    } else if (anim == [self.broView.layer animationForKey:@"broCrashed"]) {
        [self endGame];
    } else if (anim == [self.tryAgainButton.layer animationForKey:@"tryAgain"]) {
        [self.tryAgainButton.layer removeAllAnimations];
        self.endgameView.hidden = YES;
        [self readyToTheGame];
    } else if (anim == [self.endGameButton.layer animationForKey:@"endGame"]) {
        [self.broView.layer removeAllAnimations];
        [self.broView removeFromSuperview];
        [self.endGameButton.layer removeAllAnimations];
        [self.bonusView removeFromSuperview];
        self.bonusView = nil;
        self.endgameView.hidden = YES;
        self.menuView.hidden = NO;
        for (UIView *stick in self.sticks) {
            [stick removeFromSuperview];
        }
        [self.sticks removeAllObjects];
        self.gameScoreLabel.hidden = YES;
    } else if (anim == [self.playButton.layer animationForKey:@"Play"]) {
        [self.playButton.layer removeAllAnimations];
        [self readyToTheGame];
    }  else if (anim == [[self.containerView viewWithTag:38].layer animationForKey:@"flash"]) {
        UIView *flash = [self.containerView viewWithTag:38];
        [flash.layer removeAllAnimations];
        [flash removeFromSuperview];
    } else if (anim == [self.getReadyLabel.layer animationForKey:@"getReady"]) {
        [self.getReadyLabel.layer removeAllAnimations];
        [self configureViewForGame];
    } else if (anim == [self.carView.layer animationForKey:@"car"]) {
        [self.carView.layer removeAllAnimations];
        if (self.broView.layer.animationKeys.count) {
            [self startCarsAnimation];
        } else {
            [self.carView removeFromSuperview];
        }
    } else if (anim == [self.broView.layer animationForKey:@"goUp"]) {
        [self.broView.layer removeAnimationForKey:@"goUp"];
        [self goDownBro];
    }
}

#pragma mark - GameModel

- (void)kickBro:(UITapGestureRecognizer *)tapGesture
{
    [self.broView.layer removeAllAnimations];
    
    CALayer *layer = (CALayer *)self.broView.layer.presentationLayer;
    CGPoint topPosition = layer.position;
    self.broView.layer.transform = layer.transform;

    CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
    position.fromValue = [NSValue valueWithCGPoint:layer.position];
    topPosition.y -= FBKickBroDistance;
    if (topPosition.y < FBBroSize.height / 2) {
        topPosition.y = FBBroSize.height / 2;
    }
    position.toValue = [NSValue valueWithCGPoint:topPosition];
    position.duration = FBKickBroDuration;
    position.removedOnCompletion = NO;
    position.delegate = self;
    position.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotate.fromValue = [NSValue valueWithCATransform3D:layer.transform];
    rotate.toValue = [NSValue valueWithCATransform3D:self.broUpTransform];
    rotate.duration = FBKickBroDuration * 1.5;
    rotate.delegate = self;
    rotate.removedOnCompletion = NO;
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self.broView.layer addAnimation:position forKey:@"kickBro"];
    self.broView.layer.position = topPosition;
    
    [self.broView.layer addAnimation:rotate forKey:@"goUp"];
    self.broView.layer.transform = self.broUpTransform;
}

- (void)broFalling
{
    CALayer *layer;
    if (self.startGame) {
        layer = self.broView.layer;
        self.startGame = NO;
    } else {
        layer = (CALayer *)self.broView.layer.presentationLayer;
    }
    self.broView.layer.transform = layer.transform;
    CGPoint bottomPosition = layer.position;
    
    CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
    position.fromValue = [NSValue valueWithCGPoint:layer.position];
    bottomPosition.y = self.view.frame.size.height - FBBroSize.height / 2 - self.groundView.frame.size.height + 5;
    position.toValue = [NSValue valueWithCGPoint:bottomPosition];
    CGFloat duration = ((self.view.frame.size.height - layer.position.y) * (FBBroFallingHalfScreenMSeconds / (self.view.frame.size.height / 2))) / 60;
    duration *= self.gameDuration;
    position.duration = duration;
    position.removedOnCompletion = NO;
    position.delegate = self;
    position.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [self.broView.layer addAnimation:position forKey:@"broFalling"];
    self.broView.layer.position = bottomPosition;
    
}

- (void)goDownBro
{
    CALayer *layer = (CALayer *)self.broView.layer.presentationLayer;
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotate.fromValue = [NSValue valueWithCATransform3D:layer.transform];
    rotate.toValue = [NSValue valueWithCATransform3D:self.broDownTransform];
    rotate.duration = ((self.view.frame.size.height - layer.position.y) * (FBBroFallingHalfScreenMSeconds / (self.view.frame.size.height / 2))) / 60;
    rotate.removedOnCompletion = YES;
    rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [self.broView.layer addAnimation:rotate forKey:nil];
    self.broView.layer.transform = self.broDownTransform;
}

- (void)startCarsAnimation
{
    BOOL leftDirecion = NO;
    NSInteger yPosition = arc4random() % ((int)(self.groundView.frame.origin.y - self.carView.frame.size.height / 2) - (int)self.carView.frame.size.height / 2) + self.carView.frame.size.height / 2;
    if (arc4random() % 100 < 50) {
        leftDirecion = YES;
    } else {
        leftDirecion = NO;
    }
    CAKeyframeAnimation *position = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    position.duration = arc4random() % (10 - 4) + 4;
    NSValue *endValue;
    NSValue *startValue;
    if (leftDirecion) {
        endValue = [NSValue valueWithCGPoint:CGPointMake(-self.carView.frame.size.width, yPosition)];
        startValue = [NSValue valueWithCGPoint:CGPointMake(self.carView.frame.size.width + self.view.frame.size.width, yPosition)];
        self.carView.image = [UIImage imageNamed:@"policeCar"];
    } else {
        startValue = [NSValue valueWithCGPoint:CGPointMake(-self.carView.frame.size.width, yPosition)];
        endValue = [NSValue valueWithCGPoint:CGPointMake(self.carView.frame.size.width + self.view.frame.size.width, yPosition)];
        self.carView.image = [UIImage imageWithCGImage:[UIImage imageNamed:@"policeCar"].CGImage scale: [UIImage imageNamed:@"policeCar"].scale orientation:UIImageOrientationUpMirrored];
    }
    position.values = @[startValue, startValue, endValue];
    position.keyTimes = @[@0, @0.5, @1];
    position.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    position.delegate = self;
    position.removedOnCompletion = NO;
    [self.carView.layer addAnimation:position forKey:@"car"];
}

- (void)startSticksMoving
{
    self.sticks = [[NSMutableArray alloc] init];
    self.stickAppearanceTimer = [NSTimer scheduledTimerWithTimeInterval:(FBStickAppearanceTime * self.gameDuration) target:self selector:@selector(generateSticks:) userInfo:nil repeats:YES];
}

- (void)readyToTheGame
{
    self.menuView.hidden = YES;
    self.startGame = YES;
    self.tapGesture.enabled = YES;
    [self.bonusView removeFromSuperview];
    self.bonusView = nil;
    for (UIView *stick in self.sticks) {
        [stick removeFromSuperview];
    }
    [self.sticks removeAllObjects];
    
    [self createBro];
    
    switch ([FBGameManager sharedInstance].difficulty) {
        case FBGameDifficultyEasy:
            self.gameDuration = 1;
            break;
        case FBGameDifficultyMedium:
            self.gameDuration = 0.8;
            break;
        case FBGameDifficultyHard:
            self.gameDuration = 0.5;
            break;
    }
    if (!self.getReadyLabel) {
        self.resultScoreLabel.font = [UIFont fontWithName:@"BlackCoffeeShadow-Bold" size:40.0];
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:FBFontName size:30.0];
        label.textColor = [UIColor colorWithRed:(19.0/255.0) green:(37.0/255.0) blue:(78.0/255.0) alpha:1.0];
        label.text = @"Get ready";
        CGRect frame;
        frame.size = [label.text sizeWithAttributes:@{NSFontAttributeName : label.font}];
        frame.origin.y = -frame.size.height;
        frame.origin.x = self.view.frame.size.width / 2 - frame.size.width / 2;
        label.frame = frame;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
        label.layer.shadowOffset = CGSizeMake(-1.0f, 1.0f);
        label.layer.shadowOpacity = 1.0;
        label.layer.shadowRadius = 0.0;
        label.layer.shadowColor = [UIColor colorWithRed:(19.0/255.0) green:(37.0/255.0) blue:(78.0/255.0) alpha:1.0].CGColor;
        [self.containerView addSubview:label];
        self.getReadyLabel = label;
    }
    
    CAKeyframeAnimation *position = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    position.values = @[[NSValue valueWithCGPoint:self.getReadyLabel.center], [NSValue valueWithCGPoint:CGPointMake(self.getReadyLabel.center.x, self.containerView.center.y - 100)], [NSValue valueWithCGPoint:CGPointMake(self.getReadyLabel.center.x, self.containerView.center.y - 100)], [NSValue valueWithCGPoint:self.getReadyLabel.center]];
    position.keyTimes = @[@0, @0.4, @0.6, @1];
    position.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    position.duration = 1.0f;
    position.removedOnCompletion = NO;
    position.delegate = self;
    
    [self.getReadyLabel.layer addAnimation:position forKey:@"getReady"];
}

- (void)configureViewForGame
{
    if ([FBGameManager sharedInstance].enableSound) {
        [[FBSoundManager sharedInstance] playMusic:YES];
    }
    [self createViews];
    [self startSticksMoving];
    [self startGroundAnimation];
    [self startCarsAnimation];
    
    self.broGameTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(checkForLoose:) userInfo:nil repeats:YES];
    self.bonusAppearanceScore = 3; //arc4random() % (50 - 20) + 20;
    
    self.score = 0;
    self.gameScoreLabel.text = [NSString stringWithFormat:@"%i", (int)self.score];
    self.gameScoreLabel.hidden = NO;
    self.theNewRankLabel.hidden = YES;
}

- (void)createBro
{
    [self.broView removeFromSuperview];
    UIImageView *bro = [[UIImageView alloc] initWithFrame:CGRectMake(FBBroPositionX, self.view.center.y - (FBBroSize.height / 2), FBBroSize.width, FBBroSize.height)];
    bro.image = [UIImage imageNamed:@"Policeman"];
    bro.layer.cornerRadius = FBBroSize.width / 2;
    [self.containerView addSubview:bro];
    self.broView = bro;
    self.broView.layer.transform = self.broUpTransform;
    self.broView.layer.shadowOffset = CGSizeMake(2.0f, -2.0f);
    self.broView.layer.shadowOpacity = 0.8f;
    
    [self.broView layoutIfNeeded];
}

- (void)endGame
{
    [self.broView.layer removeAllAnimations];
    [self.stickAppearanceTimer invalidate];
    [self.broGameTimer invalidate];
    [self.broView.layer removeAllAnimations];
    for (UIView *stick in self.sticks) {
        CALayer *layer = stick.layer.presentationLayer;
        stick.layer.position = layer.position;
        [stick.layer removeAllAnimations];
    }
    
    for (UIImageView *imageView in self.groundImages) {
        [imageView.layer removeAllAnimations];
    }
    
    [[FBSoundManager sharedInstance] playMusic:NO];
    self.tapGesture.enabled = NO;
#warning -  add endGameMenu appearance animation
    self.endgameView.hidden = NO;
    self.resultScoreLabel.text = [NSString stringWithFormat:@"%i", (int)self.score];
    self.gameScoreLabel.hidden = YES;
    
    NSString *oldRank = [FBGameManager sharedInstance].rank;
    NSInteger oldHighScore = [FBGameManager sharedInstance].highScore;
    [FBGameManager sharedInstance].highScore = self.score;
    if (oldHighScore < [FBGameManager sharedInstance].highScore) {
        self.theNewHighScoreLabel.text = @"New high score";
    } else {
        self.theNewHighScoreLabel.text = [NSString stringWithFormat:@"High score %i", (int)[FBGameManager sharedInstance].highScore];
    }
    if (![oldRank isEqualToString:[FBGameManager sharedInstance].rank]) {
        [self setRankImages];
        self.theNewRankLabel.text = [NSString stringWithFormat:@"You become \na %@", [FBGameManager sharedInstance].rank];
        self.theNewRankLabel.hidden = NO;
    }
}

- (void)checkForLoose:(NSTimer *)timer
{
    CALayer *broLayer = self.broView.layer.presentationLayer;
    CGRect broFrame = broLayer.bounds;
    broFrame.origin.x = broLayer.position.x - FBBroSize.width / 2;
    broFrame.origin.y = broLayer.position.y - FBBroSize.height / 2;
    
    for (UIView *stick in self.sticks) {
        CALayer *layer = stick.layer.presentationLayer;
        CGRect stickFrame = layer.bounds;
        stickFrame.origin.x = layer.position.x - stick.bounds.size.width / 2;
        stickFrame.origin.y = layer.position.y - stick.bounds.size.height / 2;
        
        if (stick.tag != 99 && (broLayer.position.x >= layer.position.x) && (broLayer.position.x <= layer.position.x + 5)) {
            if (stick.tag == 77) {
                CALayer *layer = self.bonusView.layer.presentationLayer;
                CGRect bonusFrame = layer.bounds;
                bonusFrame.origin.x = layer.position.x - self.bonusView.bounds.size.width / 2;
                bonusFrame.origin.y = layer.position.y - self.bonusView.bounds.size.height / 2;
                if (CGRectIntersectsRect(broFrame, bonusFrame) && ! self.isBonus) {
                    self.broView.layer.shadowColor = [UIColor yellowColor].CGColor;
                    self.isBonus = YES;
                    [self.bonusView.layer removeAllAnimations];
                    [self.bonusView removeFromSuperview];
                    self.bonusView = nil;
                    [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(endBonusTime:) userInfo:nil repeats:NO];
                }
                self.score++;
                if (self.isBonus) {
                    self.score++;
                }
                self.gameScoreLabel.text = [NSString stringWithFormat:@"%i", (int)self.score];
                stick.tag = 99;
            }
        }
        
        if (CGRectIntersectsRect(broFrame, stickFrame)) {
            [self.stickAppearanceTimer invalidate];
            [self.broGameTimer invalidate];
            self.tapGesture.enabled = NO;
            [self.broView.layer removeAllAnimations];
            
            for (UIView *stick in self.sticks) {
                CALayer *layer = stick.layer.presentationLayer;
                stick.layer.position = layer.position;
                [stick.layer removeAllAnimations];
            }
            
            [self crashAnimation];
            return;
        }
    }
}

- (void)generateSticks:(NSTimer *)timer
{
    if (!self.broView.layer.animationKeys) {
        [self broFalling];
    }
    CGFloat topStickHeight = arc4random() % (((int)self.view.frame.size.height / 5) * 3 - 50) + 50;
    CGRect topStickFrame = CGRectMake(self.view.frame.size.width, 0, FBStickWidth, topStickHeight);
    CGRect bottomStickFrame = topStickFrame;
    bottomStickFrame.origin.y = topStickFrame.size.height + FBDistanceBetweenSticks;
    bottomStickFrame.size.height = self.view.frame.size.height - bottomStickFrame.origin.y - self.groundView.frame.size.height;
    
    UIImageView *topStick = [[UIImageView alloc] initWithFrame:topStickFrame];
    topStick.image = [UIImage imageNamed:@"topStick"];
    topStick.contentMode = UIViewContentModeBottom;
    topStick.tag = 77;
    [self.containerView insertSubview:topStick belowSubview:self.endgameView];
    
    UIImageView *bottomStick = [[UIImageView alloc] initWithFrame:bottomStickFrame];
    bottomStick.image = [UIImage imageNamed:@"bottomStick"];
    bottomStick.contentMode = UIViewContentModeTop;
    [self.containerView insertSubview:bottomStick belowSubview:self.endgameView];
    
    CGPoint endPoint = topStick.center;
    endPoint.x -= self.view.frame.size.width + FBStickWidth;
    
    CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
    position.fromValue = [NSValue valueWithCGPoint:topStick.center];
    position.toValue = [NSValue valueWithCGPoint:endPoint];
    position.duration = FBStickLeftScreenDuration * self.gameDuration;
    position.removedOnCompletion = YES;
    [topStick.layer addAnimation:position forKey:@"moveStick"];
    topStick.layer.position = endPoint;
    
    endPoint = bottomStick.center;
    endPoint.x -= self.view.frame.size.width + FBStickWidth;
    
    CABasicAnimation *bottomPosition = [CABasicAnimation animationWithKeyPath:@"position"];
    bottomPosition.fromValue = [NSValue valueWithCGPoint:bottomStick.center];
    bottomPosition.toValue = [NSValue valueWithCGPoint:endPoint];
    bottomPosition.duration = FBStickLeftScreenDuration * self.gameDuration;
    bottomPosition.removedOnCompletion = YES;
    
    [bottomStick.layer addAnimation:bottomPosition forKey:@"moveStick"];
    bottomStick.layer.position = endPoint;
    
    CAKeyframeAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacity.values = @[@1, @1, @0];
    opacity.keyTimes = @[@0, @0.8, @1];
    opacity.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    opacity.duration = position.duration;
    opacity.removedOnCompletion = YES;
    
    [topStick.layer addAnimation:opacity forKey:nil];
    [bottomStick.layer addAnimation:opacity forKey:nil];
    
    [self.sticks addObject:topStick];
    [self.sticks addObject:bottomStick];
    
    NSMutableArray *newSticksArray = [[NSMutableArray alloc] init];
    for (UIView *stick in self.sticks) {
        if (!stick.layer.animationKeys) {
            [stick removeFromSuperview];
        } else {
            [newSticksArray addObject:stick];
        }
    }
    self.sticks = newSticksArray;
    
    if (self.score == self.bonusAppearanceScore) {
        self.bonusAppearanceScore += self.bonusAppearanceScore;
        UIImageView *bonus = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star"]];
        bonus.frame = CGRectMake(topStickFrame.origin.x, bottomStickFrame.origin.y - 85, 50, 50);
        [self.containerView insertSubview:bonus belowSubview:self.broView];
        self.bonusView = bonus;
        bonus.layer.zPosition = -320;
        CABasicAnimation *bonusPosition = [CABasicAnimation animationWithKeyPath:@"position"];
        bonusPosition.fromValue = [NSValue valueWithCGPoint:bonus.center];
        endPoint = bonus.center;
        endPoint.x -=self.view.frame.size.width + 50;
        bonusPosition.toValue = [NSValue valueWithCGPoint:endPoint];
        bonusPosition.duration = FBStickLeftScreenDuration * self.gameDuration;
        bonusPosition.removedOnCompletion = YES;
        [bonus.layer addAnimation:bonusPosition forKey:@"bonus"];
        bonus.layer.position = endPoint;
        
        CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform"];
        rotate.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 1, 0)];
        rotate.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(2 * M_PI, 0, 1, 0)];
        rotate.duration = 1.5f;
        rotate.repeatCount = MAXFLOAT;
        rotate.removedOnCompletion = YES;
        rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [bonus.layer addAnimation:rotate forKey:nil];
    }
}

- (void)endBonusTime:(NSTimer *)timer
{
    [timer invalidate];
    self.broView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.isBonus = NO;
}

#pragma mark - UIActions

- (IBAction)playAction:(id)sender
{
    [self bounceElement:self.playButton animationKey:@"Play"];
}

- (IBAction)soundOnOff:(id)sender
{
    [FBGameManager sharedInstance].enableSound = ![FBGameManager sharedInstance].enableSound;
    UIImage *soundImage = [UIImage imageNamed:[FBGameManager sharedInstance].enableSound ? @"Sound on" : @"Sound off"];
    [self.soundButton setImage:soundImage forState:UIControlStateNormal];
    
    [self bounceElement:self.soundButton animationKey:nil];
}

- (IBAction)tryAgainAction:(id)sender
{
    if (self.tryAgainButton.layer.animationKeys.count || self.endGameButton.layer.animationKeys.count) {
        return; //disable doubleTap
    }
    [self bounceElement:self.tryAgainButton animationKey:@"tryAgain"];
}

- (IBAction)endGameAction:(id)sender
{
    if (self.tryAgainButton.layer.animationKeys.count || self.endGameButton.layer.animationKeys.count) {
        return; //disable doubleTap
    }
    [self.carView removeFromSuperview];
    [self bounceElement:self.endGameButton animationKey:@"endGame"];
}

@end
