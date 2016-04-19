//
//  RefrechIconView.m
//  FriendMoment
//
//  Created by tunsuy on 17/3/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import "RefrechIconView.h"

#define DEGREES_TO_RADIANS(x) ((x)/180.0*M_PI)

#define kRefrechIconViewRotationRate 59.0
#define kRefrechIconViewMaxOffsetY 50



@interface RefrechIconView()

@property (nonatomic) CGFloat preProcess;
@property (nonatomic) CGFloat process;

@end

@implementation RefrechIconView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _imageview.image = [UIImage imageNamed:@"WMIcon@2x.png"];
        _imageview.contentMode = UIViewContentModeScaleAspectFill;
        _imageview.clipsToBounds = YES;
        [self addSubview:_imageview];
        
        _fixOffsetY = self.frame.origin.y;
    }
    return self;
}

- (void)firstShow {
    CGRect frame = self.frame;
    frame.origin.y = kRefrechIconViewMaxOffsetY+_fixOffsetY;
    [self startAnimation];
}

- (void)stopAnimation {
    [self.imageview.layer removeAnimationForKey:@"rotation"];
}

- (void)startAnimation {
    [self.imageview.layer removeAnimationForKey:@"rotation"];
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = @(DEGREES_TO_RADIANS(0));
    rotation.toValue = @(DEGREES_TO_RADIANS(360));
    rotation.removedOnCompletion = NO;
    rotation.fillMode = kCAFillModeForwards;
    rotation.repeatCount = MAXFLOAT;
    rotation.duration = 0.7;
    [self.imageview.layer addAnimation:rotation forKey:@"rotation"];
}

- (void)stopStaticAnimation {
    [UIView animateWithDuration:0.7 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = _fixOffsetY;
        self.frame = frame;
    } completion:^(BOOL finished){
        [self stopAnimation];
    }];
}

- (void)setOffsetY:(CGFloat)offsetY {
    [self.imageview.layer removeAnimationForKey:@"rotation"];
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    _process = fabs(offsetY/kRefrechIconViewRotationRate);
    
    rotation.duration = 2.5;
//    NSLog(@"preProcess : %f ; process : %f", _preProcess, _process);
    rotation.fromValue = @(DEGREES_TO_RADIANS(180-180*_preProcess));
    rotation.toValue = @(DEGREES_TO_RADIANS(180-180*_process));
    rotation.removedOnCompletion = NO;
    rotation.fillMode = kCAFillModeForwards;
    [self.imageview.layer addAnimation:rotation forKey:@"rotation"];
    
    _preProcess = _process;
    
    CGRect frame = self.frame;
    frame.origin.y = MIN(kRefrechIconViewMaxOffsetY, -offsetY)+_fixOffsetY;
    self.frame = frame;
    
}

@end
