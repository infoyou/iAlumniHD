//
//  NearbyPeopleCell.h
//  iAlumniHD
//
//  Created by MobGuang on 12-7-31.
//
//

#import "BaseUITableViewCell.h"

@class Alumni;
@class Member;

@interface NearbyPeopleCell : BaseUITableViewCell {
    
    Alumni  *_alumni;
    UIView *_imageBackgroundView;
    UIImageView *_photoImageView;
    UIButton *_authorImageButton;
    
	UIView *editorImageShadowView;
	UILabel *classLabel;
    UILabel *nameLabel;
    UILabel *companyLabel;
    
    UIImageView *chatImgView;
    UIButton *_chatImgBut;
    
    NSString *_url;
    
    id<ECClickableElementDelegate> _delegate;
}

@property (nonatomic, retain) UIView			*editorImageShadowView;
@property (nonatomic, retain) UILabel			*companyLabel;
@property (nonatomic, retain) UILabel			*nameLabel;
@property (nonatomic, retain) UILabel			*classLabel;
@property (nonatomic, retain) NSString          *_url;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<ImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (void)drawCell:(Alumni *)alumni;

@end
