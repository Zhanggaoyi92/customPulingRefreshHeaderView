//
//  Fg_RefreshHeaderView.m
//  自己的下拉刷新控件
//
//  Created by zgy_smile on 16/8/12.
//  Copyright © 2016年 zgy_smile. All rights reserved.
//

#import "Fg_RefreshHeaderView.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f

@interface Fg_RefreshHeaderView ()
@property(strong,nonatomic)UILabel *statusLabel;
@property(strong,nonatomic)UIActivityIndicatorView * activityView;
@property(assign,nonatomic)FGPullRefreshState state;
@end

@implementation Fg_RefreshHeaderView

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        
        UILabel * label = [[UILabel alloc] init];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = [UIFont boldSystemFontOfSize:13.0f];
        label.textColor = TEXT_COLOR;
        label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _statusLabel=label;
        
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.frame = CGRectMake(25.0f, frame.size.height - 48.0f, 20.0f, 20.0f);
        [self addSubview:view];
        _activityView = view;
    }
    
    [self setState:FGPullRefreshNormal];
    
    return self;
}

- (void)setState:(FGPullRefreshState)aState{
    
    switch (aState) {
        case FGPullRefreshPulling:
            
            _statusLabel.text = @"Release to refresh...";
            
            break;
        case FGPullRefreshNormal:
            
            _statusLabel.text = @"Pull down to refresh...";
            if ([_activityView isAnimating]) {
                [_activityView stopAnimating];
            }
            break;
        case FGPullRefreshLoading:
            
            _statusLabel.text = @"Loading...";
            [_activityView startAnimating];
            
            break;
        default:
            break;
    }
    
    _state = aState;
}

#pragma mark - ScrollView Methods

- (void)fgRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_state == FGPullRefreshLoading) {
        return;
    }
    
    if (_state == FGPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f) {
        [self setState:FGPullRefreshNormal];
    } else if (_state == FGPullRefreshNormal && scrollView.contentOffset.y < -65.0f ) {
        [self setState:FGPullRefreshPulling];
    }
}
- (void)fgRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y <= - 65.0f) {
        
        [self setState:FGPullRefreshLoading];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self fgRefreshScrollViewDataSourceDidFinishedLoading:scrollView];
        });
    }
}

- (void)fgRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [UIView commitAnimations];
    
    [self setState:FGPullRefreshNormal];
    
}

@end
