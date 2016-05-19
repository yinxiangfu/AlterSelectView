//
//  CityModel.h
//  Taoping
//
//  Created by biznest on 15/6/25.
//  Copyright (c) 2015年 CNIT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityModel : NSObject

@property (nonatomic, copy) NSString *name;             //名字
@property (nonatomic, copy) NSString *code;             //编号
@property (nonatomic, strong) NSMutableArray *nextArr;  //下级
@end
