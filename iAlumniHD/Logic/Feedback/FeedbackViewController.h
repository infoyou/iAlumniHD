//
//  FeedbackViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class Feedback;

@interface FeedbackViewController : BaseViewController <UITableViewDelegate,UITableViewDataSource, UITextViewDelegate, UIActionSheetDelegate, UIWebViewDelegate, MFMailComposeViewControllerDelegate>
{

    UITextView *_textView;
    
    NSMutableArray *_selCellArray;
    NSString *checkMsg;
    
    BOOL _autoLoad;
    Feedback *_feedback;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
