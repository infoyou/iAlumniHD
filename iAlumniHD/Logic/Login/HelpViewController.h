//
//  HelpViewController.h
//  iAlumniHD
//
//  Created by Adam on 13-3-8.
//
//

#import "RootViewController.h"

@interface HelpViewController : RootViewController <UIAlertViewDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate> {
    
    CGFloat _animatedDistance;
    BOOL isBreakFlag;
    BOOL _hostFetched;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end

