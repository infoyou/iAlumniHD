//
//  ProfileToolView.m
//  iAlumniHD
//
//  Created by MobGuang on 12-11-15.
//
//

#import "ProfileToolView.h"
#import "WXWImageButton.h"
#import "CommonUtils.h"
#import "TextConstants.h"

#define BUTTON_WIDTH    130.0f
#define BUTTON_HEIGHT   30.0f

#define DM_IMG_EDGE       UIEdgeInsetsMake(0.0, -40.0, 0.0, 0.0)
#define ACCEPTED_IMG_EDGE UIEdgeInsetsMake(0.0, -30.0, 0.0, 0.0)
#define ADD_IMG_EDGE      UIEdgeInsetsMake(0.0, -15.0, 0.0, 0.0)
#define TITLE_EDGE        UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)

#define SPIN_VIEW_SIDE_LENGTH 26.0f


@interface ProfileToolView()
@property (nonatomic, retain) UIActivityIndicatorView *spinView;
@end

@implementation ProfileToolView


#pragma mark - user actions

- (void)enterDMList:(id)sender {
  if (_profileDelegate) {
    [_profileDelegate sendDirectMessage];
  }
}

- (void)addToAddressbook:(id)sender {
  if (_profileDelegate) {
    [_profileDelegate addToAddressbook];
  }
}

- (void)changeSaveStatus:(id)sender {
  if (_profileDelegate) {
    [_profileDelegate changeSaveStatus];
  }
}

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame
    profileDelegate:(id<ECClickableElementDelegate>)profileDelegate
{
  self = [super initWithFrame:frame];
  if (self) {
    
    _profileDelegate = profileDelegate;
    
    WXWImageButton *DMButton = [[[WXWImageButton alloc] initImageButtonWithFrame:CGRectMake(0,
                                                                                          0, BUTTON_WIDTH, BUTTON_HEIGHT)
                                                                        target:self
                                                                        action:@selector(enterDMList:)
                                                                         title:LocaleStringForKey(NSChatTitle, nil)
                                                                         image:[UIImage imageNamed:@"chat.png"]
                                                                   backImgName:@"club_button.png"
                                                                selBackImgName:@"club_button_selected.png"
                                                                     titleFont:BOLD_FONT(12)
                                                                    titleColor:[UIColor blackColor]
                                                              titleShadowColor:TEXT_SHADOW_COLOR
                                                                   roundedType:HAS_ROUNDED
                                                               imageEdgeInsert:DM_IMG_EDGE
                                                               titleEdgeInsert:ZERO_EDGE] autorelease];
    [self addSubview:DMButton];
    
    _favoriteButton = [[[WXWImageButton alloc] initImageButtonWithFrame:CGRectMake(self.frame.size.width - BUTTON_WIDTH,
                                                                                  0, BUTTON_WIDTH, BUTTON_HEIGHT)
                                                                target:self
                                                                action:@selector(changeSaveStatus:)
                                                                 title:LocaleStringForKey(NSSaveAlumniTitle, nil)
                                                                 image:[UIImage imageNamed:@"greenAdd.png"]
                                                           backImgName:@"club_button.png"
                                                        selBackImgName:@"club_button_selected.png"
                                                             titleFont:BOLD_FONT(12)
                                                            titleColor:[UIColor blackColor]
                                                      titleShadowColor:TEXT_SHADOW_COLOR
                                                           roundedType:HAS_ROUNDED
                                                       imageEdgeInsert:ADD_IMG_EDGE
                                                       titleEdgeInsert:TITLE_EDGE] autorelease];
    [self addSubview:_favoriteButton];
    
  }
  return self;
}

- (void)dealloc {
  
  self.spinView = nil;
  
  [super dealloc];
}

#pragma mark - update favorite status

- (void)setFavoriteButtonStatus {
    NSString *imageName = nil;
    NSString *title = nil;
    UIEdgeInsets imageEdgeInsert = ADD_IMG_EDGE;
    
    switch (_relationshipType) {
        case WANT_TO_KNOW_TY:
            title = LocaleStringForKey(NSWantToKnowAlumniTitle, nil);
            imageName = @"acceptGreen24.png";
            break;
            
        case KNOWN_TY:
            title = LocaleStringForKey(NSKnownAlumnusTitle, nil);
            imageName = @"acceptGreen24.png";
            break;
            
        default:
            title = LocaleStringForKey(NSSaveAlumniTitle, nil);
            imageName = @"greenAdd.png";
            break;
    }
    
    [_favoriteButton setButtonPropertiesWithFrame:_favoriteButton.frame
                                            title:title
                                            image:[UIImage imageNamed:imageName]
                                      backImgName:@"club_button.png"
                                   selBackImgName:@"club_button_selected.png"
                                       titleColor:[UIColor blackColor]
                                 titleShadowColor:TEXT_SHADOW_COLOR
                                  imageEdgeInsert:imageEdgeInsert
                                  titleEdgeInsert:TITLE_EDGE];
}

- (void)updateFavoriteStatusWithType:(AlumniRelationshipType)relationType {
    
    _relationshipType = relationType;
    
    [self setFavoriteButtonStatus];
}

- (void)stopSpingForSuccess:(BOOL)success {

  if (self.spinView) {
    self.spinView.hidden = YES;
    [self.spinView stopAnimating];
    
    if (success) {
        [self setFavoriteButtonStatus];
    } else {
      [_favoriteButton setImage:[UIImage imageNamed:@"greenAdd.png"] forState:UIControlStateNormal];
    }
  }
}

- (void)startSpinView {
  if (nil == self.spinView) {
    self.spinView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.spinView.frame = CGRectMake(MARGIN * 2 + 3.0f, (BUTTON_HEIGHT - SPIN_VIEW_SIDE_LENGTH)/2.0f, SPIN_VIEW_SIDE_LENGTH, SPIN_VIEW_SIDE_LENGTH);
    
    [_favoriteButton addSubview:self.spinView];
  }
  
  self.spinView.hidden = NO;
  [self.spinView startAnimating];
  
  [_favoriteButton setImage:nil forState:UIControlStateNormal];
}

@end
