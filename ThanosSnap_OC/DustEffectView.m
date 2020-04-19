//
//  DustEffectView.m
//  ThanosSnap_OC
//
//  Created by DR_Kun on 2019/5/7.
//  Copyright © 2019 DR_Kun. All rights reserved.
//

#import "DustEffectView.h"
#import <AVFoundation/AVFoundation.h>


#define Mask8(x) ( (x) & 0xFF )
#define ARGBMake(a, r,g, b) ( Mask8(a) | Mask8(r) << 8 | Mask8(g) << 16 | Mask8(b) << 24 )


@interface DustEffectView ()<CAAnimationDelegate>

@property (nonatomic, strong) AVAudioPlayer *soundPlayer;

@end


@implementation DustEffectView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        [self removeAllSublayers];
        [self.delegate dustEffectViewDidCompleted];
    }
}

- (void)removeAllSublayers {
    NSArray *subs = [[self.layer sublayers] mutableCopy];
    for (CALayer *layer in subs) {
        [layer removeFromSuperlayer];
    }
}

- (void)refreshImage:(UIImage *)image {
    if (image) {
        NSArray *animImages = [self createDustImages:image];
        NSInteger i = 0;
        NSInteger imagesCount = animImages.count;
        if (!imagesCount) {
            return;
        }
        for (UIImage *image in animImages) {
            @autoreleasepool {
                CALayer *layer = [CALayer layer];
                layer.frame = self.bounds;
                layer.contents = (__bridge id)(image.CGImage);
                [self.layer addSublayer:layer];
                
                CGFloat centerX = layer.position.x;
                CGFloat centerY = layer.position.y;
                
                CGFloat radian1 = M_PI / 12 * [self randomFloatForLow:-0.5 hight:0.5];
                CGFloat radian2 = M_PI / 12 * [self randomFloatForLow:-0.5 hight:0.5];
                
                CGFloat random = M_PI * 2 * [self randomFloatForLow:-0.5 hight:0.5];
                CGFloat transX = 30 * cos(random);
                CGFloat transY = 15 * sin(random);
                
                CGFloat realTransX = transX * cos(radian1) - transY * sin(radian1);
                CGFloat realTransY = transY * cos(radian1) + transX * sin(radian1);
                CGPoint realEndPoint = CGPointMake(centerX + realTransX, centerY + realTransY);
                CGPoint controlPoint = CGPointMake(centerX + transX, centerY + transY);
                
                UIBezierPath *movePath = [UIBezierPath bezierPath];
                [movePath moveToPoint:layer.position];
                [movePath addQuadCurveToPoint:realEndPoint controlPoint:controlPoint];
                
                #if 1
                CAKeyframeAnimation *moveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
                moveAnimation.path = movePath.CGPath;
                moveAnimation.calculationMode = kCAAnimationPaced;
                #endif
                
                
                CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
                rotateAnimation.toValue = @(radian1 + radian2);
                
                #if 1
                CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                fadeOutAnimation.toValue = @(0.0);
                #endif
                CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
                animationGroup.animations = @[moveAnimation, rotateAnimation, fadeOutAnimation];
                animationGroup.duration = 2.0;
                animationGroup.beginTime = CACurrentMediaTime() + 1.35 * i / imagesCount;
                animationGroup.removedOnCompletion = NO;
                animationGroup.fillMode = kCAFillModeForwards;
                
                if (i == imagesCount - 1) {
                    animationGroup.delegate = self;
                }
                [layer addAnimation:animationGroup forKey:nil];
                i++;
            }
        }
        self.soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"thanos_dust_1" ofType:@"mp3"]] error:nil];
        if (self.soundPlayer) {
            [self.soundPlayer prepareToPlay];
            [self.soundPlayer play];
        }
    }
}

#pragma mark === private

#warning 内存
/*
 1. 使用 C 的指针操作注意内存泄露等
 2. 循环中大量的临时变量内存泄露和内存吃紧
 */


