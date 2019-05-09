//
//  DustEffectView.h
//  ThanosSnap_OC
//
//  Created by DR_Kun on 2019/5/7.
//  Copyright © 2019 DR_Kun. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DustEffectViewDelegate <NSObject>

- (void)dustEffectViewDidCompleted;

@end

@interface DustEffectView : UIView

- (void)refreshImage:(UIImage *)image;

@property (nonatomic, weak) id<DustEffectViewDelegate> delegate;


@end
