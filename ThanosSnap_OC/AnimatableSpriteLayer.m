//
//  AnimatableSpriteLayer.m
//  ThanosSnap_OC
//
//  Created by DR_Kun on 2019/5/6.
//  Copyright © 2019 DR_Kun. All rights reserved.
//

#import "AnimatableSpriteLayer.h"

@interface AnimatableSpriteLayer ()

@property (nonatomic, strong) NSMutableArray<NSNumber *> *animationValues;

@end



@implementation AnimatableSpriteLayer

- (instancetype)initWithSpriteSheetImage:(UIImage *)image spriteFrameSize:(CGSize)size {
    self = [super init];
    if (self) {
        self.masksToBounds = YES;
        self.contentsGravity = kCAGravityLeft;
        self.contents = (__bridge id)image.CGImage;
        CGRect bounds = self.bounds;
        bounds.size = size;
        self.bounds = bounds;
        // 设置间隔
        NSInteger count = (NSInteger)(image.size.width / size.width);
        self.animationValues = [[NSMutableArray alloc] initWithCapacity:count];
        for (NSInteger i = 0; i < count; i++) {
            [self.animationValues addObject:@(i * 1.0 / count)];
        }
    }
    return self;
}

- (void)play {
    CAKeyframeAnimation *spriteKeyframAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contentsRect.origin.x"];
    spriteKeyframAnimation.values = _animationValues;
    spriteKeyframAnimation.duration = 2.0;
    spriteKeyframAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    spriteKeyframAnimation.calculationMode = kCAAnimationDiscrete;
    [self addAnimation:spriteKeyframAnimation forKey:nil];
}


@end
