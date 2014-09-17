//
//  SearchClubViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-20.
//
//

#import "RootViewController.h"
#import "UICascadeView.h"

@interface SearchClubViewController : RootViewController <UITableCascadeDelegate, UISearchBarDelegate> {
    
    UIView *searchBarBGView;
    UISearchBar *searchBar;
    WXWGradientButton *closeSearchBarBut;
    UICascadeView *uiCascadeView;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@property (nonatomic, retain) UIView *searchBarBGView;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) WXWGradientButton *closeSearchBarBut;
@property (nonatomic, retain) UICascadeView *uiCascadeView;

@end
