//
//  StartUpListViewController.h
//  iAlumniHD
//
//  Created by Adam on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"

@interface StartUpListViewController : BaseListViewController {
  
@private
    
    CGRect _originalTableViewFrame;
    
    BOOL _tableViewDisplayed;
    
    BOOL _keepEventsInMOC;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

- (void)clearFliter;

@end
