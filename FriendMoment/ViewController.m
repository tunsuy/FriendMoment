//
//  ViewController.m
//  FriendMoment
//
//  Created by tunsuy on 16/3/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import "ViewController.h"
#import "RefrechIconView.h"
#import "ActivityView.h"

#define kBackViewHeight 150
#define kFilterBtnWidth 50
#define kFilterBtnLeft 15
#define kRefrechIconViewLeft 15
#define kRefrechIconViewWidth 25

#define kRefrechIconViewMaxOffsetY 50

#define kWMActivityViewSize 28.0

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headView;
@property (nonatomic) BOOL hasData;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) RefrechIconView *refrechIconView;
@property (nonatomic) RefrechState oldState;

/** 第二种方式 */
@property (nonatomic, strong) ActivityView *activityView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];

    /** 第一种方式 */
//    _refrechIconView = [[RefrechIconView alloc] initWithFrame:CGRectMake(kRefrechIconViewLeft, -kRefrechIconViewWidth+64, -kRefrechIconViewWidth, kRefrechIconViewWidth)];
//    [self.view addSubview:_refrechIconView];
    
    /** 第二种方式 */
    __weak typeof(self) weakself = self;
    _activityView = [[ActivityView alloc] initWithFrame:CGRectMake(15.0, -kWMActivityViewSize+64 , kWMActivityViewSize, kWMActivityViewSize)];
    _activityView.scrollView = self.tableView;
    _activityView.refreshRequest = ^(ActivityView *sender) {
        [weakself pullDownRefreshData:sender];
    };
    [self.view addSubview:_activityView];
    
//    _tableView.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0);
    
    [_tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (BOOL)automaticallyAdjustsScrollViewInsets{
    return NO;
}

- (UIView *)generateHeadView {
    _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, kBackViewHeight)];
    
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _headView.frame.size.width, _headView.frame.size.height)];
    imageview.image = [UIImage imageNamed:@"IMG1.jpg"];
    imageview.clipsToBounds = YES;
    imageview.contentMode = UIViewContentModeScaleAspectFill;
    
    UIButton *filterBtn = [[UIButton alloc] initWithFrame:CGRectMake(_headView.frame.size.width-kFilterBtnLeft-kFilterBtnWidth, _headView.frame.size.height-kFilterBtnWidth/2, kFilterBtnWidth, kFilterBtnWidth)];
    
//    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(kFilterBtnWidth/2, kFilterBtnWidth/2) radius:kFilterBtnWidth/2.0 startAngle:0 endAngle:M_1_PI*360/180 clockwise:YES];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, kFilterBtnWidth, kFilterBtnWidth)];
    CAShapeLayer *filterLayer = [CAShapeLayer layer];
    filterLayer.path = circlePath.CGPath;
    filterLayer.fillColor = [UIColor redColor].CGColor;
//    filterLayer.strokeColor = [UIColor redColor].CGColor;
//    filterBtn.backgroundColor = [UIColor redColor];
    [filterBtn.layer addSublayer:filterLayer];
    [filterBtn setTitle:@"筛选" forState:UIControlStateNormal];
    [filterBtn addTarget:self action:@selector(filterBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_headView addSubview:imageview];
    [_headView addSubview:filterBtn];
    
    return _headView;
    
}

- (void)filterBtnClick:(id)sender{
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [self generateHeadView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kBackViewHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = @"呵呵大";
    return cell;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGFloat offsetY = _tableView.contentOffset.y;

        BOOL hasChanged = !(_oldState == _refrechIconView.refrechState);
        if (offsetY > 0 && hasChanged) {
            [_refrechIconView stopAnimation];
        }else if (_refrechIconView.refrechState == RefrechStateStatic && hasChanged) {
            [_refrechIconView startAnimation];
            
        }else if (_refrechIconView.refrechState == RefrechStatePulling) {
            [_refrechIconView setOffsetY:offsetY];
        }
        
        _oldState = _refrechIconView.refrechState;
        
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    [_tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    if (!(_refrechIconView.refrechState == RefrechStateStatic)) {
        _refrechIconView.refrechState = RefrechStatePulling;
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([scrollView isKindOfClass:[UITableView class]]) {
        if (fabs(scrollView.contentOffset.y) >= kRefrechIconViewMaxOffsetY) {
//            [_tableView removeObserver:self forKeyPath:@"contentOffset"];
//            [_refrechIconView startAnimation];
            _refrechIconView.refrechState = RefrechStateStatic;
            [self pullRefrech];
        }
    }
    
    
}

- (void)pullRefrech {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)5.0*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_refrechIconView stopStaticAnimation];
        _refrechIconView.refrechState = RefrechStateDone;
        
    });
}

/** 第二种方式 */
#pragma mark - 
- (void)pullDownRefreshData:(ActivityView *)sender {
    __weak typeof(self) weakself = self;
    dispatch_time_t refreshTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5*NSEC_PER_SEC));
    dispatch_after(refreshTime, dispatch_get_main_queue(), ^(){
        if ([weakself.activityView refresh]) {
            [weakself.activityView endRefreshing];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
