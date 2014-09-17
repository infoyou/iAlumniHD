//
//  WXWImageConsumerCell.h
//  iAlumniHD
//
//  Created by Mobguang on 11-11-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "ImageFetcherDelegate.h"
#import "ImageDisplayerDelegate.h"
#import "WXWTextBoardCell.h"

@interface WXWImageConsumerCell : WXWTextBoardCell <ImageFetcherDelegate> {
  
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  
  NSManagedObjectContext *_MOC;
  
@private
  NSMutableArray *_imageUrls;
  
}

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (CATransition *)imageTransition;

- (BOOL)currentUrlMatchCell:(NSString *)url;

- (void)fetchImage:(NSMutableArray *)imageUrls forceNew:(BOOL)forceNew;

/*
- (void)removeLabelShadowForHighlight:(UILabel **)label;

- (void)addLabelShadowForHighlight:(UILabel **)label;

- (void)hideLabelShadow;

- (void)showLabelShadow;
*/
@end
