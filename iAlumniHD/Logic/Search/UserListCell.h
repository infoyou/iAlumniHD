//
//  UserListCell.h
//  iAlumniHD
//
//  Created by MobGuang on 10-10-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"
#import "Alumni.h"
#import "WXWLabel.h"

@interface UserListCell : BaseUITableViewCell {
    
    Alumni  *_alumni;
    
	UIImageView *userImgView;
    UIButton *_userImgButton;
    
    UIImageView *chatImgView;
    UIButton *_chatImgBut;
    
	UIView *editorImageShadowView;
	UILabel *classLabel;
    UILabel *nameLabel;
    UILabel *companyLabel;
    
    WXWLabel *_tableInfoLabel;
    
    UILabel *shakePlaceLabel;
    UILabel *shakeThingLabel;
    WXWLabel *_distance;
    WXWLabel *_time;
    WXWLabel *_plat;
    
    NSString *_url;
    
    id<ECClickableElementDelegate> _delegate;
}

@property (nonatomic, retain) UIImageView		*userImgView;
@property (nonatomic, retain) UIImageView       *chatImgView;
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

- (void)drawCell:(Alumni*)alumni userListType:(WebItemType)userListType;

@end
