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
#import "DLFeedAddRSSViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DLRSS.h"
#import <MJRefresh.h>
#import <MJExtension.h>
#import <XMNetworking.h>
#import "LKDBSQLState.h"

static NSString *const kUserInfoCell = @"kUserInfoCell";
static NSString *const kUserInfoSwitchCell = @"kUserInfoSwitchCell";

@interface DLRSSSubscribeViewController () <UITableViewDelegate, UITableViewDataSource>

//RSS订阅列表
@property (nonatomic) UITableView *RSSSubscribeListView;

@property (nonatomic) NSMutableArray <DLRSS *>*RSSList;


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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;

    //导航栏
    self.navigationItem.title = self.RSSGroup.name;
    
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightBtnClicked)];
    self.navigationItem.rightBarButtonItems = @[rightBarBtn];

    [self.view addSubview:self.RSSSubscribeListView];

    [self.RSSSubscribeListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
    }];
    
    self.RSSSubscribeListView.backgroundColor = [UIColor whiteColor];
    self.RSSSubscribeListView.dataSource = self;
    self.RSSSubscribeListView.delegate = self;
    
    self.RSSSubscribeListView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [XMCenter sendRequest:^(XMRequest *request) {
            request.api = @"classes/DLRSS";
            request.parameters = @{@"where":[NSString stringWithFormat:@"{\"groupId\":{\"__type\":\"Pointer\",\"className\":\"DLRSSGroup\",\"objectId\":\"%@\"}}", self.RSSGroup.rg_id]};
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
                         @"rg_id_fk" : @"groupId.objectId",

                         };
            }];
            
            NSMutableArray <DLRSS *>*RSSList = [DLRSS mj_objectArrayWithKeyValuesArray:responseObject[@"results"]];
            
            //缓存到数据库            
            for (DLRSS *RSS in RSSList) {
                [RSS saveOrUpdateByColumnName:@"r_id" AndColumnValue:RSS.r_id];
            }
            
            //更新界面
            [self.RSSSubscribeListView.mj_header endRefreshing];
            
            self.RSSList = RSSList;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.RSSSubscribeListView reloadData];
            });
            
        } onFailure:^(NSError *error) {
            DDLogError(@"onFailure: %@", error);
        } onFinished:^(id responseObject, NSError *error) {
            DDLogInfo(@"onFinished");
        }];
        
    }];
    
    // 查询出全部的RSS
    LKDBSQLState *query = [[LKDBSQLState alloc] object:[DLRSS class] type:WHERE key:@"rg_id_fk" opt:@"=" value:self.RSSGroup.rg_id];
    NSArray *RSSList = [DLRSS findByCriteria:[query sqlOptionStr]];

    self.RSSList = [RSSList mutableCopy];
    
}


-(UITableView *)RSSSubscribeListView {
    if (!_RSSSubscribeListView) {
        _RSSSubscribeListView = [[UITableView alloc] init];
        _RSSSubscribeListView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_RSSSubscribeListView registerClass:[DLUserInfoCell class] forCellReuseIdentifier:kUserInfoCell];
        [_RSSSubscribeListView registerClass:[DLUserInfoSwitchCell class] forCellReuseIdentifier:kUserInfoSwitchCell];
        
    }
    
    
    return _RSSSubscribeListView;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.RSSList.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    
    DLRSS *RSS = self.RSSList[row];
    
    DLUserInfoSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kUserInfoSwitchCell forIndexPath:indexPath];
    if (cell) {
        [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:RSS.iconUrl] placeholderImage:nil];
        [cell.titleLab setText:RSS.name];
    }

    
    return cell;
    
    return [[UITableViewCell alloc] initWithFrame:CGRectZero];
    
    
}


-(void)leftBtnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClicked {
    
    DLFeedAddRSSViewController *feedEditViewController = [[DLFeedAddRSSViewController alloc] init];
    
    [self.navigationController pushViewController:feedEditViewController animated:YES];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
