//
//  SliderSelectView.h
//  Taoping
//
//  Created by biznest on 15/6/24.
//  Copyright (c) 2015年 CNIT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^sureValueBlock)(int num);
typedef void(^sureValueBlockForCity)(NSString *areaCode1, NSString *areaCode2, NSString *areaCode3, NSString *areaName1, NSString *areaName2, NSString *areaName3);
typedef void(^oneTimeBlock)(NSInteger time);
typedef void(^twoTimeBlock)(NSInteger startTime, NSInteger endTime);

@interface SliderSelectView : UIView

//滑动选择值
- (instancetype)initWithMinValue:(float)minValue maxValue:(float)maxValue currenValue:(float)currenVlue sureValueBlock:(sureValueBlock)block;

//城市滚动选择
- (instancetype)initWithCitySelectSureValuBlock:(sureValueBlockForCity)blockForCity;

//时间选择（几条,请选择 1或2）
- (instancetype)initWithOneTimePassBlock:(oneTimeBlock)oneTimePassBlock;
- (instancetype)initWithTwoTimePassBlock:(twoTimeBlock)twoTimePassBlock;

//展示
- (void)show;

@end
