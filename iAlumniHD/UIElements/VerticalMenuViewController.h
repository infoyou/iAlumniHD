//
//  VerticalMenuViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-10-3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"
#import "WXApi.h"

@class UserProfileCell;

@interface VerticalMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIPopoverControllerDelegate, UITabBarControllerDelegate, WXApiDelegate, UIActionSheetDelegate>
{
    
    id<WXApiDelegate> _wxApiDelegate;
    
@private
    CGRect _frame;
    
    UITableView *_tableView;
    NSArray *_baseMenuTitles;
    NSManagedObjectContext *_MOC;
    
    UIView *_sectionHeaderView;
}

@property (nonatomic, retain) id<WXApiDelegate> wxApiDelegate;

- (id)initWithFrame:(CGRect)frame MOC:(NSManagedObjectContext *)MOC;
- (void)selectRow:(HomeMenuType)type;

- (void)selectedCell:(NSInteger)showIndex;

- (void)drawProfileCell;


#pragma mark - open shared
- (void)openSharedEventById:(long long)eventId eventType:(int)eventType;

- (void)setAutoSelectEventTabFlagWithId:(long long)eventId eventType:(int)eventType;

- (void)openSharedBrandWithId:(long long)brandId;

- (void)openSharedVideoWithId:(long long)videoId;

@end
