//
//  ClubDetailController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"
#import <MapKit/MapKit.h>
#import "AsyncImageView.h"
#import "ClubDetail.h"

@interface ClubDetailController : BaseViewController <UITableViewDelegate, UITableViewDataSource>
{
  BOOL _autoLoaded;
  
  ClubDetail *_club;
  
  NSArray *iLabel1Array;
  NSArray *iValue1Array;
  
  NSArray *_clubInstructionList;
  
  UIPopoverController *_popoverView;
  
  UIView *_headerView;
  BOOL joinStatus;
}

@property (nonatomic, retain) ClubDetail *_club;
@property (nonatomic, retain) NSArray *iLabel1Array;
@property (nonatomic, retain) NSArray *iValue1Array;

- (id)initWithMOC:(NSManagedObjectContext*)MOC;
- (void)configureCell:(NSIndexPath *)indexPath aCell:(UITableViewCell *)cell;
- (void)fetchItems;

@end
