//
//  SearchListViewController.h
//  iAlumniHD
//
//  Created by Mobguang on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "FilterListDelegate.h"

@interface SearchListViewController : BaseListViewController <UISearchBarDelegate, UISearchDisplayDelegate> {
  @private
  UISearchDisplayController *_itemSearchDisplayController;
  
  id<FilterListDelegate> _filterListDelegate;
  
  NSString *_keywords;
  
  BOOL _beginSearch;

  NSMutableArray *_recentSearchKeywords;
  
  UISearchBar *_searchBar;
}

- (id)initNoSwipeBackWithMOC:(NSManagedObjectContext *)MOC 
                      holder:(id)holder 
            backToHomeAction:(SEL)backToHomeAction

          filterListDelegate:(id<FilterListDelegate>)filterListDelegate;

@end
