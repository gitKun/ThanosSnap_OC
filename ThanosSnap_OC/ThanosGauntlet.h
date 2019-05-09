//
//  ThanosGauntlet.h
//  ThanosSnap_OC
//
//  Created by DR_Kun on 2019/5/7.
//  Copyright © 2019 DR_Kun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ThanosGauntletDelegate <NSObject>

@required
- (void)thanosGauntletDidSnapped;

- (void)thanosGauntletDidReversed;

@end


@interface ThanosGauntlet : UIControl

@property (nonatomic, weak) id<ThanosGauntletDelegate> delegate;

@end

