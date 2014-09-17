//
//  ClubManagementDelegate.h
//  iAlumniHD
//
//  Created by MobGuang on 12-10-8.
//
//

#import <Foundation/Foundation.h>

@protocol ClubManagementDelegate <NSObject>

@optional

- (void)doJoin2Quit:(BOOL)joinStatus ifAdmin:(NSString*)ifAdmin;
- (void)doManage;
- (void)doDetail;
- (void)goClubActivity;
- (void)goClubUserList;
- (void)doPost;
- (void)showFilters;

@end
