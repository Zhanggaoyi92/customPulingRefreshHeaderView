# customPulingRefreshHeaderView
每个人都能学会的下拉刷新demo，然后可以开心的自己实现自己的下拉刷新控件了。
# custom pulling refresh header View
- 此篇目的是让大家都可以学会下拉刷新控件的实现，然后轻松自定义自己的下拉刷新控件。
- 坐稳咯，开车了！
- 首先，你初始化一个头部视图和一个tableview

```
-(void)setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    if (self.refreshHeaderView == nil) {
        //稍后介绍这个自定义头部视图，继承的是一个view
        Fg_RefreshHeaderView *view = [[Fg_RefreshHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        // 不太理解，添加tableviewHeaderView会顶上去，使用clipsToBounds也切不掉，打印tableview的frame 也没有变大。大神解释一下呀 -。-
        [self.tableView addSubview:view];
        self.refreshHeaderView = view;
    }
}
```
- 然后实现tableview 的数据源方法，有个视图效果就好，就不粘代码了。
- 然后是代理方法，直接由refreshHeaderView 头部view接管。

```
#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    [self.refreshHeaderView fgRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [self.refreshHeaderView fgRefreshScrollViewDidEndDragging:scrollView];
}
```
- 以上是控制器里的所有代码了，下面是Fg_RefreshHeaderView 自定义头部视图的代码了。

```
//下拉常见的3种状态
typedef enum{
    FGPullRefreshPulling = 0,
    FGPullRefreshNormal,
    FGPullRefreshLoading,
} FGPullRefreshState;
//两个接管tableview 的代理方法的接口
@interface Fg_RefreshHeaderView : UIView
- (void)fgRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)fgRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView ;
@end
```
- 需要达到视觉效果的属性，并初始化。

```
#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]

@interface Fg_RefreshHeaderView ()
//动态显示当前下拉状态label
@property(strong,nonatomic)UILabel *statusLabel;
//显示加载状态指示器
@property(strong,nonatomic)UIActivityIndicatorView * activityView;
//记录当前状态
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
```
- 切换状态的方法，直接重写state 的setter方法，来使状态显示与状态绑定，实时显示。

```
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
```
- 接下来就是核心部分了，即如何接管tableview 的代理方法了

```
#pragma mark - ScrollView Methods

- (void)fgRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_state == FGPullRefreshLoading) {
        //用户滑动时，不要去修改contentInset ，会抖动。之前按自己的理解就是在偏移达到 -65.0f 时（用户此时还在拖动tableview）就改动contentInset，一直卡在这部分，实现不了下拉刷新控件，悲剧。
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

        //这里是模拟加载数据，然后回调。应用时，应该发消息（怎么发自己决定，block，代理，通知...），通知外面更新数据，更新数据然后回调通知 gcd 里面这个方法，停止刷新即可。
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self fgRefreshScrollViewDataSourceDidFinishedLoading:scrollView];
        });
        
        [self setState:FGPullRefreshLoading];
        //这个动画去掉也没关系
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
    }
}

- (void)fgRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    [scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [UIView commitAnimations];
    
    [self setState:FGPullRefreshNormal];
    
}
```

- 关键点以注释的形式，在代码中。自己之前实现过，有点不顺，就放弃啦（主要是有现成的框架，且只是易用，不易学），后来发现其实，就差一点点，思路其实蛮简单的。
- 相信大家看完后都可以实现自己的下拉刷新控件，在state的setter方法下，定义每个状态的显示，可以简单清爽，也可以是动画，看自己喜欢了。
- 我是学习了大神的demo，发现soeasy，这是他的链接：https://github.com/enormego/EGOTableViewPullRefresh
[不过这个demo，不能执行了，版本太久远，需要自己修改一下就行了]
- Emil:zhanggaoyi92@163.com 欢迎交流！

