//
//  TapSwitchDelegate.h
//  iAlumniHD
//
//  Created by MobGuang on 12-9-2.
//
//

#import <Foundation/Foundation.h>

@protocol TapSwitchDelegate <NSObject>

@optional
- (void)selectTapByIndex:(int)index;

@end
