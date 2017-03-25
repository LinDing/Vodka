//
//  DLFeedsViewController.m
//  Vodka
//
//  Created by dinglin on 2017/3/25.
//  Copyright © 2017年 dinglin. All rights reserved.
//

#import "DLFeedsViewController.h"
#import <Masonry/Masonry.h>

@interface DLFeedsViewController ()
//自定义导航栏
@property (nonatomic) UINavigationBar *customNavigationBar;
@property (nonatomic) UINavigationItem *customNavigationItem;

@end

@implementation DLFeedsViewController
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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.customNavigationBar];

    //导航栏布局
    [self.customNavigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@64);
        make.top.equalTo(@0);
        make.left.equalTo(@0);
    }];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UINavigationItem *)customNavigationItem {
    if (!_customNavigationItem) {
        _customNavigationItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Feeds", comment: "")];
        
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(0, 0, 24, 24);
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        
        
        _customNavigationItem.rightBarButtonItems = @[rightBarBtn];
    }
    
    return _customNavigationItem;
}

-(UINavigationBar *)customNavigationBar {
    if (!_customNavigationBar) {
        _customNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
        [_customNavigationBar setItems:@[self.customNavigationItem] animated:false];
        _customNavigationBar.barTintColor = [UIColor whiteColor];
        _customNavigationBar.titleTextAttributes = @{
                                                     NSForegroundColorAttributeName:[UIColor blackColor]
                                                     
                                                     };
    }
    
    return _customNavigationBar;
}

-(void)rightBtnClicked {

}


@end
