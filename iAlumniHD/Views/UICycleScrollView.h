//
//  UICycleScrollView.h
//  iAlumniHD
//
//  Created by Adam on 12-11-20.
//
//

#import <UIKit/UIKit.h>
#import "WXWLabel.h"

@interface UICycleScrollView : UIView <UIScrollViewDelegate> {
    
    UIScrollView *scrollView;
    UIImageView *curImageView;
    UIPageControl *pageControl;
    
    CGRect scrollFrame;
    
    NSMutableArray *currentClubPostArray;
    
    id delegate;
    
    UIView *curPageView;

    NSMutableArray *viewsArray;
    NSMutableArray *curViews;
    
    NSTimer         *_timer;
    BOOL            isRun;
    UIScrollView    *topPostView;
    UIView          *bottomView;
    UILabel			*userName;
    UILabel         *postContent;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) UIScrollView *scrollView;

@property (nonatomic, retain) UILabel *userName;
@property (nonatomic, retain) UILabel *postContent;

@property (nonatomic, retain) NSTimer *_timer;
@property (nonatomic, retain) NSMutableArray *currentClubPostArray;

@property (nonatomic, retain) NSMutableArray *viewsArray;
@property (nonatomic, retain) NSMutableArray *curViews;

- (id)initWithFrame:(CGRect)frame;
- (int)validIndex:(NSInteger)value;
- (void)refreshScrollView;
- (void)stopCycle;
- (void)dealloc;

@end

@protocol UICycleScrollViewDelegate <NSObject>

@optional
- (void)cycleSelectViewDelegate:(UICycleScrollView *)cycleScrollView didSelectView:(int)index;
- (void)cycleScrollViewDelegate:(UICycleScrollView *)cycleScrollView didScrollView:(int)index;

@end