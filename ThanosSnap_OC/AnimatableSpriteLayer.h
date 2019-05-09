//
//  AnimatableSpriteLayer.h
//  ThanosSnap_OC
//
//  Created by DR_Kun on 2019/5/6.
//  Copyright © 2019 DR_Kun. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>


@interface AnimatableSpriteLayer : CALayer

- (instancetype)initWithSpriteSheetImage:(UIImage *)image spriteFrameSize:(CGSize)size;

- (void)play;


@end
