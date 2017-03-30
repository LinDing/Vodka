//
//  DiscoverViewController.m
//  Vodka
//
//  Created by dinglin on 2017/3/24.
//  Copyright © 2017年 dinglin. All rights reserved.
//
#import "DLRSSCategoriesViewController.h"
#import <Masonry.h>
#import "DLCategoryInfoCell.h"
#import "DLRSSCategory.h"
#import <XMNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MJRefresh.h>

#import "DLRSSSubscribeViewController.h"
#import "DLFeedEditViewController.h"

static NSString *const kDLCategoryInfoCell = @"DLCategoryInfoCell";

@interface DLRSSCategoriesViewController () <UITableViewDelegate, UITableViewDataSource>

//分类列表
@property (nonatomic) UITableView *RSSCategoryListView;
@property (nonatomic) NSMutableArray <DLRSSCategory *>*RSSCategoryList;

@end

@implementation DLRSSCategoriesViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        
        
        NSLog(@"DiscoverViewController init");
        
    }
    
    return self;
}

-(void)dealloc {
    NSLog(@"DiscoverViewController dealloc");
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //导航栏
    self.navigationItem.title = NSLocalizedString(@"Discover", comment: "");
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 24, 24);
    [rightBtn setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItems = @[rightBarBtn];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.RSSCategoryListView];
    
    [self.RSSCategoryListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.centerX.equalTo(self.view);
    }];
    
    
    self.RSSCategoryListView.backgroundColor = [UIColor whiteColor];
    self.RSSCategoryListView.dataSource = self;
    self.RSSCategoryListView.delegate = self;
    
    self.RSSCategoryListView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //请求RSS的种类
        [XMCenter sendRequest:^(XMRequest *request) {
            request.api = @"classes/DLRSSCategory";
            request.parameters = @{};
            request.headers = @{};
            request.httpMethod = kXMHTTPMethodGET;
            request.requestSerializerType = kXMRequestSerializerJSON;
        } onSuccess:^(id responseObject) {
            
            [self.RSSCategoryListView.mj_header endRefreshing];

            NSError *error;
            self.RSSCategoryList = [[DLRSSCategory arrayOfModelsFromDictionaries:responseObject[@"results"] error:&error] mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.RSSCategoryListView reloadData];
            });
            
        } onFailure:^(NSError *error) {
            NSLog(@"onFailure: %@", error);
        } onFinished:^(id responseObject, NSError *error) {
            NSLog(@"onFinished");
        }];
        
    }];
    
    [self.RSSCategoryListView.mj_header beginRefreshing];
    
}

-(UITableView *)RSSCategoryListView {
    if (!_RSSCategoryListView) {
        _RSSCategoryListView = [[UITableView alloc] initWithFrame:CGRectZero];
        _RSSCategoryListView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_RSSCategoryListView registerClass:[DLCategoryInfoCell class] forCellReuseIdentifier:kDLCategoryInfoCell];
        
    }
    
    
    return _RSSCategoryListView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.RSSCategoryList.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    DLRSSCategory *RSSCategory = self.RSSCategoryList[row];

    DLCategoryInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kDLCategoryInfoCell forIndexPath:indexPath];
    if (cell) {
        [cell.iconImageView sd_setImageWithURL:RSSCategory.imageUrl placeholderImage:nil];
        [cell.titleLab setText:RSSCategory.name];
        
        return cell;
    }

    
    
    return [[UITableViewCell alloc] initWithFrame:CGRectZero];
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    
    DLRSSSubscribeViewController *RSSSubscribeViewController = [[DLRSSSubscribeViewController alloc] init];
    
    RSSSubscribeViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:RSSSubscribeViewController animated:YES];
    

}

-(void)rightBtnClicked {
    
    DLFeedEditViewController *feedEditViewController = [[DLFeedEditViewController alloc] init];
    
    [self.navigationController pushViewController:feedEditViewController animated:YES];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end