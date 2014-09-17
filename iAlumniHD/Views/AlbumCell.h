//
//  AlbumCell.h
//  iAlumniHD
//
//  Created by Mobguang on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"


@interface AlbumCell : BaseUITableViewCell {
  @private
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  NSMutableDictionary *_photoDic;
  
  NSMutableDictionary *_buttonContainer;
  
  NSArray *_photos;
}

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier 
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate 
                MOC:(NSManagedObjectContext *)MOC;

- (void)drawAlbumCell:(NSArray *)photos;

@end
