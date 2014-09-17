//
//  BrandsViewController.h
//  iAlumniHD
//
//  Created by MobGuang on 12-8-20.
//
//

#import "BaseListViewController.h"

@interface BrandsViewController : BaseListViewController {
  @private
  
  BOOL _currentLocationIsLatest;

}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
