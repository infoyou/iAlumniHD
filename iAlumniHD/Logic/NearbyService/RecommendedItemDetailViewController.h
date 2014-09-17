//
//  RecommendedItemDetailViewController.h
//  iAlumniHD
//
//  Created by Mobguang on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "GlobalConstants.h"
#import "ImageFetcherDelegate.h"
#import "ECClickableElementDelegate.h"

@class ServiceItemLikerAlbumView;
@class RecommendedItem;
@class ItemNamesView;
@class RecommendedItemLikeAreaView;
@class WXWLabel;

@interface RecommendedItemDetailViewController : RootViewController <ImageFetcherDelegate, ECClickableElementDelegate> {
  @private
  
  RecommendedItem *_item;
  
  UIScrollView *_contentView;
  
  UIView *_imageBackgroundView;
  UIImageView *_photoView;
  UIImageView *_defaultImageView;
  
  RecommendedItemLikeAreaView *_likerAlbumArea;
  
  ItemNamesView *_namesView;
  
  UITextView *_introContentView;

  NSString *_hashedLikedItemId;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC 
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction
             item:(RecommendedItem *)item;

@end
