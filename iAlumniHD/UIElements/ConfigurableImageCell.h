//
//  ConfigurableImageCell.h
//  iAlumniHD
//
//  Created by MobGuang on 12-11-24.
//
//

#import "ConfigurableTextCell.h"
#import "GlobalConstants.h"
#import "ImageFetcherDelegate.h"
#import "ImageDisplayerDelegate.h"


@interface ConfigurableImageCell : ConfigurableTextCell <ImageFetcherDelegate> {
  
  id<ImageDisplayerDelegate> _imageDisplayerDelegate;
  
  NSManagedObjectContext *_MOC;
  
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (CATransition *)imageTransition;

- (BOOL)currentUrlMatchCell:(NSString *)url;

- (void)fetchImage:(NSMutableArray *)imageUrls forceNew:(BOOL)forceNew;


@end
