//
//  UIUrlLabelDelegate.h
//  iAlumniHD
//
//  Created by Adam on 12-11-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

@class UIUrlLabel;

@protocol UIUrlLabelDelegate <NSObject>

@optional
- (void)urlLabel:(UIUrlLabel *)urlLabel touchesWithTag:(NSInteger)tag;

@end
