//
//  ProfileToolView.h
//  iAlumniHD
//
//  Created by MobGuang on 12-11-15.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class WXWImageButton;

@interface ProfileToolView : UIView {
  @private
  
  id<ECClickableElementDelegate> _profileDelegate;
  
  WXWImageButton *_favoriteButton;
    AlumniRelationshipType _relationshipType;
}

- (id)initWithFrame:(CGRect)frame
    profileDelegate:(id<ECClickableElementDelegate>)profileDelegate;

#pragma mark - update favorite status
- (void)updateFavoriteStatusWithType:(AlumniRelationshipType)relationType;

- (void)startSpinView;
- (void)stopSpingForSuccess:(BOOL)success;

@end
