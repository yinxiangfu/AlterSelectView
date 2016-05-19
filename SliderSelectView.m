//
//  SliderSelectView.m
//  Taoping
//
//  Created by biznest on 15/6/24.
//  Copyright (c) 2015年 CNIT. All rights reserved.
//

#import "SliderSelectView.h"
#import "CityModel.h"

#define UI_WIDTH    [UIScreen mainScreen].bounds.size.width
#define UI_HEIGHT   [UIScreen mainScreen].bounds.size.height

@interface SliderSelectView () <UIPickerViewDelegate, UIPickerViewDataSource>
{
    UIWindow *_window;
    UIView *_showView;
    UILabel *_titleLb;
    UIButton *_cancelBt;
    UIButton *_sureBt;
    
    float _minValue;
    float _maxValue;
    float _currenValue;
    sureValueBlock _block;      //值选择回调
    
    UILabel *_numLb;

    NSMutableArray *_cityArr;
    NSInteger _areaCode1;   //省
    NSInteger _areaCode2;   //市
    NSInteger _areaCode3;   //区
    UIPickerView *_pickerView;
    sureValueBlockForCity _blockForCity;    //城市选择回调
    
    int _kind;              //初始化种类 （0：滑动条，1：城市选择，2：时间选择）
    
    int _timeNum;           //时间选择滚动条数目
    
    NSInteger _startTime;   //开始时间
    NSInteger _endTime;     //结束时间
    oneTimeBlock _oneTimePassBlock;
    twoTimeBlock _twoTimePassBlock;
}
@end

@implementation SliderSelectView

- (void)initBase
{
    _window = [UIApplication sharedApplication].keyWindow;
    self.frame = _window.bounds;
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    
    _titleLb = [[UILabel alloc] init];
    _titleLb.text = @"请选择";
    _titleLb.font = [UIFont systemFontOfSize:18];
    _titleLb.backgroundColor = [UIColor whiteColor];
    _titleLb.textAlignment = NSTextAlignmentCenter;
    
    _cancelBt = [UIButton buttonWithType:UIButtonTypeSystem];
    _cancelBt.backgroundColor = [UIColor orangeColor];
    [_cancelBt setTitle:@"取消" forState:UIControlStateNormal];
    _cancelBt.tag = 1;
    [_cancelBt addTarget:self action:@selector(clickBt:) forControlEvents:UIControlEventTouchUpInside];
    
    _sureBt = [UIButton buttonWithType:UIButtonTypeSystem];
    _sureBt.backgroundColor = [UIColor redColor];
    [_sureBt setTitle:@"确定" forState:UIControlStateNormal];
    _sureBt.tag = 2;
    [_sureBt addTarget:self action:@selector(clickBt:) forControlEvents:UIControlEventTouchUpInside];

}

//滑动选择值
- (instancetype)initWithMinValue:(float)minValue maxValue:(float)maxValue currenValue:(float)currenVlue sureValueBlock:(sureValueBlock)block
{
    self = [super init];
    if (self) {
        _kind = 0;
        _minValue = minValue;
        _maxValue = maxValue;
        _currenValue = currenVlue;
        _block = block;
        [self initBase];
        [self initShowView];
        [self show];
    }
    return self;
}

//城市滚动选择
- (instancetype)initWithCitySelectSureValuBlock:(sureValueBlockForCity)blockForCity;
{
    self = [super init];
    if (self) {
        [self initBase];
        _kind = 1;
        _blockForCity = blockForCity;
        
        [self jsonCity];
        [self initPicker];
    }
    return self;
}

//时间选择（几条,请选择 1或2）
- (instancetype)initWithOneTimePassBlock:(oneTimeBlock)oneTimePassBlock
{
    self = [super init];
    if (self) {
        _oneTimePassBlock = oneTimePassBlock;
        _timeNum = 1;
        _startTime = 0;
        [self initTimeSelectView];
    }
    return self;
}

