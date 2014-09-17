//
//  EventListViewController.h
//  iAlumniHD
//
//  Created by Adam on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "TapSwitchDelegate.h"


@class PlainTabView;

@interface EventListViewController : BaseListViewController <TapSwitchDelegate> {
  
@private
    
    PlainTabView *_tabSwitchView;
    
    CGRect _originalTableViewFrame;
    
    BOOL _tableViewDisplayed;
    
    BOOL _keepEventsInMOC;
    
    // if user switch the tab during table scrolling, the footer view of short list maybe
    // display "loading...", we need reset it after scrolling stop after user switch
    BOOL _userJustSwitched;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         tabIndex:(int)tabIndex;

- (void)clearFliter;

@end
