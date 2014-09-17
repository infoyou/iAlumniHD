//
//  ServiceItemCell.m
//  iAlumniHD
//
//  Created by Mobguang on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ServiceItemCell.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "ServiceItem.h"
#import "TextConstants.h"
#import "AppManager.h"

#import "CommonUtils.h"

#define ITEM_IMG_WIDTH				50.0f
#define ITEM_IMG_HEIGHT				50.0f

#define ITEM_NAME_WIDTH				360.0f
#define ITEM_NAME_HEIGHT			20.0f

#define ADDRESS_Y    					35.0f

#define BASE_INFO_HEIGHT      15.0f

#define ICON_WIDTH            16.0f
#define ICON_HEIGHT           16.0f

#define STATUS_Y              58.0f

#define HOT_IND_X             297.0f
#define HOT_IND_WIDTH         22.0f
#define HOT_IND_HEIGHT        22.0f

#define LABEL_WIDTH           120.0f
#define LABEL_HEIGHT          20.0f

#define COUPON_X              285.0f
#define COUPON_SIDE_LENGTH    32.0f

#define COMMENT_X             140.0f

@implementation ServiceItemCell

#pragma mark - lifecycle methods
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate 
                MOC:(NSManagedObjectContext *)MOC {
  self = [super initWithStyle:style 
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate 
                          MOC:MOC];
  if (self) {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.contentView.backgroundColor = CELL_COLOR;
    
    CGFloat backgroundViewSideLength = ITEM_IMG_WIDTH + 10.0f;
    UIView *imageBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN, 
                                                                            (80.0f - backgroundViewSideLength)/2, 
                                                                            backgroundViewSideLength, 
                                                                            backgroundViewSideLength)] autorelease];
    imageBackgroundView.backgroundColor = [UIColor whiteColor];
    imageBackgroundView.layer.borderWidth = 1.0f;
    imageBackgroundView.layer.borderColor = COLOR(227, 227, 227).CGColor;
    [self.contentView addSubview:imageBackgroundView];
    
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN, MARGIN, ITEM_IMG_WIDTH, ITEM_IMG_HEIGHT)];
    _avatarView.backgroundColor = TRANSPARENT_COLOR;
    [imageBackgroundView addSubview:_avatarView];
    
    _nameLabel = [self initLabel:CGRectMake(MARGIN + imageBackgroundView.frame.size.width + MARGIN * 2, 
                                            MARGIN, ITEM_NAME_WIDTH, ITEM_NAME_HEIGHT)
                       textColor:DARK_TEXT_COLOR
                     shadowColor:[UIColor whiteColor]];
    _nameLabel.font = FONT(16);
    _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [self.contentView addSubview:_nameLabel];
    
    /*
    _hotIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(HOT_IND_X, 0, HOT_IND_WIDTH, HOT_IND_HEIGHT)];
    _hotIndicator.backgroundColor = TRANSPARENT_COLOR;
    _hotIndicator.image = [UIImage imageNamed:@"hot.png"];
    [self.contentView addSubview:_hotIndicator];
    _hotIndicator.hidden = YES;
     */
    
    _addressLabel = [self initLabel:CGRectMake(_nameLabel.frame.origin.x,
                                               ADDRESS_Y, 0, BASE_INFO_HEIGHT)
                          textColor:[UIColor blackColor]
                        shadowColor:[UIColor whiteColor]];
    _addressLabel.font = FONT(12);
    [self.contentView addSubview:_addressLabel];
    
    //_couponIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, ADDRESS_Y - 8.0f, COUPON_SIDE_LENGTH, COUPON_SIDE_LENGTH)];
    _couponIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(COUPON_X, 
                                                                     0, COUPON_SIDE_LENGTH, COUPON_SIDE_LENGTH)];
    _couponIndicator.backgroundColor = TRANSPARENT_COLOR;
    _couponIndicator.image = [UIImage imageNamed:@"hasCoupon.png"];
    [self.contentView addSubview:_couponIndicator];
    _couponIndicator.hidden = YES;
        
    _categoryLabel = [self initLabel:CGRectMake(0, ADDRESS_Y, 0, BASE_INFO_HEIGHT)
                           textColor:[UIColor blackColor]
                         shadowColor:[UIColor whiteColor]];
    _categoryLabel.font = FONT(12);
    [self.contentView addSubview:_categoryLabel];
    
    _likeIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x, 
                                                                   STATUS_Y + 2, ICON_WIDTH, ICON_HEIGHT)];
    _likeIndicator.backgroundColor = TRANSPARENT_COLOR;
    _likeIndicator.image = [UIImage imageNamed:@"like.png"];
    [self.contentView addSubview:_likeIndicator];
    
    _likeCountLabel = [self initLabel:CGRectMake(_likeIndicator.frame.origin.x + ICON_WIDTH + MARGIN,
                                                 STATUS_Y + 2.0f, LABEL_WIDTH, LABEL_HEIGHT)
                            textColor:BASE_INFO_COLOR
                          shadowColor:[UIColor whiteColor]];
    _likeCountLabel.font = FONT(12);
    [self.contentView addSubview:_likeCountLabel];
    
    _commentIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(COMMENT_X, 
                                                                      STATUS_Y + 2, ICON_WIDTH, ICON_HEIGHT)];
    _commentIndicator.backgroundColor = TRANSPARENT_COLOR;
    _commentIndicator.image = [UIImage imageNamed:@"commentGray.png"];
    [self.contentView addSubview:_commentIndicator];
    
    _commentCountLabel = [self initLabel:CGRectMake(COMMENT_X + ICON_WIDTH + MARGIN, 
                                                    STATUS_Y + 2.0f, 
                                                    LABEL_WIDTH, LABEL_HEIGHT)
                               textColor:BASE_INFO_COLOR
                             shadowColor:[UIColor whiteColor]];
    _commentCountLabel.font = FONT(12);
    [self.contentView addSubview:_commentCountLabel];
    
    _distanceLabel = [self initLabel:CGRectMake(0, STATUS_Y + MARGIN, 0, BASE_INFO_HEIGHT)
                           textColor:BASE_INFO_COLOR
                         shadowColor:[UIColor whiteColor]];
    _distanceLabel.font = FONT(12);
    [self.contentView addSubview:_distanceLabel];
  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_avatarView);
  RELEASE_OBJ(_nameLabel);
  //RELEASE_OBJ(_hotIndicator);
  RELEASE_OBJ(_addressLabel);
  RELEASE_OBJ(_couponIndicator);
  RELEASE_OBJ(_categoryLabel);
  RELEASE_OBJ(_likeIndicator);
  RELEASE_OBJ(_likeCountLabel);
  RELEASE_OBJ(_commentIndicator);
  RELEASE_OBJ(_commentCountLabel);
  RELEASE_OBJ(_distanceLabel);
  
  [super dealloc];
}