- (instancetype)initWithTwoTimePassBlock:(twoTimeBlock)twoTimePassBlock
{
    self = [super init];
    if (self) {
        _twoTimePassBlock = twoTimePassBlock;
        _timeNum = 2;
        _startTime = 0;
        _endTime = 0;
        [self initTimeSelectView];
    }
    return self;
}

- (void)initTimeSelectView
{
    _kind = 2;
    [self initBase];
    [self initPicker];
}


- (void)initPicker
{
    _pickerView = [[UIPickerView alloc] init];
    _pickerView.center = self.center;
    _pickerView.backgroundColor = [UIColor whiteColor];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    
    _titleLb.frame = CGRectMake(_pickerView.frame.origin.x, _pickerView.frame.origin.y - 40, _pickerView.frame.size.width, 40);
    [self addSubview:_titleLb];
    
    _cancelBt.frame = CGRectMake(_pickerView.frame.origin.x, _pickerView.frame.origin.y + _pickerView.frame.size.height, _pickerView.frame.size.width/2, 40);
    [self addSubview:_cancelBt];

    _sureBt.frame = CGRectMake(_pickerView.frame.size.width/2, _cancelBt.frame.origin.y, _pickerView.frame.size.width/2, 40);
    [self addSubview:_sureBt];
    
    [self addSubview:_pickerView];
}

//解析城市plist数据
- (void)jsonCity
{
    NSString *cityPlistPath = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"plist"];
    NSArray *cityArr = [NSArray arrayWithContentsOfFile:cityPlistPath];
    _areaCode1 = 0;
    _areaCode2 = 0;
    _areaCode3 = 0;
    _cityArr = [NSMutableArray array];
    for (NSDictionary *ac1Dic in cityArr) {
        //省
        CityModel *ac1Md = [[CityModel alloc] init];
        ac1Md.name = ac1Dic[@"name"];
        ac1Md.code = ac1Dic[@"pid"];
        for (NSDictionary *ac2Dic in ac1Dic[@"cities"]) {
            //市
            CityModel *ac2Md = [[CityModel alloc] init];
            ac2Md.name = ac2Dic[@"cname"];
            ac2Md.code = ac2Dic[@"cid"];
            for (NSDictionary *ac3Dic in ac2Dic[@"district"]) {
                //区
                CityModel *ac3Md = [[CityModel alloc] init];
                ac3Md.name = ac3Dic[@"dname"];
                ac3Md.code = ac3Dic[@"did"];
                [ac2Md.nextArr addObject:ac3Md];
            }
            [ac1Md.nextArr addObject:ac2Md];
        }
        [_cityArr addObject:ac1Md];
    }
}

- (void)show
{
    [_window addSubview:self];
}

- (void)initShowView
{
    _showView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width*0.9, 170)];
    _showView.center = self.center;
    _showView.backgroundColor = [UIColor whiteColor];
    
    _titleLb.frame = CGRectMake(0, 10, _showView.bounds.size.width, 20);
    [_showView addSubview:_titleLb];

    CGFloat sliderWidth = _showView.frame.size.width * 0.8;
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(_showView.frame.size.width/2 - sliderWidth/2, 70, sliderWidth, 40)];
    slider.minimumTrackTintColor = [UIColor orangeColor];
    slider.maximumTrackTintColor = [UIColor grayColor];
    slider.thumbTintColor = [UIColor redColor];
    slider.minimumValue = _minValue;
    slider.maximumValue = _maxValue;
    slider.value = (int)_currenValue;
    [slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    [_showView addSubview:slider];
    
    _numLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, _showView.frame.size.width, 20)];
    _numLb.text = [NSString stringWithFormat:@"%d",(int)slider.value];
    _numLb.textAlignment = NSTextAlignmentCenter;
    [_showView addSubview:_numLb];

    _cancelBt.frame = CGRectMake(0, 130, _showView.frame.size.width/2, 40);
    [_showView addSubview:_cancelBt];
    
    _sureBt.frame = CGRectMake(_showView.frame.size.width/2, 130, _showView.frame.size.width/2, 40);
    [_showView addSubview:_sureBt];
    
    [self addSubview:_showView];
}

