//
//  PostContentCell.h
//  iAlumniHD
//
//  Created by Adam on 12-10-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"
#import "ECClickableElementDelegate.h"
#import <MapKit/MapKit.h>

@class WXWLabel;
@class Post;
@class WXWAsyncConnectorFacade;
@class WXWGradientButton;
@class ECEmbedMapView;
@class LikePeopleAlbumView;
@class TagListView;

@interface PostContentCell : BaseUITableViewCell <UIWebViewDelegate, MKMapViewDelegate> {
@private
    
    PostType _postType;
    
    UIWebView *_contentWebView;
    
    UIButton *_authorPhotoBackgroundButton;
    UIImageView *_authorPhotoImageView;
    
    WXWGradientButton *_likeButton;
    WXWGradientButton *_shareButton;
    WXWGradientButton *_favoriteButton;
    WXWGradientButton *_surveyBut;
    WXWGradientButton *_surveyResultBut;
    
    UIView *_imageBackgroundView;
    UIButton *_imageButton;
    //UIImageView *_loadImageView;
    
    WXWLabel *_authorLabel;
    
    WXWLabel *_likedCountLabel;
    LikePeopleAlbumView *_likePeopleAlbumView;
    
    UIView *_embedMapBackgroundView;
    ECEmbedMapView *_embedMapView;
    
    TagListView *_tagListView;
    
    WXWLabel *_placeLabel;
    WXWLabel *_dateLabel;
    WXWLabel *_createdAtLabel;
    
    UIButton *_deleteButton;
    
    id<ECClickableElementDelegate> _clickableElementHolderDelegate;
    
    NSString *_imageFormat;
    
    UIImage *_loadedImage;
    
    BOOL _authorImageLoaded;
    BOOL _attachedImageLoaded;
    BOOL _textContentLoaded;
    BOOL _isCanGoSurvey;
    
    BOOL _connectionCancelled;
    
    CGFloat _textContentHeight;
    
    NSString *_authorPhotoUrl;
    NSString *_imageUrl;
    
    NSString *_content;
    
    UIActivityIndicatorView *_likeSpinView;
    UIActivityIndicatorView *_favoriteSpinView;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementHolder:(id<ECClickableElementDelegate>)clickableElementHolder
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate
                MOC:(NSManagedObjectContext *)MOC
           postType:(PostType)postType;

- (void)drawPost:(Post *)feed;

@end
