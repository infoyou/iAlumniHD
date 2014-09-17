//
//  StartUpDetailHeadView.h
//  iAlumniHD
//
//  Created by Adam on 13-1-25.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "EventActionDelegate.h"
#import "ImageFetcherDelegate.h"

@class WXWLabel;
@class Event;
@class WXWImageButton;

@interface StartUpDetailHeadView : UIView <UIGestureRecognizerDelegate,ImageFetcherDelegate>{
    
@private

    UIButton *_postImgButton;
    WXWLabel *_nameLabel;
    WXWLabel *_timeLabel;
    id<EventActionDelegate> _delegate;
    UIView *_activityView;
  
  WXWImageButton *_eventSignBut;
  
  WXWImageButton *_eventCheckinBut;
  
  id _imageHolder;
  
  SEL _saveImageAction;
}

@property (nonatomic, retain) Event *event;

- (id)initWithFrame:(CGRect)frame
              event:(Event *)event
           delegate:(id<EventActionDelegate>)delegate
        imageHolder:(id)imageHolder
    saveImageAction:(SEL)saveImageAction;

@end

