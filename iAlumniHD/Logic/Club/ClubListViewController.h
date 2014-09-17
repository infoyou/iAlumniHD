//
//  ClubListViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-24.
//
//

#import "BaseListViewController.h"

@interface ClubListViewController : BaseListViewController <UIGestureRecognizerDelegate>
{
    
    UIImageView                 *_likeIcon;
    WXWLabel                     *_likeCountLabel;
    UIImageView                 *_commentIcon;
    WXWLabel                     *_commentCountLabel;
    
    WXWLabel                     *_classLabel;
    
    // 1时按协会名称排序，2时按新帖时间顺序
    NSString *sortType;
    NSString *onlyMine;
    
    ClubListViewType            _listType;
    
@private
    
    NSInteger _pageIndex;
    NSString *_requestParam;
    
    NSMutableArray *clubFliters;

}

@property (nonatomic, copy) NSString *sortType;
@property (nonatomic, copy) NSString *onlyMine;

@property (nonatomic, copy) NSString *requestParam;
@property (nonatomic, assign) NSInteger pageIndex;

@property (retain, nonatomic) NSMutableArray *clubFliters;
@property (nonatomic, retain) UIImageView *_likeIcon;
@property (nonatomic, retain) WXWLabel *_likeCountLabel;
@property (nonatomic, retain) UIImageView *_commentIcon;
@property (nonatomic, retain) WXWLabel *_commentCountLabel;

- (id)initWithMOC:(NSManagedObjectContext *)MOC listType:(ClubListViewType)listType;

@end
