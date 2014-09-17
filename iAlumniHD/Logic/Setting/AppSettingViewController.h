//
//  AppSettingViewController.h
//  iAlumniHD
//
//  Created by MobGuang on 12-9-29.
//
//

#import "BaseListViewController.h"
#import "UPOMP_iPad.h"

@interface AppSettingViewController : BaseListViewController <WXApiDelegate, UPOMP_iPad_Delegate> {
    
@private
    UIView *_footerView;
    
    NSInteger _alertOwnerType;
    UPOMP_iPad *cpView;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction;

@end
