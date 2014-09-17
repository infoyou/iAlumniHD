//
//  NearbyEntranceViewController.h
//  iAlumniHD
//
//  Created by MobGuang on 12-9-11.
//
//

#import "BaseListViewController.h"
#import "TapSwitchDelegate.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class Shake;
@class PlainTabView;
@class WinnerHeaderView;

@interface NearbyEntranceViewController : BaseListViewController <TapSwitchDelegate, ECClickableElementDelegate, ECClickableElementDelegate, UIActionSheetDelegate> {
  @private
  
  PlainTabView *_tabSwitchView;
  
  Shake *_shake;
  
  WinnerHeaderView *_winnerHeaderView;
  
  UIImageView *_backgroundImage;
  
  UIButton *_couponButton;
  UIButton *_alumnusButton;
  
  BOOL _userRefreshList;
  
  BOOL _currentLocationIsLatest;
  
  BOOL _winnerLoaded;
  
  UIButton *_contactUsButton;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC brandId:(long long)brandId;

@end
