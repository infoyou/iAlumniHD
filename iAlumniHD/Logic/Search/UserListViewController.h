//
//  UserListViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "PostToolView.h"
#import "ECClickableElementDelegate.h"

@class Alumni;
@class AlumniDetail;
@class Club;

@interface UserListViewController : BaseListViewController <FilterListDelegate, ECClickableElementDelegate, UIActionSheetDelegate>
{
	BOOL willOpenUserProfile;
    BOOL needGoToHome;
    BOOL isFirst;
    
    // trigger go home
    NSString *requestParam;
    NSInteger pageIndex;
    WebItemType _userListType;
    
    PostToolView *_toolTitleView;
    
@private
    Alumni *_alumni;
    
#pragma mark - shake user list
    NSMutableArray *_TableCellShowValArray;
    NSMutableArray *_TableCellSaveValArray;
    
}

@property (nonatomic, copy) NSString *requestParam;
@property (nonatomic, assign) NSInteger pageIndex;

- (id)initWithType:(WebItemType)aType
      needGoToHome:(BOOL)aNeedGoToHome
               MOC:(NSManagedObjectContext*)MOC;

- (id)initWithType:(WebItemType)aType
      needGoToHome:(BOOL)aNeedGoToHome
               MOC:(NSManagedObjectContext*)MOC
             group:(Club *)group;

- (void)showAlumniDetailByNet:(Alumni*)aAlumni needAddContact:(BOOL)needAddContact;
- (void)showAlumniDetailByLocal:(Alumni *)aAlumni needAddContact:(BOOL)needAddContact;
- (void)setTableCellVal:(int)index aShowVal:(NSString*)aShowVal aSaveVal:(NSString*)aSaveVal isFresh:(BOOL)isFresh;

- (void)openProfile:(NSString*)authorId userType:(NSString*)userType;

@end