//
//  ViewController.m
//  TTTT
//
//  Created by DR_Kun on 2019/5/7.
//  Copyright © 2019 DR_Kun. All rights reserved.
//

#import "ViewController.h"
#import "DustEffectView.h"

@interface ViewController ()<DustEffectViewDelegate>

@property (nonatomic, strong) DustEffectView *dustView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.dustView = [[DustEffectView alloc] initWithFrame:CGRectZero];
    self.dustView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dustView.delegate = self;
    [self.view addSubview:_dustView];
    NSArray<NSLayoutConstraint *> *activites\
     = @[
        [self.dustView.centerXAnchor constraintEqualToAnchor:self.imageView.centerXAnchor],
        [self.dustView.topAnchor constraintEqualToAnchor:self.imageView.bottomAnchor constant:25],
        [self.dustView.widthAnchor constraintEqualToAnchor:self.imageView.widthAnchor],
        [self.dustView.heightAnchor constraintEqualToAnchor:self.imageView.heightAnchor]
        ];
    [NSLayoutConstraint activateConstraints:activites];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.dustView refreshImage:[UIImage imageNamed:@"4"]];
}


- (void)dustEffectViewDidCompleted {
    
}


@end
