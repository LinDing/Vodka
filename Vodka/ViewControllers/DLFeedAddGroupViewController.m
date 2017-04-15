//
//  DLFeedEditViewController.m
//  Vodka
//
//  Created by dinglin on 2017/3/26.
//  Copyright © 2017年 dinglin. All rights reserved.
//

#import "DLFeedAddGroupViewController.h"
#import <Masonry.h>
#import <XMNetworking.h>

@interface DLFeedAddGroupViewController ()

@property (nonatomic) UITextField *groupNameTF;

@end

@implementation DLFeedAddGroupViewController

-(instancetype)init {
    self = [super init];
    if (self) {
        DDLogInfo(@"DLFeedAddGroupViewController init");
    }
    
    return self;
}

-(void)dealloc {
    DDLogInfo(@"DLFeedAddGroupViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //导航栏
    self.navigationItem.title = NSLocalizedString(@"Add group", comment: "");
    
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightBtnClicked)];
    
    self.navigationItem.rightBarButtonItems = @[rightBarBtn];
    
    
    [self.view addSubview:self.groupNameTF];
    
    
    [self.groupNameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(20);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@40);
    }];
    
    [self.groupNameTF becomeFirstResponder];
    
}

-(UITextField *)groupNameTF {
    if (!_groupNameTF) {
        _groupNameTF = [[UITextField alloc] init];
        _groupNameTF.textAlignment = NSTextAlignmentCenter;
        _groupNameTF.placeholder = NSLocalizedString(@"Input group name", comment: "");
        _groupNameTF.backgroundColor = [UIColor whiteColor];
    }
    
    return _groupNameTF;
}



-(void)rightBtnClicked {
    NSString *groupName = self.groupNameTF.text;
    if (!groupName || groupName.length == 0) {
        return;
    }
    
    [XMCenter sendRequest:^(XMRequest *request) {
        request.api = @"classes/DLRSSGroup";
        request.parameters = @{@"name":groupName};
        request.headers = @{};
        request.httpMethod = kXMHTTPMethodPOST;
        request.requestSerializerType = kXMRequestSerializerJSON;
    } onSuccess:^(id responseObject) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
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
