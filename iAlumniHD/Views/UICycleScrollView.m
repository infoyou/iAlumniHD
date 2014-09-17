//
//  UICycleScrollView.m
//  iAlumniHD
//
//  Created by Adam on 12-11-20.
//
//

#import "UICycleScrollView.h"
#import "CommonUtils.h"
#import "GlobalConstants.h"
#import "AppManager.h"

#define FONT_SIZE              13.0f
#define TOP_VIEW_H             105.f

#define INTERVAL               5.0f

static int curPage = 0;
static int totalPage = 0;

@implementation UICycleScrollView
@synthesize delegate;
@synthesize currentClubPostArray;
@synthesize userName;
@synthesize postContent;
@synthesize _timer;
@synthesize pageControl;
@synthesize viewsArray;
@synthesize curViews;
@synthesize scrollView;

#pragma mark - init
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        scrollFrame = frame;
        
        totalPage = [[AppManager instance].clubPostArray count];
        curPage = 1;
        //create pages
        [self createPages];
        
        CGRect scrollViewRect = [self bounds];
        scrollView = [[UIScrollView alloc] initWithFrame:frame];
        scrollView.backgroundColor = TRANSPARENT_COLOR;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        
        scrollView.frame = CGRectOffset(scrollView.frame, 0, -37.f);
        [self addSubview:scrollView];
        
        // 在水平方向滚动
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 3,
                                            scrollView.frame.size.height);
        scrollView.delegate = self;
        
        //create page control view
        float pageControlHeight = 15.0;
        CGRect pageViewRect = [self bounds];
        pageViewRect.size.height = pageControlHeight;
        pageViewRect.origin.y = scrollViewRect.size.height;
        
        pageControl = [[UIPageControl alloc] initWithFrame:pageViewRect];
        pageControl.frame = CGRectOffset(pageControl.frame, 0, -8.f);
        
        pageControl.backgroundColor = TRANSPARENT_COLOR;
        pageControl.numberOfPages = totalPage;
        pageControl.currentPage = 0;
        [pageControl addTarget:self action:@selector(changePage) forControlEvents:UIControlEventValueChanged];
        [self addSubview:pageControl];
        
        [self refreshScrollView];
        
        //        [self performSelector:@selector(setLoopTimer)
        //                   withObject:nil
        //                   afterDelay:INTERVAL
        //         ];
    }
    
    return self;
}

- (void)loadScrollViewWithPage:(UIView *)page
{
    int pageCount = [[scrollView subviews] count];
    
    CGRect bounds = scrollView.bounds;
    bounds.origin.x = bounds.size.width * pageCount;
    bounds.origin.y = bounds.size.height;
    page.frame = bounds;
    [scrollView addSubview:page];
}

- (void)createPages
{
    
    self.curViews = [NSMutableArray array];
    self.viewsArray = [NSMutableArray array];
    
    for (int i=0; i<totalPage; i++) {
        
        self.currentClubPostArray = [[AppManager instance].clubPostArray objectAtIndex:i];
        [self.viewsArray insertObject:[self getLogicView] atIndex:i];
        
        //        [self loadScrollViewWithPage:[self getLogicView]];
    }
    
}

- (void)stopCycle {
    
    isRun = NO;
    if (self._timer != nil) {
        [self._timer invalidate];
        
        self._timer = nil;
    }
}

- (void)refreshScrollView {
    
    NSArray *subViews = [scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayViewCurpage:curPage];
    
    for (int i = 0; i < 3; i++) {
        UIView *logicView = [[UIView alloc] initWithFrame:scrollFrame];
        
        [logicView addSubview:[self.curViews objectAtIndex:i]];
        [logicView setBackgroundColor:TRANSPARENT_COLOR];
        
        logicView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleTap:)];
        [logicView addGestureRecognizer:singleTap];
        [singleTap release];
        
        // 水平滚动
        logicView.frame = CGRectOffset(logicView.frame, scrollFrame.size.width * i, -35.f);
        
        [scrollView addSubview:logicView];
        [logicView release];
    }
    
    [scrollView setContentOffset:CGPointMake(scrollFrame.size.width, 0)];
}

- (NSArray *)getDisplayViewCurpage:(int)page {
    
    int pre = [self validIndex:curPage-1];
    int last = [self validIndex:curPage+1];
    
    if([self.curViews count] != 0)
        [self.curViews removeAllObjects];
    
    [self.curViews addObject:[self.viewsArray objectAtIndex:pre-1]];
    [self.curViews addObject:[self.viewsArray objectAtIndex:curPage-1]];
    [self.curViews addObject:[self.viewsArray objectAtIndex:last-1]];
    
    return self.curViews;
}

