//
//  LanguageListViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "AppSettingDelegate.h"

@interface LanguageListViewController : RootViewController <UITableViewDelegate, UITableViewDataSource, AppSettingDelegate>
{
    BOOL isFirst;
    
    NSInteger selectIndex;
    NSInteger currentIndex;
}

@end
