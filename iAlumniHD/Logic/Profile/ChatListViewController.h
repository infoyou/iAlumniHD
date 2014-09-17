//
//  ChatListViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "ChatFaceViewController.h"
#import "ECClickableElementDelegate.h"
#import "UIInputToolbar.h"
#import "AlumniDetail.h"

@interface ChatListViewController : BaseListViewController <UIInputToolbarDelegate, UIPopoverControllerDelegate, UIGestureRecognizerDelegate, ECClickableElementDelegate> {
    
    AlumniDetail        *_alumni;
    UIInputToolbar      *inputToolbar;
    
    BOOL                keyboardWasShown;
    int                 flag;
    
    NSString            *startChatId;
    NSString            *endChatId;
    
	NSString                   *_phraseString;
    NSMutableString            *_messageString;
    ChatFaceViewController     *_faceViewController;
    
    UIView  *promptView;
    UILabel *promptLabel;
    
@private
    BOOL keyboardIsVisible;
}

@property (nonatomic, retain) UIInputToolbar *inputToolbar;
@property (nonatomic, copy) NSString    *startChatId;
@property (nonatomic, copy) NSString    *endChatId;
@property (nonatomic, retain) NSString               *phraseString;
@property (nonatomic, retain) NSMutableString        *messageString;
@property (nonatomic, retain) ChatFaceViewController *faceViewController;
@property (nonatomic, retain) UIView *promptView;
@property (nonatomic, retain) UILabel *promptLabel;

- (id)initWithMOC:(NSManagedObjectContext *)MOC alumni:(AlumniDetail*)alumni;
- (void)openProfile:(NSString*)personId userType:(NSString*)userType;

@end
