//
//  DLRSSViewController.m
//  Vodka
//
//  Created by dinglin on 2017/3/29.
//  Copyright © 2017年 dinglin. All rights reserved.
//

#import "DLRSSSubscribeViewController.h"
#import <Masonry.h>
#import "DLUserInfoCell.h"
#import "DLUserInfoHeaderCell.h"
#import "DLUserInfoSwitchCell.h"
#import "DLAddRSSViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DLRSS.h"
#import <MJRefresh.h>
#import <MJExtension.h>
#import <XMNetworking.h>
#import <DLDBSQLState.h>
#import "VodkaUserDefaults.h"
#import "DLFeedInfo.h"
#import "DLFeedItem.h"
#import "AppUtil.h"

static NSString *const kUserInfoSwitchCell = @"kUserInfoSwitchCell";

@interface DLRSSSubscribeViewController () <UITableViewDelegate, UITableViewDataSource>

//RSS订阅列表
@property (nonatomic) UITableView *RSSSubscribeListView;

@property (nonatomic) NSMutableArray <DLRSS *>*RSSList;
//计算高度
@property (nonatomic, strong) UITableViewCell *templateCell;

@end

@implementation DLRSSSubscribeViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        DDLogInfo(@"DLRSSSubscribeViewController init");
    }
    
    return self;
}

-(void)dealloc {
    DDLogInfo(@"DLRSSSubscribeViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tryUpdateAddRSS:) name:[AppUtil notificationNameAddRSS] object:nil];

    self.automaticallyAdjustsScrollViewInsets = NO;

    //导航栏
    self.navigationItem.title = self.RSSGroup.name;
    
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightBtnClicked)];
    self.navigationItem.rightBarButtonItems = @[rightBarBtn];

    [self.view addSubview:self.RSSSubscribeListView];

    
    [self.RSSSubscribeListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
#if 0
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
#else
        make.bottom.equalTo(self.view);
#endif
    }];

    
    
    self.RSSSubscribeListView.backgroundColor = [UIColor whiteColor];
    self.RSSSubscribeListView.dataSource = self;
    self.RSSSubscribeListView.delegate = self;
    
    self.templateCell = [self.RSSSubscribeListView dequeueReusableCellWithIdentifier:kUserInfoSwitchCell];

    self.RSSSubscribeListView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [XMCenter sendRequest:^(XMRequest *request) {
            request.api = @"classes/DLRSS";
            request.parameters = @{@"where":[NSString stringWithFormat:@"{\"group\":{\"__type\":\"Pointer\",\"className\":\"DLRSSGroup\",\"objectId\":\"%@\"}}", self.RSSGroup.rg_id]};
            request.headers = @{};
            request.httpMethod = kXMHTTPMethodGET;
            request.requestSerializerType = kXMRequestSerializerJSON;
        } onSuccess:^(id responseObject) {
            
            [DLRSS mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
                return @{
                         @"r_id" : @"objectId",
                         @"name" : @"name",
                         @"iconUrl" : @"iconUrl",
                         @"feedUrl" : @"feedUrl",
                         @"linkUrl" : @"url",
                         @"open" : @"open",
                         @"rg_id_fk" : @"group.objectId",
                         @"u_id_fk" : @"author.objectId"

                         };
            }];
            
            NSMutableArray <DLRSS *>*RSSList = [DLRSS mj_objectArrayWithKeyValuesArray:responseObject[@"results"]];
            
            self.RSSList = RSSList;
            [self.RSSSubscribeListView reloadData];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //缓存到数据库
                for (DLRSS *RSS in RSSList) {
                    [RSS saveOrUpdateByColumnName:@"r_id" AndColumnValue:RSS.r_id];
                }
            });
            
        } onFailure:^(NSError *error) {
            DDLogError(@"onFailure: %@", error);
        } onFinished:^(id responseObject, NSError *error) {
            DDLogInfo(@"onFinished");
            [self.RSSSubscribeListView.mj_header endRefreshing];
        }];
        
    }];
    
    
    [self tryUpdateAddRSS:nil];
}


