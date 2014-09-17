//
//  ClubEventListViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-10-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"

@interface ClubEventListViewController : BaseListViewController 
{
    
@private
    
    NSInteger _pageIndex;
    NSString *_requestParam;
}

@property (nonatomic, copy) NSString *requestParam;
@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, retain) NSString *selectedSponsorType;

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
