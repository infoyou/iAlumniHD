//
//  LoginViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-03-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "HomepageViewController.h"
#import "UIUrlLabel.h"

@interface LoginViewController : RootViewController <UIAlertViewDelegate, UIUrlLabelDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UIWebViewDelegate> {
    
    BOOL _nameFieldIsFirstResponder;
    BOOL _pswdFieldIsFirstResponder;
    
    CGFloat _animatedDistance;
    
    UILabel *loginNoteLabel;
    BOOL isBreakFlag;
    BOOL _autoLogin;
    BOOL _hostFetched;
}

@property (nonatomic, retain) UILabel *loginNoteLabel;
@property (nonatomic, retain) HomepageViewController *homepageVC;

- (id)initWithMOC:(NSManagedObjectContext *)MOC autoLogin:(BOOL)autoLogin;
- (void)entryAlumnus;

@end
