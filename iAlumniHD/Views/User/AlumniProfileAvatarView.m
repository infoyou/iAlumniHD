//
//  AlumniProfileAvatarView.m
//  iAlumniHD
//
//  Created by MobGuang on 12-11-13.
//
//

#import "AlumniProfileAvatarView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "ECInnerShadowImageView.h"
#import "CommonUtils.h"
#import "Alumni.h"
#import "AlumniProfileTopBackgroundView.h"
#import "ProfileToolView.h"
#import "AppManager.h"
#import "LinkEntranceView.h"
#import "AlumniLocationStatusView.h"
#import "WXWUIUtils.h"
#import "CoreDataUtils.h"
#import "WithMeConnectionView.h"

#define AVATAR_RADIUS               40.0f

#define IMAGE_HEIGHT AVATAR_RADIUS * 2
#define IMAGE_WIDTH  AVATAR_RADIUS * 2

#define TOP_BACKGROUND_VIEW_HEIGHT 75.0f

#define BUTTON_BAR_HEIGHT           30.0f

#define LINK_ENTRANCE_HEIGHT        50.0f

#define STATUS_VIEW_HEIGHT          90.0f

@interface AlumniProfileAvatarView()
@property (nonatomic, retain) Alumni *alumni;
@property (nonatomic, copy) NSString *personId;
@end

@implementation AlumniProfileAvatarView

#pragma mark - user action
- (void)showBigAvatar:(UITapGestureRecognizer *)recognizer {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate showBigPhoto:self.alumni.imageUrl];
  }
}

#pragma mark - lifecycle methods

- (BOOL)needToolView {
  if ([[AppManager instance].personId isEqualToString:self.personId]) {
    return NO;
  } else {
    return YES;
  }
}

- (BOOL)needMapView {
  if ((self.alumni.latitude.doubleValue > 0 && self.alumni.longitude.doubleValue > 0) &&
      ![self.personId isEqualToString:[AppManager instance].personId] && !_hideLocation) {
    return YES;
  } else {
    return NO;
  }
}

- (void)initViews {
  
  self.backgroundColor = CELL_COLOR;
  
  _topBackgroundView = [[[AlumniProfileTopBackgroundView alloc] initWithFrame:CGRectMake(0,
                                                                                         0,
                                                                                         self.frame.size.width,
                                                                                         TOP_BACKGROUND_VIEW_HEIGHT)
                                                                       alumni:self.alumni] autorelease];
  [self addSubview:_topBackgroundView];
  
  _avatarImageView = [[[ECInnerShadowImageView alloc] initCircleWithCenterPoint:CGPointMake(self.frame.size.width/2.0f, MARGIN * 2 + AVATAR_RADIUS)
                                                                         radius:AVATAR_RADIUS] autorelease];
  [_avatarImageView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(showBigAvatar:)] autorelease]];
  [self addSubview:_avatarImageView];
  
  if ([self needToolView]) {
    // send direct message and add addressbook buttons
    _toolView = [[[ProfileToolView alloc] initWithFrame:CGRectMake(30.f, TOP_BACKGROUND_VIEW_HEIGHT + MARGIN * 4, self.frame.size.width-60.f, BUTTON_BAR_HEIGHT)
                                        profileDelegate:_clickableElementDelegate] autorelease];
    
    [self addSubview:_toolView];
    
    _bottomLineY = _toolView.frame.origin.y + _toolView.frame.size.height + MARGIN * 2;
    
    if (_clickableElementDelegate) {
      
      // entrance of people links
      
      _linkEntranceView = [[[LinkEntranceView alloc] initWithFrame:CGRectMake(30.f, _toolView.frame.origin.y + _toolView.frame.size.height + MARGIN * 2, self.frame.size.width - 60.f, LINK_ENTRANCE_HEIGHT) clickableElementDelegate:_clickableElementDelegate] autorelease];
      
      [self addSubview:_linkEntranceView];
      
      //[_linkEntranceView beginFlicker];
      
      _bottomLineY = _linkEntranceView.frame.origin.y + _linkEntranceView.frame.size.height + MARGIN * 2;
      
      /*
       // with me connections
       _withMeConnectionView = [[[WithMeConnectionView alloc] initWithFrame:CGRectMake(MARGIN * 2, _bottomLineY, self.frame.size.width - MARGIN * 4, LINK_ENTRANCE_HEIGHT) clickableElementDelegate:_clickableElementDelegate] autorelease];
       [self addSubview:_withMeConnectionView];
       
       _bottomLineY = _withMeConnectionView.frame.origin.y + _withMeConnectionView.frame.size.height + MARGIN * 2;
       */
      
      // embedded map view
      if ([self needMapView]) {
        _alumniStatusView = [[[AlumniLocationStatusView alloc] initWithFrame:CGRectMake(30.f, _linkEntranceView.frame.origin.y + _linkEntranceView.frame.size.height + MARGIN * 2, self.frame.size.width - 60.f, STATUS_VIEW_HEIGHT)
                                                                   mapHolder:_clickableElementDelegate
                                                                      alumni:self.alumni] autorelease];
        [self addSubview:_alumniStatusView];
        
        _bottomLineY = _alumniStatusView.frame.origin.y + _alumniStatusView.frame.size.height + MARGIN * 2;
      }
    }
  }
}

