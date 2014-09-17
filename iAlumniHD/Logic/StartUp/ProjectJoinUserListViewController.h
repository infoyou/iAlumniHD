//
//  ProjectJoinUserListViewController.h
//  iAlumniHD
//
//  Created by Adam on 13-3-11.
//
//

#import "AlumniListViewController.h"

@interface ProjectJoinUserListViewController : AlumniListViewController {
  @private
  
  long long _eventId;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC eventId:(long long)eventId;

@end
