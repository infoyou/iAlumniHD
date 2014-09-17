//
//  ComposerDelegate.h
//  iAlumniHD
//
//  Created by Adam on 12-11-8.
//
//

#import <Foundation/Foundation.h>

@protocol ComposerDelegate <NSObject>

@optional
- (void)addPlaceText;
- (void)addTagText;
- (void)textChanged:(NSString *)text;

@end
