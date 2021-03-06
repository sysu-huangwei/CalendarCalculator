//
//  ViewController.m
//  CalendarCalculator
//
//  Created by rayyy on 2021/3/31.
//

#import "ViewController.h"
#import "MSSCalendarViewController.h"
#import "MSSCalendarDefine.h"

@interface ViewController ()<MSSCalendarViewControllerDelegate>
@property (nonatomic,strong)UILabel *startLabel;
@property (nonatomic,strong)UILabel *endLabel;
@property (nonatomic,strong)UILabel *workdayCountLabel;
@property (nonatomic,strong)UILabel *holidayCountLabel;
@property (nonatomic,assign)NSInteger startDate;
@property (nonatomic,assign)NSInteger endDate;
// {"year": "2021",  "month": "2",  "day": "7",  "name": "春节"}
@property (nonatomic,strong)NSMutableArray<NSMutableDictionary<NSString *, NSString *> *> *chineseHolidayNeedWork;
@property (nonatomic,strong)NSMutableArray<NSMutableDictionary<NSString *, NSString *> *> *chineseHolidayNotNeedWork;

// {"year": "2021",  "month": "2",  "day": "7",  "week": "7"}
@property (nonatomic,strong)NSMutableArray<NSDictionary<NSString *, NSString *> *> *selectedNeedWork;
@property (nonatomic,strong)NSMutableArray<NSDictionary<NSString *, NSString *> *> *selectedNotNeedWork;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self parseChineseHoliday];
    [self createUI];
}

