//
//  UIUrlLabel.h
//  iAlumniHD
//
//  Created by Adam on 12-11-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIUrlLabelDelegate.h"

@interface UIUrlLabel : UILabel
{
    id <UIUrlLabelDelegate> delegate;
}

@property (nonatomic, assign) id <UIUrlLabelDelegate> delegate;
- (id)initWithFrame:(CGRect)frame;

@end
