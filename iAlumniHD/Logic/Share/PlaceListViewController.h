//
//  PlaceListViewController.h
//  iAlumniHD
//
//  Created by Mobguang on 11-11-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "ComposerDelegate.h"

@interface PlaceListViewController : BaseListViewController {
    
    UIPopoverController *_popVC;
    
    id<ComposerDelegate> _composerDelegate;
}

@property (nonatomic, retain) UIPopoverController *_popVC;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
 composerDelegate:(id<ComposerDelegate>)composerDelegate;

@end