- (void)createUI
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((MSS_SCREEN_WIDTH - 110) / 2, 80, 110, 50);
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    btn.layer.cornerRadius = 5.0f;
    btn.layer.borderWidth = 1.0f;
    btn.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    [btn setTitle:@"打开日历" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(calendarClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    _startLabel = [[UILabel alloc]init];
    _startLabel.backgroundColor = MSS_SelectBackgroundColor;
    _startLabel.textColor = MSS_SelectTextColor;
    _startLabel.textAlignment = NSTextAlignmentCenter;
    _startLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    _startLabel.frame = CGRectMake(20, CGRectGetMaxY(btn.frame) + 20, MSS_SCREEN_WIDTH - 20 * 2, 50);
    _startLabel.text = @"开始日期";
    [self.view addSubview:_startLabel];
    
    _endLabel = [[UILabel alloc]init];
    _endLabel.backgroundColor = MSS_SelectBackgroundColor;
    _endLabel.textColor = MSS_SelectTextColor;
    _endLabel.textAlignment = NSTextAlignmentCenter;
    _endLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    _endLabel.frame = CGRectMake(20, CGRectGetMaxY(_startLabel.frame) + 20, MSS_SCREEN_WIDTH - 20 * 2, 50);
    _endLabel.text = @"开始日期";
    _endLabel.text = @"结束日期";
    [self.view addSubview:_endLabel];
    
    _workdayCountLabel = [[UILabel alloc]init];
    _workdayCountLabel.backgroundColor = MSS_SelectBackgroundColor;
    _workdayCountLabel.textColor = MSS_SelectTextColor;
    _workdayCountLabel.textAlignment = NSTextAlignmentCenter;
    _workdayCountLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    _workdayCountLabel.frame = CGRectMake(20, CGRectGetMaxY(_endLabel.frame) + 20, MSS_SCREEN_WIDTH - 20 * 2, 50);
    _workdayCountLabel.text = @"工作日";
    [self.view addSubview:_workdayCountLabel];
    
    _holidayCountLabel = [[UILabel alloc]init];
    _holidayCountLabel.backgroundColor = MSS_SelectBackgroundColor;
    _holidayCountLabel.textColor = MSS_SelectTextColor;
    _holidayCountLabel.textAlignment = NSTextAlignmentCenter;
    _holidayCountLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    _holidayCountLabel.frame = CGRectMake(20, CGRectGetMaxY(_workdayCountLabel.frame) + 20, MSS_SCREEN_WIDTH - 20 * 2, 50);
    _holidayCountLabel.text = @"休息日";
    [self.view addSubview:_holidayCountLabel];
}

- (void)calendarClick:(UIButton *)btn
{
    MSSCalendarViewController *cvc = [[MSSCalendarViewController alloc]init];
    cvc.limitMonth = 12 * 15;// 显示几个月的日历
    /*
     MSSCalendarViewControllerLastType 只显示当前月之前
     MSSCalendarViewControllerMiddleType 前后各显示一半
     MSSCalendarViewControllerNextType 只显示当前月之后
     */
    cvc.type = MSSCalendarViewControllerMiddleType;
    cvc.beforeTodayCanTouch = YES;// 今天之后的日期是否可以点击
    cvc.afterTodayCanTouch = YES;// 今天之前的日期是否可以点击
    cvc.startDate = _startDate;// 选中开始时间
    cvc.endDate = _endDate;// 选中结束时间
    /*以下两个属性设为YES,计算中国农历非常耗性能（在5s加载15年以内的数据没有影响）*/
    cvc.showChineseHoliday = YES;// 是否展示农历节日
    cvc.showChineseCalendar = YES;// 是否展示农历
    cvc.showHolidayDifferentColor = YES;// 节假日是否显示不同的颜色
    cvc.showAlertView = YES;// 是否显示提示弹窗
    cvc.delegate = self;
    [self presentViewController:cvc animated:YES completion:nil];
}

- (void)calendarViewConfirmClickWithStartDate:(NSInteger)startDate endDate:(NSInteger)endDate dates:(NSMutableArray<NSMutableDictionary<NSString *, NSString *> *> *)dates
{
    [self getSelectedDates:dates];
    _startDate = startDate;
    _endDate = endDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSString *startDateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_startDate]];
    NSString *endDateString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_endDate]];
    _startLabel.text = [NSString stringWithFormat:@"开始日期: %@",startDateString];
    _endLabel.text = [NSString stringWithFormat:@"结束日期: %@",endDateString];
    _workdayCountLabel.text = [NSString stringWithFormat:@"工作日: %ld", _selectedNeedWork.count];
    _holidayCountLabel.text = [NSString stringWithFormat:@"休息日: %ld", _selectedNotNeedWork.count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)parseChineseHoliday {
    if (!_chineseHolidayNeedWork) {
        _chineseHolidayNeedWork = [[NSMutableArray alloc] init];
    }
    if (!_chineseHolidayNotNeedWork) {
        _chineseHolidayNotNeedWork = [[NSMutableArray alloc] init];
    }
    
    NSString *jsonFolderPath = [NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:@"datesJson"];
    for (int i = 2007; i <= 2021; i++) {
        NSString *jsonPath = [jsonFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.json", i]];
        NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
        NSArray *days = jsonDict[@"days"];
        for (NSDictionary *dayDict in days) {
            NSMutableDictionary *infoItem = [[NSMutableDictionary alloc] init];
            infoItem[@"name"] = dayDict[@"name"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [dateFormatter dateFromString:dayDict[@"date"]];
            [dateFormatter setDateFormat:@"yyyy"];
            infoItem[@"year"] = [dateFormatter stringFromDate:date];
            [dateFormatter setDateFormat:@"MM"];
            infoItem[@"month"] = [dateFormatter stringFromDate:date];
            [dateFormatter setDateFormat:@"dd"];
            infoItem[@"day"] = [dateFormatter stringFromDate:date];
            if ([dayDict[@"isOffDay"] boolValue]) {
                [_chineseHolidayNotNeedWork addObject:infoItem];
            } else {
                [_chineseHolidayNeedWork addObject:infoItem];
            }
        }
    }
}

- (void)getSelectedDates:(NSArray<NSDictionary<NSString *, NSString *> *> *)dates {
    if (!_selectedNotNeedWork) {
        _selectedNotNeedWork = [[NSMutableArray alloc] init];
    }
    if (!_selectedNeedWork) {
        _selectedNeedWork = [[NSMutableArray alloc] init];
    }
    [_selectedNotNeedWork removeAllObjects];
    [_selectedNeedWork removeAllObjects];
    for (NSDictionary<NSString *, NSString *> *date in dates) {
        if ([self isDate:date InList:_chineseHolidayNotNeedWork]) {
            [_selectedNotNeedWork addObject:date];
        } else if ([self isDate:date InList:_chineseHolidayNeedWork]) {
            [_selectedNeedWork addObject:date];
        } else if ([date[@"week"] integerValue] == 6 || [date[@"week"] integerValue] == 0) {
            [_selectedNotNeedWork addObject:date];
        } else {
            [_selectedNeedWork addObject:date];
        }
    }
}

- (BOOL)isDate:(NSDictionary<NSString *, NSString *> *)date InList:(NSArray<NSDictionary<NSString *, NSString *> *> *)list {
    for (NSDictionary<NSString *, NSString *> *dateItem in list) {
        if ([self isSameDate:date otherDate:dateItem]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isSameDate:(NSDictionary<NSString *, NSString *> *)date1 otherDate:(NSDictionary<NSString *, NSString *> *)date2 {
    return [date1[@"year"] integerValue] == [date2[@"year"] integerValue] &&
           [date1[@"month"] integerValue] == [date2[@"month"] integerValue] &&
           [date1[@"day"] integerValue] == [date2[@"day"] integerValue];
}

@end
