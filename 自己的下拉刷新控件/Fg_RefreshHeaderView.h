//
//  Fg_RefreshHeaderView.h
//  自己的下拉刷新控件
//
//  Created by zgy_smile on 16/8/12.
//  Copyright © 2016年 zgy_smile. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
    FGPullRefreshPulling = 0,
    FGPullRefreshNormal,
    FGPullRefreshLoading,
} FGPullRefreshState;

@interface Fg_RefreshHeaderView : UIView
- (void)fgRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)fgRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView ;
@end
