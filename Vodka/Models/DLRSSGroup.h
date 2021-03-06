//
//  DLNewsCategory.h
//  Vodka
//
//  Created by dinglin on 2017/3/29.
//  Copyright © 2017年 dinglin. All rights reserved.
//

#import <DLDBModel.h>

@interface DLRSSGroup : DLDBModel

@property (nonatomic, assign) int pk_id;

@property (nonatomic, copy) NSString *rg_id;

//分组的名称
@property (nonatomic, copy) NSString *name;

//外键，分组的作者id
@property (nonatomic, copy) NSString *u_id_fk;

@end

