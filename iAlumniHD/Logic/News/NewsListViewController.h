//
//  NewsListViewController.h
//  iAlumniHD
//
//  Created by Adam on 12-11-23.
//
//

#import "BaseListViewController.h"

@interface NewsListViewController : BaseListViewController {
    
@private
    NSInteger _pageIndex;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction;

@end