- (void)fetchImage {
  if (self.alumni.imageUrl.length > 1) {
    [self fetchImage:[NSMutableArray arrayWithObject:self.alumni.imageUrl]
            forceNew:NO];
  }
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
           personId:(NSString *)personId
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
      profileHolder:(id)profileHolder
   saveAvatarAction:(SEL)saveAvatarAction
       hideLocation:(BOOL)hideLoation {
  
  self = [super initWithFrame:frame];
  
  if (self) {
    
    self.personId = personId;
    
    _profileHolder = profileHolder;
    
    _saveAvatarAction = saveAvatarAction;
    
    _hideLocation = hideLoation;
    
    self.alumni = (Alumni *)[CoreDataUtils fetchObjectFromMOC:MOC
                                                   entityName:@"Alumni"
                                                    predicate:[NSPredicate predicateWithFormat:@"(personId == %@)", personId]];
    
    _clickableElementDelegate = clickableElementDelegate;
    
    [self initViews];
    
    [self fetchImage];
  }
  return self;
}

- (void)dealloc {
  
  self.alumni = nil;
  
  [super dealloc];
}

#pragma mark - set alumni entity for refresh
- (void)refreshAfterAlumniLoaded:(Alumni *)alumni {
  self.alumni = alumni;
  
  [self fetchImage];
  
  [_topBackgroundView refreshAfterAlumniLoaded:alumni];
}

#pragma mark - draw view methods

- (void)arrangeToolViews {
  if ([self needToolView]) {
    
    CGFloat y = self.frame.size.height;
    
    if ([self needMapView]) {
      
      y = y - MARGIN * 2 - _alumniStatusView.frame.size.height;
      
      _alumniStatusView.frame = CGRectMake(_alumniStatusView.frame.origin.x,
                                           y,
                                           _alumniStatusView.frame.size.width,
                                           _alumniStatusView.frame.size.height);
      
    }
    
    /*
     y = y - MARGIN * 2 - _withMeConnectionView.frame.size.height;
     _withMeConnectionView.frame = CGRectMake(_withMeConnectionView.frame.origin.x,
     y,
     _withMeConnectionView.frame.size.width,
     _withMeConnectionView.frame.size.height);
     */
    
    y = y - MARGIN * 2 - _linkEntranceView.frame.size.height;
    _linkEntranceView.frame = CGRectMake(_linkEntranceView.frame.origin.x,
                                         y,
                                         _linkEntranceView.frame.size.width,
                                         _linkEntranceView.frame.size.height);
    
    y = y - MARGIN * 2 - _toolView.frame.size.height;
    _toolView.frame = CGRectMake(_toolView.frame.origin.x,
                                 y,
                                 _toolView.frame.size.width,
                                 _toolView.frame.size.height);
    
    _bottomLineY = self.frame.size.height;
    
    
    [self setNeedsDisplay];
  }
}

- (void)arrangeProfileBio {
  if (self.alumni.profile && self.alumni.profile.length > 0) {
    _bioLabel = [[self initLabel:CGRectZero
                       textColor:BASE_INFO_COLOR
                     shadowColor:TEXT_SHADOW_COLOR
                            font:BOLD_FONT(13)] autorelease];
    _bioLabel.textAlignment = UITextAlignmentCenter;
    _bioLabel.numberOfLines = 0;
    [self addSubview:_bioLabel];
    
    _bioLabel.text = self.alumni.profile;
    
    CGSize size = [_bioLabel.text sizeWithFont:_bioLabel.font
                             constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 4,
                                                          CGFLOAT_MAX)
                                 lineBreakMode:UILineBreakModeWordWrap];
    
    _bioLabel.frame = CGRectMake((self.frame.size.width - size.width)/2.0f, TOP_BACKGROUND_VIEW_HEIGHT + MARGIN * 4, size.width, size.height);
  }
}

- (void)updateBadges {
  
  [_linkEntranceView updateBadge:self.alumni.allKnownAlumniCount.intValue];
  
  //[_withMeConnectionView updateBadge:self.alumni.withMeConnectionCount.intValue];
}

#pragma mark - update favorite status
- (void)updateFavoriteStatusWithType:(AlumniRelationshipType)relationType {
  [_toolView updateFavoriteStatusWithType:relationType];
}

- (void)startSpinView {
  [_toolView startSpinView];
}

- (void)stopSpingForSuccess:(BOOL)success {
  [_toolView stopSpingForSuccess:success];
}

#pragma mark - draw rect
- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGFloat pattern[2] = {1, 2};
  
  [WXWUIUtils draw1PxDashLine:context
                startPoint:CGPointMake(MARGIN * 2, _bottomLineY - 0.5f)
                  endPoint:CGPointMake(self.frame.size.width - MARGIN * 2, _bottomLineY - 0.5f)
                  colorRef:SEPARATOR_LINE_COLOR.CGColor
              shadowOffset:CGSizeMake(0, 1.0f)
               shadowColor:TEXT_SHADOW_COLOR
                   pattern:pattern];
}

#pragma mark - ImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  [_avatarImageView.layer addAnimation:[self imageTransition] forKey:nil];
  
  _avatarImageView.imageView.image = [CommonUtils cutPartImage:image
                                                         width:IMAGE_WIDTH
                                                        height:IMAGE_HEIGHT];
  
  if (_profileHolder && _saveAvatarAction) {
    [_profileHolder performSelector:_saveAvatarAction withObject:image];
  }
  
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  
  _avatarImageView.imageView.image = [CommonUtils cutPartImage:image
                                                         width:IMAGE_WIDTH
                                                        height:IMAGE_HEIGHT];
  if (_profileHolder && _saveAvatarAction) {
    [_profileHolder performSelector:_saveAvatarAction withObject:image];
  }
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}



@end
