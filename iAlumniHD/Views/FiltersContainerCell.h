//
//  FiltersContainerCell.h
//  iAlumniHD
//
//  Created by MobGuang on 12-8-2.
//
//

#import <UIKit/UIKit.h>

@class NearbyFilterContainerView;

@interface FiltersContainerCell : UITableViewCell {
  @private
  NearbyFilterContainerView *_filterContainer;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
                MOC:(NSManagedObjectContext *)MOC
 needDistanceFilter:(BOOL)needDistanceFilter
     needTimeFilter:(BOOL)needTimeFilter
    containerHeight:(CGFloat)containerHeight;

@end
