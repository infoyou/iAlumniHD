//
//  NameCardSearchToolView.h
//  iAlumniHD
//
//  Created by MobGuang on 12-11-24.
//
//

#import <UIKit/UIKit.h>
#import "WXWGradientView.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"


@class WXWLabel;
@class WXWImageButton;

@interface NameCardSearchToolView : WXWGradientView {
  @private
  
  UISearchBar *_searchBar;
  
  WXWLabel *_industryTitleLabel;
  
  WXWImageButton *_industryButton;
  
  id<ECClickableElementDelegate> _searchManager;
}

- (id)initWithFrame:(CGRect)frame
  searchBarDelegate:(id<UISearchBarDelegate>)searchBarDelegate
      searchManager:(id<ECClickableElementDelegate>)searchManager;

#pragma mark - update views
- (void)updateIndustryTitle:(NSString *)industry;

#pragma mark - search bar properties
- (BOOL)searchBarFirstResponse;
- (void)searchBarResignFirstResponder;
- (void)selectKeyworkdFromHistory:(NSString *)keyword;

@end
