//
//  UIView+ThanosSnap.m
//  ThanosSnap_OC
//
//  Created by DR_Kun on 2019/5/8.
//  Copyright © 2019 DR_Kun. All rights reserved.
//

#import "UIView+ThanosSnap.h"

@implementation UIView (ThanosSnap)

- (nullable UIImage *)renderToImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context) {
        [self.layer renderInContext:context];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    UIGraphicsEndImageContext();
    return nil;
}

@end
