//
//  DLCategoryInfoCell.m
//  Vodka
//
//  Created by dinglin on 2017/3/29.
//  Copyright © 2017年 dinglin. All rights reserved.
//

#import "DLCategoryInfoCell.h"
#import <Masonry.h>

@implementation DLCategoryInfoCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self makeUI];
    }
    
    return self;
}

-(void)makeUI {
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.titleLab];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@24);
        make.height.equalTo(@24);
        make.left.equalTo(self.contentView).offset(20);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@24);
        make.left.equalTo(self.iconImageView.mas_right).offset(15);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.titleLab sizeToFit];
  
}

-(UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
    }
    
    return _iconImageView;
}

-(UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    }
    
    return _titleLab;
}


@end