- (int)validIndex:(NSInteger)value {
    
    if(value == 0)
        value = totalPage;
    // value＝1为第一张，value = 0为前面一张
    if(value == totalPage+1)
        value = 1;
    
    return value;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    int x = aScrollView.contentOffset.x;
    int y = aScrollView.contentOffset.y;
    NSLog(@"did  x=%d  y=%d", x, y);
    
    // 水平滚动 往下翻一张
    if(x >= (2*scrollFrame.size.width)) {
        curPage = [self validIndex:curPage+1];
        [self refreshScrollView];
    }
    if(x <= 0) {
        curPage = [self validIndex:curPage-1];
        [self refreshScrollView];
    }
    
    if ([delegate respondsToSelector:@selector(cycleScrollViewDelegate:didScrollView:)]) {
        [delegate cycleScrollViewDelegate:self didScrollView:curPage];
        pageControl.currentPage = curPage-1;
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    
    int x = aScrollView.contentOffset.x;
    int y = aScrollView.contentOffset.y;
    
    NSLog(@"--end  x=%d  y=%d", x, y);
    
    [scrollView setContentOffset:CGPointMake(scrollFrame.size.width, 0)];
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if ([delegate respondsToSelector:@selector(cycleSelectViewDelegate:didSelectView:)]) {
        [delegate cycleSelectViewDelegate:self didSelectView:curPage];
    }
}

#pragma mark - init view
- (UILabel *)userName {
    
    //	if (userName == nil) {
    userName = [[UILabel alloc] init];
    userName.backgroundColor = TRANSPARENT_COLOR;
    userName.textColor = [UIColor blackColor];
    userName.highlightedTextColor = [UIColor whiteColor];
    userName.font = FONT(FONT_SIZE);
    userName.numberOfLines = 1;
    userName.lineBreakMode = UILineBreakModeTailTruncation;
    userName.text = [self.currentClubPostArray objectAtIndex:1];
    
    CGSize mDescSize = [userName.text sizeWithFont:userName.font
                                 constrainedToSize:CGSizeMake(SCREEN_WIDTH - 5*MARGIN, CGFLOAT_MAX)
                                     lineBreakMode:UILineBreakModeTailTruncation];
    userName.frame = CGRectMake(MARGIN * 4, MARGIN, mDescSize.width, mDescSize.height);
    userName.backgroundColor = TRANSPARENT_COLOR;
    //	}
	return userName;
}

- (UILabel *)postContent {
    
    //	if (postContent == nil) {
    postContent = [[UILabel alloc] init];
    postContent.backgroundColor = TRANSPARENT_COLOR;
    postContent.textColor = [UIColor darkGrayColor];
    postContent.highlightedTextColor = [UIColor whiteColor];
    postContent.text = [NSString stringWithFormat:@"%@: %@",[self.currentClubPostArray objectAtIndex:2],[self.currentClubPostArray objectAtIndex:3]];
    postContent.font = Arial_FONT(FONT_SIZE-1);
    postContent.numberOfLines = 3;
    postContent.lineBreakMode = UILineBreakModeTailTruncation;
    
    CGSize mPostContentSize = [postContent.text sizeWithFont:postContent.font
                                           constrainedToSize:CGSizeMake(SCREEN_WIDTH - 5*MARGIN, CGFLOAT_MAX)
                                               lineBreakMode:UILineBreakModeTailTruncation];
    
    if (mPostContentSize.height < 20.f) {
        postContent.frame = CGRectMake(MARGIN * 4, MARGIN+20, 240.f, 30.f);
    } else {
        postContent.frame = CGRectMake(MARGIN * 4, MARGIN+20, 240.f, 60.f);
    }
    
    postContent.backgroundColor = TRANSPARENT_COLOR;
    //	}
	return postContent;
}

- (UIView *)getLogicView {
    
    UIView *postView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TOP_VIEW_H)] autorelease];
    [postView setBackgroundColor:TRANSPARENT_COLOR];
    
    UIImageView *_topBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"club_post_bg.png"]];
    _topBgView.frame = CGRectMake(2*MARGIN, 0, SCREEN_WIDTH - 4*MARGIN, TOP_VIEW_H);
    //    _topBgView.frame = scrollFrame;
    [postView addSubview:_topBgView];
    [_topBgView release];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(2*MARGIN, 0, SCREEN_WIDTH - 4*MARGIN, TOP_VIEW_H)];
    //    UIView *topView = [[UIView alloc] initWithFrame:scrollFrame];
    topView.backgroundColor = TRANSPARENT_COLOR;
    
    [topView addSubview:self.userName];
    [topView addSubview:self.postContent];
    
    [postView addSubview:topView];
    [topView release];
    
    return postView;
}

- (void)dealloc
{
    
    self.currentClubPostArray = nil;
    self.viewsArray = nil;
    self.curViews = nil;
    
    self._timer = nil;
    
    RELEASE_OBJ(userName);
    RELEASE_OBJ(postContent);
    
    RELEASE_OBJ(pageControl);
    RELEASE_OBJ(scrollView);
    
    [super dealloc];
}

#pragma mark - auto loop
- (void)setLoopTimer
{
    
    NSDate *date = [NSDate date];
    self._timer = [[[NSTimer alloc] initWithFireDate:date interval:INTERVAL target:self selector:@selector(changePage) userInfo:nil repeats:YES] autorelease];
    [[NSRunLoop currentRunLoop] addTimer:self._timer forMode:NSRunLoopCommonModes];
    isRun = YES;
}

- (void)changePage
{
    if (!isRun) {
        return;
    }
    
    //    curPage = [self validIndex:curPage+1];
    if (curPage >= totalPage) {
        curPage = 1;
    }
    
    int page = [self validIndex:(curPage++)];
    NSLog(@"page is %d", page);
    CGRect frame = scrollView.frame;
    // update the scroll view to the appropriate page
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndScrollingAnimation  -   End of Scrolling.");
}

- (void)autoScrollView {
    
    curPage = [self validIndex:curPage+1];
    
    [self changePage];
    
}

@end