- (NSArray <UIImage *>*)createDustImages:(UIImage *)image {
    // 这里应该注意 iOS 动画是在系统统一的线程中不属于你app管理此线程,所以 imageCount 不应该过大 ??
    NSInteger imagesCount = 32;
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:imagesCount];
    CGImageRef inputeCGImage = image.CGImage;
    if (!inputeCGImage) {
        return result;
    }
    // 创建一个RGB模式的颜色空间CGColorSpace和一个容器CGBitmapContext,将像素指针参数传递到容器中缓存进行存储。
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t width = CGImageGetWidth(inputeCGImage);
    size_t height = CGImageGetHeight(inputeCGImage);
    // 由于你使用的是 32 位 RGB 颜色空间模式，
    // 你需要定义一些参数 bytesPerPixel（每像素大小）和 bitsPerComponent（每个颜色通道大小），
    // 然后计算图像bytesPerRow（每行有大）。
    int bytesPerPixel = 4;
    int bitsPerComponent = 8;
    size_t bytesPerRow = bytesPerPixel * width;
    uint32_t bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little;
    // 创建上下文,kCGImageAlphaPremultipliedLast表示像素点的排序是ARGB
    CGContextRef context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    if (!context) {
        CGColorSpaceRelease(colorSpace);
        return result;
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), inputeCGImage);
    Byte *buffer = CGBitmapContextGetData(context);
    if (buffer == NULL) {
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        return result;
    }
    
    // 使用一个数组来存储像素的值
    UInt32* pixelBuffer = (UInt32 *)calloc(width * height, sizeof(UInt32));
    // 简单的 memcpy 并不能将 Byte* 转为 UInt32* (颜色空间ARGB)
    // memcpy(pixelBuffer, buffer, width * height);
    for (NSInteger i = 0; i < width * height; i++) {
        @autoreleasepool {
            UInt8 a = buffer[4 * i];
            UInt8 r = buffer[4 * i + 1];
            UInt8 g = buffer[4 * i + 2];
            UInt8 b = buffer[4 * i + 3];
            UInt32 *tmpPixel = pixelBuffer + i;
            *tmpPixel = ARGBMake(a, r, g, b);
        }
    }
    
    // 存储每张图片像素数组的数组
    UInt32* framePixels[imagesCount];
    for (NSInteger i = 0; i < imagesCount; i++) {
        UInt32 *tmp = (UInt32 *)calloc(width * height, sizeof(UInt32));
        framePixels[i] = tmp;
    }
    
    CFAbsoluteTime refTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"循环开始: start time 0.000000");
    for (NSInteger column = 0; column < width; column++) {
        for (NSInteger row = 0; row < height; row++) {
            NSInteger offset = row * width + column;
            // 事实证明 2 次 要比 1 次所展示的动画效果更好 !!
            for (NSInteger i = 0; i < 2; i++) {
                @autoreleasepool {
                    // 可以直接将 pixelBuffer 看做数组的指针进行数组取值，也可以进行指针偏移
                    // (UInt32 *currentPixelPoint = pixelBuffer + offset)
                    // 然后 *currentPixelPoint 取到 ARGB 的值
                    UInt32 currentPixel = pixelBuffer[offset];
                    //CGFloat random = (arc4random() * 1.0) / UINT32_MAX;
                    CGFloat random = [self randomFloatForLow:0 hight:1];
                    CGFloat temp = random + 2 * (column * 1.0 / width);
                    printf("%.2f \n", temp);
                    NSInteger index = floor(imagesCount * (temp / 3));
                    UInt32 *tmp = framePixels[index];
                    tmp[offset] = currentPixel;
                }
            }
        }
    }
    NSLog(@"循环结束: after busy %f", CFAbsoluteTimeGetCurrent() - refTime);
    free(pixelBuffer);
    for (NSInteger i = 0; i < imagesCount; i++) {
        @autoreleasepool {
            UInt32 *data = framePixels[i];
            CGContextRef ctxf = CGBitmapContextCreate(data, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
            if (!ctxf) {
                continue;
            }
            CGImageRef restultCGImage = CGBitmapContextCreateImage(ctxf);
            // 这个生成Image的方法不会失败 所以判断可以去掉 ??
            UIImage *resultImage = [UIImage imageWithCGImage:restultCGImage scale:image.scale orientation:image.imageOrientation];
            if (image) {
                [result addObject:resultImage];
            }
            CGImageRelease(restultCGImage);
            CGContextRelease(ctxf);
            free(data);
        }
    }
    // 内存释放
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return result;
}

#pragma mark === tools

- (CGFloat)randomFloatForLow:(CGFloat)low hight:(CGFloat)hight {
    CGFloat random = (arc4random() % 100) / 100.0;
    CGFloat lowResult = low + (hight - low) * random;
    return lowResult;
}

- (NSInteger)randomIntegerForLow:(NSInteger)low hight:(NSInteger)hight {
    NSInteger difference = hight - low;
    return low + arc4random() % difference;
}

@end
