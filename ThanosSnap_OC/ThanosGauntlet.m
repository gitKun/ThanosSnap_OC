//
//  ThanosGauntlet.m
//  ThanosSnap_OC
//
//  Created by DR_Kun on 2019/5/7.
//  Copyright © 2019 DR_Kun. All rights reserved.
//

#import "ThanosGauntlet.h"
#import "AnimatableSpriteLayer.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, ThanosGauntletAction) {
    ThanosGauntletActionSnap,
    ThanosGauntletActionReverse,
};


@interface ThanosGauntlet ()

@property (nonatomic, strong) AnimatableSpriteLayer *snapLayer;
@property (nonatomic, strong) AnimatableSpriteLayer *reverseLayer;
@property (nonatomic, strong) AVAudioPlayer *snapSoundPlayer;
@property (nonatomic, strong) AVAudioPlayer *reverseSoundPlayer;
@property (nonatomic, assign) ThanosGauntletAction action;


@end



@implementation ThanosGauntlet

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setupViews];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setupViews];
    return self;
}

- (void)layoutSubviews {
    CGPoint point =  CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.snapLayer.position = point;
    self.reverseLayer.position = point;
}

- (void)setupViews {
    self.action = ThanosGauntletActionSnap;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.layer addSublayer:self.snapLayer];
    self.reverseLayer.hidden = YES;
    [self.layer addSublayer:self.reverseLayer];
}

#pragma mark === Actions

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    switch (self.action) {
        case ThanosGauntletActionSnap: {
            [self begainSnapAction:YES];
        }
            break;
        case ThanosGauntletActionReverse: {
            [self begainSnapAction:NO];
        }
        default:
            break;
    }
}

- (void)begainSnapAction:(BOOL)snap {
    AnimatableSpriteLayer *showLayer = snap ? self.snapLayer : self.reverseLayer;
    AVAudioPlayer *play = snap ? self.snapSoundPlayer : self.reverseSoundPlayer;
    AnimatableSpriteLayer *hiddenLayer = !snap ? self.snapLayer : self.reverseLayer;
    AVAudioPlayer *stop = !snap ? self.snapSoundPlayer : self.reverseSoundPlayer;
    showLayer.hidden = NO;
    hiddenLayer.hidden = YES;
    [showLayer play];
    [stop stop];
    [stop setCurrentTime:0];
    [play play];
    self.action = snap ? ThanosGauntletActionReverse : ThanosGauntletActionSnap;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate) {
            snap ? [self.delegate thanosGauntletDidSnapped] : [self.delegate thanosGauntletDidReversed];
        }
    });
}



#pragma mark === Lazy load

- (AnimatableSpriteLayer *)snapLayer {
    if (!_snapLayer) {
        self.snapLayer = [[AnimatableSpriteLayer alloc] initWithSpriteSheetImage:[UIImage imageNamed:@"thanos_snap"] spriteFrameSize:CGSizeMake(80, 80)];
    }
    return _snapLayer;
}

- (AVAudioPlayer *)snapSoundPlayer {
    if (!_snapSoundPlayer) {
        self.snapSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"thanos_snap_sound" ofType:@"mp3"]] error:nil];
    }
    return _snapSoundPlayer;
}

- (AnimatableSpriteLayer *)reverseLayer {
    if (!_reverseLayer) {
        self.reverseLayer = [[AnimatableSpriteLayer alloc] initWithSpriteSheetImage:[UIImage imageNamed:@"thanos_time"] spriteFrameSize:CGSizeMake(80, 80)];
    }
    return _reverseLayer;
}

- (AVAudioPlayer *)reverseSoundPlayer {
    if (!_reverseSoundPlayer) {
        self.reverseSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"thanos_reverse_sound" ofType:@"mp3"]] error:nil];
    }
    return _reverseSoundPlayer;
}


@end
