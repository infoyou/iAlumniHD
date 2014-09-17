//
//  CommentListCell.h
//  iAlumniHD
//
//  Created by Adam on 12-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;
@class PostComment;

@interface CommentListCell : BaseUITableViewCell {
    
    PostComment *_comment;
    
@private
    
    WXWLabel *_timelineLabel;
    WXWLabel *_contentLabel;
    WXWLabel *_authorLabel;
    
    UIView *_userPicBackgroundView;
    UIButton *_authorPicButton;
    
    UIButton *_deleteButton;
    
    UIView *_imageBackgroundView;
    UIButton *_commentImageButton;
    
    NSString *_authorPicUrl;
    NSString *_imageUrl;
    NSString *_thumbnailUrl;
    
    id<ECClickableElementDelegate> _delegate;
    
    BOOL _imageLoaded;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (void)drawComment:(PostComment *)comment;

@end
