//
//  AdminCheckInViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "ECClickableElementDelegate.h"

@class Alumni;

@interface AdminCheckInViewController : RootViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, ECClickableElementDelegate> {
    
    UIView *bgView;
    UITextField *_codeField;
    UITextField *_nameField;
    UITextField *_classField;
    
    BOOL _isCheckedStatus;
    
    Alumni *_alumni;
    
    NSMutableArray *_TableCellShowValArray;
    NSMutableArray *_TableCellSaveValArray;
    
    CGFloat _animatedDistance;
    
    NSMutableArray *classFliters;
    
    NSInteger   type;
}

@property (nonatomic,retain) NSMutableArray *_SelCheckResult;

@property (nonatomic,retain) NSMutableArray *classFliters;
@property (nonatomic,assign) NSInteger type;

- (id)initWithMOC:(NSManagedObjectContext *)MOC event:(Event *)event;
- (void)clearFliter;
- (void)setTableCellVal:(int)index aShowVal:(NSString*)aShowVal aSaveVal:(NSString*)aSaveVal isFresh:(BOOL)isFresh;

@end
