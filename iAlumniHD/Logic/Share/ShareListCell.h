//
//  ShareListCell.h
//  iAlumniHD
//
//  Created by Adam on 12-11-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"

@class WXWLabel;
@class ECHandyImageBrowser;
@class SharePost;
@class TagsOmissionView;

@interface ShareListCell : BaseUITableViewCell {
    
    SharePost *_post;
    
@private
    UIButton *_authorImageButton;
    UIView *_authorImageBackgroundView;
    
    WXWLabel *_editorNameLabel;
    WXWLabel *_contentLabel;
    WXWLabel *_distanceLabel;
    
    UIView      *_postImageBackgroundView;
    UIButton    *_postImageButton;
    
    id<ECClickableElementDelegate> _delegate;
    
    ECHandyImageBrowser *_imageBrowser;
    
    UIImage         *_postImage;
    
    NSString *_authorPicUrl;
    NSString *_imageUrl;
    NSString *_thumbnailUrl;
    
    // indicator
    UIImageView		*_locAttachedIndicator;
	WXWLabel         *_commentCountLabel;
    UIImageView     *_commentIcon;
    WXWLabel         *_likeCountLabel;
    UIImageView     *_likeIcon;
	WXWLabel         *_timeline;
    UIImageView     *_hotIndicaor;
    UILabel			*_smsLabel;
    
    TagsOmissionView *_tagsView;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (void)drawPost:(SharePost *)post MOC:(NSManagedObjectContext *)MOC;
- (void)initSmsArea;

@end
