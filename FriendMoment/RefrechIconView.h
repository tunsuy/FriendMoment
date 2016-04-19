//
//  RefrechIconView.h
//  FriendMoment
//
//  Created by tunsuy on 17/3/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RefrechState) {
    RefrechStatePulling = 0,
    RefrechStateStatic,
    RefrechStateDone
};

@interface RefrechIconView : UIView

@property (nonatomic, strong) UIImageView *imageview;
@property (nonatomic, strong) UIView *refrechIconView;
@property (nonatomic) CGFloat fixOffsetY;
@property (nonatomic) RefrechState refrechState;

- (void)setOffsetY:(CGFloat)offsetY;
- (void)startAnimation;
- (void)stopAnimation;
- (void)stopStaticAnimation;

@end
