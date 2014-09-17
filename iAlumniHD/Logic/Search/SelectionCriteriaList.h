//
//  SelectionCriteriaList.h
//  iAlumniHD
//
//  Created by Adam on 12-10-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"

@interface SelectionCriteriaList : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    UIPopoverController *_popController;
    
@private
    CGRect _frame;
    UITableView *_tableView;
    id _target;
    SEL _itemSelectedAction;
    
    NSManagedObjectContext *_MOC;
    NSFetchedResultsController *_fetchedRC;
    
    WebItemType _itemType;
    
    id _currentSelectedItem;
    
    BOOL _selectSameItem;
}

@property (nonatomic, retain) UIPopoverController *_popController;

- (id)initWithFrame:(CGRect)frame 
                MOC:(NSManagedObjectContext *)MOC
           itemType:(WebItemType)itemType 
             target:(id)target 
 itemSelectedAction:(SEL)itemSelectedAction
currentSelectedItem:(id)currentSelectedItem;

@end
