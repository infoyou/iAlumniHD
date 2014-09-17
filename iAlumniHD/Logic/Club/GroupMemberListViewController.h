//
//  GroupMemberListViewController.h
//  iAlumniHD
//
//  Created by MobGuang on 12-12-6.
//
//

#import "AlumniListViewController.h"

@class Club;

@interface GroupMemberListViewController : AlumniListViewController {
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC group:(Club *)group;

@end
