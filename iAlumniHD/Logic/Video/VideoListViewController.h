//
//  VideoListViewController.h
//  iAlumniHD
//
//  Created by Adam on 13-1-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "ECClickableElementDelegate.h"
#import "FilterListDelegate.h"
#import "WXApi.h"

@interface VideoListViewController : BaseListViewController <FilterListDelegate, ECClickableElementDelegate, UIActionSheetDelegate, UIAlertViewDelegate, WXApiDelegate>
{

    BOOL isReloadView;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
