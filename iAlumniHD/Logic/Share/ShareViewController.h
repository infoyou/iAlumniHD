//
//  ShareViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "FilterListDelegate.h"
#import "ItemUploaderDelegate.h"
#import "ECClickableElementDelegate.h"
#import "ECEditorDelegate.h"

@class PostToolView;
@interface ShareViewController : BaseListViewController <FilterListDelegate, ItemUploaderDelegate, ECClickableElementDelegate, ECEditorDelegate> {
    
@private
    
    PostToolView *_toolTitleView;
    
    NSString *_filterCountryId;
    NSString *_currentTagIds;
    NSString *_distanceParams;
    NSString *_filterCityId;
    NSString *_currentFiltersTitle;
    
    NSTimeInterval _currentLatestTimeline;
    long long _currentLatestFeedId;
    NSTimeInterval _currentOldestTimeline;
    long long _currentOldestFeedId;
    
    SortType _sortType;
    
    CGFloat _currentContentOffset_y;
    
    BOOL _autoLoadAfterSent;
    
    BOOL _returnFromComposer;
    
    BOOL _selectedFeedBeDeleted;
    
    ItemListType _listType;
    
    ItemFavoriteCategory _favoriteItemType;
  
    BOOL _filtersChanged;
    
    BOOL _sortOptionsChanged;
  
    BOOL _tagsFetched;
    
    NSString *_targetUserId;
    
    NSInteger _pageIndex;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
         listType:(ItemListType)listType;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
     targetUserId:(NSString *)targetUserId;

- (void)openProfile:(NSString*)personId userType:(NSString*)userType;

@end
