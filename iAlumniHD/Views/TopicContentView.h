//
//  TopicContentView.h
//  iAlumniHD
//
//  Created by MobGuang on 12-9-11.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@class WXWLabel;

@interface TopicContentView : UIView {
  @private
  WXWLabel *_contentLabel;
}

- (id)initWithFrame:(CGRect)frame content:(NSString *)content;

@end