- (void)prepareForReuse {
  [super prepareForReuse];
  
  _avatarView.image = nil;
}

- (void)drawItem:(ServiceItem *)item index:(NSInteger)index {
  
  NSString *imageName = item.liked.boolValue ? @"like.png" : @"unlike.png";
  
  _likeIndicator.image = [UIImage imageNamed:imageName];
  
  _nameLabel.text = [NSString stringWithFormat:@"%d. %@", index + 1, item.itemName];
  
  //_categoryLabel.text = item.categoryName;
  
  CGSize size = [_categoryLabel.text sizeWithFont:_categoryLabel.font
                                constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                                    lineBreakMode:UILineBreakModeWordWrap];
  _categoryLabel.frame = CGRectMake(295 - size.width, 
                                    _categoryLabel.frame.origin.y, 
                                    size.width,
                                    _categoryLabel.frame.size.height);
  
  _couponIndicator.hidden = !item.hasCoupon.boolValue;
  if (item.hasCoupon.boolValue) {
    _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, 
                                  _nameLabel.frame.origin.y,
                                  _couponIndicator.frame.origin.x - _nameLabel.frame.origin.x, 
                                  _nameLabel.frame.size.height);
  }
//  if (item.hasCoupon.boolValue) {
//    _couponIndicator.frame = CGRectMake(_categoryLabel.frame.origin.x - MARGIN - COUPON_SIDE_LENGTH, _couponIndicator.frame.origin.y, COUPON_SIDE_LENGTH, COUPON_SIDE_LENGTH);
//  } 
  
  _addressLabel.text = item.address;
//  CGFloat addressWidth = 0.0f;
//  if (item.hasCoupon.boolValue) {
//    addressWidth = _couponIndicator.frame.origin.x - _addressLabel.frame.origin.x - MARGIN;
//  } else {
//    addressWidth = _categoryLabel.frame.origin.x - _addressLabel.frame.origin.x - MARGIN;
//  }
  _addressLabel.frame = CGRectMake(_addressLabel.frame.origin.x, 
                                   _addressLabel.frame.origin.y, 
                                   ITEM_NAME_WIDTH, _addressLabel.frame.size.height);  
  
  //_hotIndicator.hidden = !item.hot.boolValue;
  
  _likeCountLabel.text = [NSString stringWithFormat:@"%@", item.likeCount];
  _commentCountLabel.text = [NSString stringWithFormat:@"%@", item.commentCount];
  if (item.likeCount.intValue > 0) {
    _likeCountLabel.hidden = NO;
    _likeIndicator.hidden = NO;
  } else {
    _likeCountLabel.hidden = YES;
    _likeIndicator.hidden = YES;
  }
  if (item.commentCount.intValue > 0) {
    _commentCountLabel.hidden = NO;
    _commentIndicator.hidden = NO;
  } else {
    _commentCountLabel.hidden = YES;
    _commentIndicator.hidden = YES;
  }
  
  _distanceLabel.text = [NSString stringWithFormat:@"%.2f %@", 
                         item.distance.floatValue, 
                         LocaleStringForKey(NSKMTitle, nil)];
  
  size = [_distanceLabel.text sizeWithFont:_distanceLabel.font
                         constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                             lineBreakMode:UILineBreakModeWordWrap];
  
  _distanceLabel.frame = CGRectMake(LIST_WIDTH - MARGIN - size.width,
                                    _distanceLabel.frame.origin.y, 
                                    size.width, _distanceLabel.frame.size.height);
  
  if (item.thumbnailUrl && item.thumbnailUrl.length > 0) {
    NSMutableArray *urls = [NSMutableArray array];
    [urls addObject:item.thumbnailUrl];
    [self fetchImage:urls forceNew:NO];
  } else {
    _avatarView.image = nil;
  }
}

#pragma mark - ImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    _avatarView.image = nil;
  }  
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    [_avatarView.layer addAnimation:[self imageTransition] forKey:nil];
    _avatarView.image = [CommonUtils cutPartImage:image width:ITEM_IMG_WIDTH height:ITEM_IMG_HEIGHT];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  /*
  if ([self currentUrlMatchCell:url]) {
    _avatarView.image = image;
  }
   */
  [self imageFetchDone:image url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

@end
