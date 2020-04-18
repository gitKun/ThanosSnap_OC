//
//  ViewController.m
//  ThanosSnap_OC
//
//  Created by DR_Kun on 2019/5/6.
//  Copyright © 2019 DR_Kun. All rights reserved.
//

#import "ViewController.h"
#import "ThanosGauntlet.h"
#import "DustEffectView.h"
#import "UIView+ThanosSnap.h"


@interface CellModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *imageName;



@end


@implementation CellModel

//- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
//}
- (void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key{
}

@end



@interface ViewController ()<ThanosGauntletDelegate,DustEffectViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) BOOL playing;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DustEffectView *dustView;
@property (nonatomic, strong) UIImageView *testImageView;
@property (nonatomic, copy) NSArray *searchResult;

@property (nonatomic, strong) UITableViewCell *hiddenCell;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    ThanosGauntlet *gauntlet = [[ThanosGauntlet alloc] initWithFrame:CGRectZero];
    gauntlet.delegate = self;
    [self.view addSubview:gauntlet];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.dataSource = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    
    self.dustView = [[DustEffectView alloc] initWithFrame:CGRectZero];
    self.dustView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dustView.delegate = self;
    [self.tableView addSubview:self.dustView];
    
    UILayoutGuide *margin = self.view.layoutMarginsGuide;
    NSArray<NSLayoutConstraint *> *activites\
    = @[
        [self.tableView.centerXAnchor constraintEqualToAnchor:margin.centerXAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:margin.topAnchor],
        [self.tableView.widthAnchor constraintEqualToAnchor:margin.widthAnchor],
        [self.tableView.heightAnchor constraintEqualToConstant:420],
        [gauntlet.widthAnchor constraintEqualToConstant:80],
        [gauntlet.heightAnchor constraintEqualToConstant:80],
        [gauntlet.centerXAnchor constraintEqualToAnchor:margin.centerXAnchor],
        [gauntlet.topAnchor constraintEqualToAnchor:self.tableView.bottomAnchor]
        ];
    [NSLayoutConstraint activateConstraints:activites];
}

#pragma mark === Action

- (void)turnCellsToDust {
    if (self.hiddenCell) {
        self.dustView.frame = self.hiddenCell.frame;
        [self.dustView refreshImage:[self.hiddenCell renderToImage]];
        self.hiddenCell.hidden = YES;
    }
}


#pragma marl === Delegate

#pragma mark ==- ThanosGauntletDelegate

- (void)thanosGauntletDidReversed {
    if (self.hiddenCell) {
        self.hiddenCell.textLabel.textColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.13 alpha:1.0];
        self.hiddenCell.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.13 alpha:1.0];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hiddenCell.hidden = NO;
        [UIView transitionWithView:self.hiddenCell.textLabel duration:2.0 options:(UIViewAnimationOptionTransitionCrossDissolve) animations:^{
            self.hiddenCell.textLabel.textColor = UIColor.redColor;
        } completion:nil];
        [UIView transitionWithView:self.hiddenCell.detailTextLabel duration:2.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.hiddenCell.detailTextLabel.textColor = [UIColor blackColor];
        } completion:nil];
    });
}

- (void)thanosGauntletDidSnapped {
    self.hiddenCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(arc4random() % self.searchResult.count) inSection:0]];
//    self.hiddenCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [self turnCellsToDust];
}

#pragma mark ==- DustEffectViewDelegate

- (void)dustEffectViewDidCompleted {
    
    
}

#pragma mark ==- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCellID"];
    }
    CellModel *model = self.searchResult[indexPath.row];
    cell.textLabel.text = model.title;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor blueColor];
    cell.detailTextLabel.text = model.content;
    cell.detailTextLabel.numberOfLines = 0;
    cell.imageView.image = [UIImage imageNamed:model.imageName];
    
    return cell;
}


#pragma mark === Lazy load

- (NSArray *)searchResult {
    if (!_searchResult) {
        self.searchResult = self.testSearchResult;
    }
    return _searchResult;
}


#pragma mark === data

- (NSArray<CellModel *> *)testSearchResult {
    NSArray *data = @[
             @{@"title":@"灭霸_百度百科",
               @"content":@"灭霸（Thanos，音译为萨诺斯）是美国漫威漫画旗下的超级反派，初次登场于《钢铁侠》（Iron Man）第55期（1973年1月）。是出生在土星卫星泰坦上的永恒一族，实力极其 ...",
               @"imageName":@"baidu"
               },
//             @{@"title":@"灭霸- 维基百科，自由的百科全书 - Wikipedia",
//               @"content":@"萨诺斯（英语：Thanos），美国漫威漫画创造的虚拟漫画角色，是一个超级反派。由漫画家吉姆·史达林所创造，首次登场于《钢铁人》（Iron Man）#55（1973年二月）。",
//               @"imageName":@"wikipedia"
//               },
//             @{@"title":@"在 iOS 中实现谷歌灭霸彩蛋 - 掘金",
//               @"content":@"最近上映的复仇者联盟4据说没有片尾彩蛋，不过谷歌帮我们做了。只要在谷歌搜索灭霸，在结果的右侧点击无限手套，你将化身为灭霸，其中一半的搜索结果会化为灰烬消失...",
//               @"imageName":@"juejin"
//               },
//             @{@"title":@"全网最全灭霸资料！ - 知乎",
//               @"content":@"孤独中才见真挚苦难中才见真诚死亡中才见真相——灭霸《复仇者联盟3》大陆定档于5月11日，和全球首映时间相比晚了近半个月。这是漫威电影在内地首次因“翻译”...",
//               @"imageName":@"google"
//               }
             ];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:data.count];
    for (NSDictionary *dict in data) {
        CellModel *model = [[CellModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [result addObject:model];
    }
    return result;
}


@end
