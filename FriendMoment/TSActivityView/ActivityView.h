//
//  ActivityView.h
//  FriendMoment
//
//  Created by tunsuy on 28/5/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityView : UIView

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *activityView;

@property (nonatomic) NSString *state;

@property (nonatomic, copy) void (^refreshRequest)(ActivityView *sender);

- (BOOL)refresh;
- (void)beginRefreshing;
- (void)endRefreshing;

@end