-(UITableView *)RSSSubscribeListView {
    if (!_RSSSubscribeListView) {
        _RSSSubscribeListView = [[UITableView alloc] init];
        _RSSSubscribeListView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_RSSSubscribeListView registerClass:[DLUserInfoSwitchCell class] forCellReuseIdentifier:kUserInfoSwitchCell];
        
    }
    
    
    return _RSSSubscribeListView;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.RSSList.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    
    DLRSS *RSS = self.RSSList[row];
    
    DLUserInfoSwitchCell *cell = (DLUserInfoSwitchCell *)self.templateCell;
    [cell.titleLab setText:RSS.name];
    
    CGFloat cellHeight = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 0.5f;
    if (cellHeight < 60) {
        cellHeight = 60;
    }
    
    
    return cellHeight;
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    
    DLRSS *RSS = self.RSSList[row];
    
    DLUserInfoSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoSwitchCell forIndexPath:indexPath];
    if (cell) {
        [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:RSS.iconUrl] placeholderImage:nil];
        [cell.titleLab setText:RSS.name];
        cell.titleSwitch.on = RSS.open;
        cell.titleSwitch.tag = row;
        [cell.titleSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }

    
    return cell;
    
    return [[UITableViewCell alloc] initWithFrame:CGRectZero];
    
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        
        
        VodkaUserDefaults *userDefaults= [VodkaUserDefaults sharedUserDefaults];
        NSString *accessToken = [userDefaults accessToken];
        
        DLRSS *RSS = self.RSSList[row];
        
        [XMCenter sendRequest:^(XMRequest *request) {
            request.api = [NSString stringWithFormat:@"classes/DLRSS/%@", RSS.r_id];
            request.parameters = @{};
            request.headers = @{@"X-LC-Session":accessToken};
            request.httpMethod = kXMHTTPMethodDELETE;
            request.requestSerializerType = kXMRequestSerializerJSON;
        } onSuccess:^(id responseObject) {
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //同时删除该RSS的所有DLFeedInfo DLFeedItem缓存
                DLDBSQLState *query1 = [[DLDBSQLState alloc] object:[DLFeedInfo class] type:WHERE key:@"feedUrl" opt:@"=" value:RSS.feedUrl];
                [DLFeedInfo deleteObjectsByCriteria:[query1 sqlOptionStr]];
                
                DLDBSQLState *query2 = [[DLDBSQLState alloc] object:[DLFeedItem class] type:WHERE key:@"fi_feedUrl_fk" opt:@"=" value:RSS.feedUrl];
                [DLFeedItem deleteObjectsByCriteria:[query2 sqlOptionStr]];
                
                //删除缓存
                DLDBSQLState *query = [[DLDBSQLState alloc] object:[DLRSS class] type:WHERE key:@"r_id" opt:@"=" value:RSS.r_id];
                [DLRSS deleteObjectsByCriteria:[query sqlOptionStr]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.RSSList removeObject:RSS];
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:[AppUtil notificationNameDeleteFeed] object:nil userInfo:nil];
                });
                
            });

        } onFailure:^(NSError *error) {
            DDLogError(@"onFailure: %@", error);
        } onFinished:^(id responseObject, NSError *error) {
            DDLogInfo(@"onFinished");
        }];
        
        
        
    }
}

-(void)leftBtnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClicked {
    DLAddRSSViewController *feedEditViewController = [[DLAddRSSViewController alloc] init];
    feedEditViewController.RSSGroup = self.RSSGroup;
    [self.navigationController pushViewController:feedEditViewController animated:YES];
}

-(void)tryUpdateAddRSS:(NSNotification *)notification{
    // 查询出全部的RSS
    DLDBSQLState *query = [[DLDBSQLState alloc] object:[DLRSS class] type:WHERE key:@"rg_id_fk" opt:@"=" value:self.RSSGroup.rg_id];
    NSArray *RSSList = [DLRSS findByCriteria:[query sqlOptionStr]];
    
    self.RSSList = [RSSList mutableCopy];
    
    [self.RSSSubscribeListView reloadData];

}

-(void)switchValueChanged:(UISwitch *)sender {

    NSInteger row = sender.tag;

    DLRSS *RSS = self.RSSList[row];
    
    VodkaUserDefaults *userDefaults= [VodkaUserDefaults sharedUserDefaults];
    NSString *accessToken = [userDefaults accessToken];
    
    [XMCenter sendRequest:^(XMRequest *request) {
        request.api = [NSString stringWithFormat:@"classes/DLRSS/%@", RSS.r_id];
        request.parameters = @{@"open":@(sender.on)};
        request.headers = @{@"X-LC-Session":accessToken};
        request.httpMethod = kXMHTTPMethodPUT;
        request.requestSerializerType = kXMRequestSerializerJSON;
    } onSuccess:^(id responseObject) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            RSS.open = sender.on;
            [RSS saveOrUpdateByColumnName:@"r_id" AndColumnValue:RSS.r_id];
            if (!sender.on) {
                //同时删除该RSS的所有DLFeedInfo DLFeedItem缓存
                DLDBSQLState *query1 = [[DLDBSQLState alloc] object:[DLFeedInfo class] type:WHERE key:@"feedUrl" opt:@"=" value:RSS.feedUrl];
                [DLFeedInfo deleteObjectsByCriteria:[query1 sqlOptionStr]];
                
                DLDBSQLState *query2 = [[DLDBSQLState alloc] object:[DLFeedItem class] type:WHERE key:@"fi_feedUrl_fk" opt:@"=" value:RSS.feedUrl];
                [DLFeedItem deleteObjectsByCriteria:[query2 sqlOptionStr]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:[AppUtil notificationNameDeleteFeed] object:nil userInfo:nil];
            });
            
        });
 
    } onFailure:^(NSError *error) {
        DDLogError(@"onFailure: %@", error);
    } onFinished:^(id responseObject, NSError *error) {
        DDLogInfo(@"onFinished");
    }];



}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
