//
//  ClubHeadView.h
//  iAlumniHD
//
//  Created by Adam on 12-8-16.
//
//

#import "RootViewController.h"
#import "ClubManagementDelegate.h"

@class ClubSimple;
@class WXWImageButton;

@interface ClubHeadView : UIView
{
    id<ClubManagementDelegate> _delegate;
    
    CGRect  _frame;
    UIView  *_headerView;
    NSManagedObjectContext *_MOC;
    
    WebItemType _currentType;
    
    BOOL    joinStatus;
    
    ClubSimple *_clubSimple;
  
    WXWImageButton *_memberBut;
  
    WXWImageButton *_joinAndQuitBut;
  
    UIView *_member2ActivityView;
  
    BOOL _autoLoaded;
}

@property (nonatomic, assign) BOOL joinStatus;

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext*)MOC
   clubHeadDelegate:(id<ClubManagementDelegate>)clubHeadDelegate;

- (void)loadData;

@end
