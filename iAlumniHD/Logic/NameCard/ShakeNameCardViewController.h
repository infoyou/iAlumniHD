//
//  ShakeNameCardViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-12-11.
//
//

#import "RootViewController.h"

@interface ShakeNameCardViewController : RootViewController <UIGestureRecognizerDelegate, UIAccelerometerDelegate>
{
    
@private
    SystemSoundID   shakeSoundID;
    UIImageView *_leftIcon;
    UIImageView *_rightIcon;
    BOOL    isShakeAction;
    BOOL    _processing;
}

@end
