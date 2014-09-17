//
//  ShakeViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

@interface ShakeViewController : RootViewController <UIGestureRecognizerDelegate, UIAccelerometerDelegate>
{
    UIImageView    *imageView;
    SystemSoundID   shakeSoundID;
    SystemSoundID   shakeEndID;
    
    UIImage        *shakeStartImg;
    UIImage        *shakeEndImg;
    
    BOOL            _isShakeImg;
    BOOL            isRun;
    BOOL            isShakeAction;
    BOOL            _processing;
    
    BOOL histeresisExcited;
    UIAcceleration* lastAcceleration;
    
    long long _eventId;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImage *shakeStartImg;
@property (nonatomic, retain) UIImage *shakeEndImg;

- (id)initWithMOC:(NSManagedObjectContext *)MOC;
- (id)initWithMOC:(NSManagedObjectContext *)MOC eventId:(long long)eventId;

- (void)loadData;
- (void)initResource;

@end