- (void)sliderChange:(UISlider *)sender
{
    _numLb.text = [NSString stringWithFormat:@"%d", (int)sender.value];
}

- (void)clickBt:(UIButton *)sender
{
    if (sender.tag == 2) {
        switch (_kind) {
            case 0:
            {
                if (_block) {
                    _block([_numLb.text intValue]);
                }
            }
                break;
             case 1:
            {
                if (_blockForCity) {
                    CityModel *ac1M = _cityArr[_areaCode1];
                    CityModel *ac2M = ac1M.nextArr[_areaCode2];
                    CityModel *ac3M = ac2M.nextArr[_areaCode3];
                    _blockForCity(ac1M.code, ac2M.code, ac3M.code, ac1M.name, ac2M.name, ac3M.name);
                }
            }
                break;
            case 2:
            {
                if (_timeNum == 1) {
                    if (_oneTimePassBlock) {
                        _oneTimePassBlock(_startTime);
                    }
                }else if (_timeNum == 2){
                    if (_twoTimePassBlock) {
                        _twoTimePassBlock(_startTime, _endTime);
                    }
                }
            }
                break;
            default:
                break;
        }
    }
    [self removeFromSuperview];

}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (_kind == 1) {
        return 3;
    }
    
    return _timeNum;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (_kind == 1) {
        CityModel *ac1Md = _cityArr[_areaCode1];
        CityModel *ac2Md = ac1Md.nextArr[_areaCode2];
        
        if (component == 0) {
            return _cityArr.count;              //省
        }else if (component == 1){
            return  ac1Md.nextArr.count;        //市
        }else{
            return ac2Md.nextArr.count;         //区
        }
    }
    
//    if (_timeNum == 2 && component == 1) {
//        return 24 - _startTime;
//    }
    return 24;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_kind == 1) {
        if (component == 0) {
            //省
            CityModel *ac1Md = _cityArr[row];
            return ac1Md.name;
        }else if (component == 1){
            //市
            CityModel *ac1Md = _cityArr[_areaCode1];
            CityModel *ac2Md = ac1Md.nextArr[row];
            return ac2Md.name;
        }else{
            //区
            CityModel *ac1Md = _cityArr[_areaCode1];
            CityModel *ac2Md = ac1Md.nextArr[_areaCode2];
            CityModel *ac3Md = ac2Md.nextArr[row];
            return ac3Md.name;
        }

    }
//    if (_timeNum == 2 && component == 1) {
//        return [NSString stringWithFormat:@"%02ld:00",[self timeZeroHandleWithTime:(long)row + _startTime + 1]];
//    }
    return [NSString stringWithFormat:@"%02ld:00",(long)row];
}

//24时处理
- (NSInteger)timeZeroHandleWithTime:(NSInteger)time
{
    if (time >= 24) {
        return time - 24;
    }
    return time;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_kind == 1) {
        if (component == 0) {
            //省
            _areaCode1 = row;
            _areaCode2 = 0;
            _areaCode3 = 0;
            [_pickerView reloadAllComponents];
            [_pickerView selectRow:0 inComponent:1 animated:YES];
            [_pickerView selectRow:0 inComponent:2 animated:YES];
        }else if (component == 1){
            //市
            _areaCode2 = row;
            _areaCode3 = 0;
            [_pickerView reloadAllComponents];
            [_pickerView selectRow:0 inComponent:2 animated:YES];
        }else{
            //区
            _areaCode3 = row;
        }
    }
    
    if (_timeNum == 2) {
        if (component == 0) {
            _startTime = row;
//            _endTime = [self timeZeroHandleWithTime:_startTime + 1];
//            [_pickerView reloadAllComponents];
//            [_pickerView selectRow:0 inComponent:1 animated:YES];
        }else{
//            _endTime = [self timeZeroHandleWithTime:row + _startTime + 1];
            _endTime = row;
        }
    }else{
        _startTime = row;
    }
}

@end
